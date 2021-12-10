local str = require('lib/strings')

local function On_Initialize(event, forceful)
	--On_Initialize the blacklists
	global.playerBlacklists = global.playerBlacklists or {}
	if (global.playerBlacklists == nil or forceful) then
		global.playerBlacklists = {}
	end

	--We need to rebuild this each time, in case the prototypes have changed
	RebuildHappyData()

	UpdateAllBlacklists()
end

function RebuildHappyData()
	global.happyData = {}
	global.happyData_TileNameIndexed = {}
	for _, item in pairs(game.item_prototypes) do
		local tdata = {}
		if item.place_as_tile_result ~= nil then
			local result = item.place_as_tile_result.result

			tdata.item_name = item.name
			tdata.tile_name = result.name
			tdata.walking_speed_modifier = result.walking_speed_modifier

			table.insert(global.happyData, tdata)
			global.happyData_TileNameIndexed[tdata.tile_name] = tdata
		end
	end
	table.sort(global.happyData, function(a, b)
			return a.walking_speed_modifier > b.walking_speed_modifier
		end)

	-- for k,v in pairs(global.happyData) do
	-- 	log(k .. " : " .. v.item_name .. " : " .. v.tile_name .. " : " .. v.walking_speed_modifier)
	-- end
end

function UpdateAllBlacklists()
	for player_index = 1, #game.players do
		UpdatePlayerBlacklist(player_index)
	end
end


function UpdatePlayerBlacklist(player_index)
	local blacklist_raw = game.players[player_index].mod_settings["tile-blacklist"].value

	global.playerBlacklists[player_index] = str.split(blacklist_raw,",")
end

local function On_PlayerPosition(event)
	local player = game.players[event.player_index]
	if player.get_main_inventory() == nil then
		--Probably haven't finished the opening cutscene yet
		return
	end

	local newTdata = FindTDataItemStacks(player) or false
	local oldTile = player.surface.get_tile(player.position.x, player.position.y)

	local canPlace = TileCanBePlaced(newTdata, player, oldTile)
	if canPlace then
		PlaceTileFromInventory(newTdata, player, oldTile)
	end
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

	local oldTdata = global.happyData_TileNameIndexed[oldTile.name]
	if oldTdata and WalkingSpeedIsGreater(oldTdata, newTdata) then
		return false
	end

	--Testing to see if the tile could normally be placed here.
	--	It's Bit roundabout, but a great workaround was found! Thanks Honktown!
	if player.surface.can_place_entity{name="tile-ghost", position=player.position, inner_name=newTdata.tile_name, force=player.force} then
		return true
	end

	return false
end

function WalkingSpeedIsGreater(tdata1, tdata2)
	if tdata1.walking_speed_modifier >= tdata2.walking_speed_modifier then
		return true
	end
	return false
end

function PlaceTileFromInventory(newTile, player, oldTile)
	--This doesn't check anything; it just takes an item and plops it on the ground.
	local removeTile = {name=newTile.item_name, count=1}
	local placeTile = {{name=newTile.tile_name, position=player.position}}

	if player.get_main_inventory().remove(removeTile) > 0 then
		if game.tile_prototypes[oldTile.name].mineable_properties.minable then
			player.mine_tile(oldTile)
		end

		player.surface.set_tiles(placeTile)
	end
end

function FindTDataItemStacks(player)
	for i = 1, #global.happyData do
		local tdata = global.happyData[i]
		if player.get_main_inventory().find_item_stack(tdata.item_name) and not IsInPlayerBlacklist(player.index, tdata.item_name) then
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
	UpdateAllBlacklists(player_index)
	RebuildHappyData()
end

script.on_init(On_Initialize)
script.on_configuration_changed(On_Initialize)
script.on_event(defines.events.on_runtime_mod_setting_changed, On_SettingsChanged)
script.on_event(defines.events.on_player_changed_position, On_PlayerPosition)
