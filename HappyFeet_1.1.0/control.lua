local str = require('lib/strings')

local function On_Initialize(event, forceful)
	--We need to rebuild this each time, in case the prototypes have changed
	RebuildTileData()
	RebuildBlacklists()
end

function RebuildTileData()
	global.tile_data = {}
	global.tile_data_TileNameIndexed = {}
	for _, item in pairs(game.item_prototypes) do
		local tdata = {}
		if item.place_as_tile_result ~= nil then
			local result = item.place_as_tile_result.result

			tdata.item_name = item.name
			tdata.tile_name = result.name
			tdata.walking_speed_modifier = result.walking_speed_modifier

			table.insert(global.tile_data, tdata)
			global.tile_data_TileNameIndexed[tdata.tile_name] = tdata
		end
	end
	table.sort(global.tile_data, function(a, b)
			return a.walking_speed_modifier > b.walking_speed_modifier
		end)

	-- for k,v in pairs(global.tile_data) do
	-- 	log(k .. " : " .. v.item_name .. " : " .. v.tile_name .. " : " .. v.walking_speed_modifier)
	-- end
end

function RebuildBlacklists()
	global.playerBlacklists = {}
	for player_index = 1, #game.players do
		UpdatePlayerBlacklist(player_index)
	end
end


function UpdatePlayerBlacklist(player_index)
	local blacklist_raw = game.players[player_index].mod_settings["tile-blacklist"].value
	local bl = str.split(blacklist_raw,",")

	for i = 1, #bl do
		bl[i] = str.trim(bl[i])
	end

	global.playerBlacklists[player_index] = bl
end

local function On_PlayerPosition(event)
	local player = game.players[event.player_index]
	if player.get_main_inventory() == nil then
		--Probably haven't finished the opening cutscene yet
		return
	end

	local newTdata = FindTDataItemStacks(player) or false
	if not newTdata then
		return
	end

	local range = player.mod_settings["tile-range"].value
	local side = range*2-1
	local items_avail = newTdata.inv_count

	for iy = -(range-1), (range-1) do
		local y = iy + player.position.y
		for ix = -(range-1), (range-1) do
			local x = ix + player.position.x

			local oldTile = player.surface.get_tile(x, y)
			-- log(ix .. "(" .. x .. ")" .. "," .. iy .. "(" .. y .. ")" .. " : " .. oldTile.name .. " : " .. items_avail)
			local canPlace = TileCanBePlaced(newTdata, player, oldTile)
			if canPlace then
				-- log("can place!")
				PlaceTileFromInventory(newTdata, player, oldTile)
			else
				items_avail = items_avail + 1
				--We didn't use up a tile so we can add this to our available item count.
				--This isn't the clearest code, but since we are determining our position
				--in the placement area via geometry instead of a variable counting items
				--used, this addition will ensure that we don't run out before we're done
			end

			if side*(iy-1) + ix > items_avail then
				goto out_of_resources
			end
		end
	end
	::out_of_resources::
end

function TileCanBePlaced(newTdata, player, oldTile)
	--returns false if:
	--	There is no tile in Ba Sing Se
	--	The tile-to-place is the same as the tile-that's-there
	--	The tile-to-place is slower or equal to whatever tile is already there
	--	The tile couldn't normally be placed (eg. concrete on water)
	if not newTdata then
		return false
	end

	if oldTile.name == newTdata.tile_name then
		return false
	end

	if WalkingSpeedIsGreater(oldTile, newTdata) then
		return false
	end

	if player.mod_settings["happy-factorissimo"].value == false then
		if player.surface.name:find("^Factory floor ") then
			return false
		end
	end

	--Testing to see if the tile could normally be placed here.
	--	It's Bit roundabout, but a great workaround was found! Thanks Honktown!
	if player.surface.can_place_entity{name="tile-ghost", position=oldTile.position, inner_name=newTdata.tile_name, force=player.force} then
		return true
	end

	return false
end

function WalkingSpeedIsGreater(tile, tdata2)
	-- local tdata1 = global.tile_data_TileNameIndexed[tile.name]
	-- if tdata1 then
	-- 	if tdata1.walking_speed_modifier >= tdata2.walking_speed_modifier then
	-- 		return true
	-- 	end
	-- end

	local tproto1 = tile.prototype
	-- log(tproto1.name .. " : " .. tproto1.walking_speed_modifier .. " : " .. tdata2.walking_speed_modifier)
	if tproto1.walking_speed_modifier >= tdata2.walking_speed_modifier then
		return true
	end

	return false
end

function PlaceTileFromInventory(newTile, player, oldTile)
	--This doesn't check anything; it just takes an item and plops it on the ground.
	local removeTile = {name=newTile.item_name, count=1}
	local placeTile = {{name=newTile.tile_name, position=oldTile.position}}

	if player.get_main_inventory().remove(removeTile) > 0 then
		if game.tile_prototypes[oldTile.name].mineable_properties.minable then
			player.mine_tile(oldTile)
		end

		player.surface.set_tiles(placeTile)
	end
end

function FindTDataItemStacks(player)
	if not global.tile_data then
		RebuildTileData()
	end
	for i = 1, #global.tile_data do
		local tdata = global.tile_data[i]
		local item_stack = player.get_main_inventory().find_item_stack(tdata.item_name)
		if item_stack and not IsInPlayerBlacklist(player.index, tdata.item_name) then
			tdata.inv_count = item_stack.count
			return tdata
		end
	end
end

function IsInPlayerBlacklist(player_index, item_name)
	local blacklist = global.playerBlacklists[player_index]

	for i = 1, #blacklist do
		if (blacklist[i] == item_name) then
			return true
		end
	end

	return false
end

local function On_SettingsChanged(player_index)
	RebuildBlacklists(player_index)
	RebuildTileData()
end

script.on_init(On_Initialize)
script.on_configuration_changed(On_Initialize)
script.on_event(defines.events.on_runtime_mod_setting_changed, On_SettingsChanged)
script.on_event(defines.events.on_player_changed_position, On_PlayerPosition)
