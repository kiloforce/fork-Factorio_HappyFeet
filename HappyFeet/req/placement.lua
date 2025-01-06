local Pause = require('req/pause')
local Range = require('req/range')
local TileData = require('req/tile_data')

local function TileCanBePlaced(newTdata, player, oldTile)
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
	local tproto1 = tile.prototype
	-- log(tproto1.name .. " : " .. tproto1.walking_speed_modifier .. " : " .. tdata2.walking_speed_modifier)
	if tproto1.walking_speed_modifier >= tdata2.walking_speed_modifier then
		return true
	end

	return false
end

local function PlaceTileFromInventory(newTile, player, oldTile)
	--This doesn't check anything; it just takes an item and plops it on the ground.
	local removeTile = {name=newTile.item_name, count=1}
	local placeTile = {{name=newTile.tile_name, position=oldTile.position}}

	if player.get_main_inventory().remove(removeTile) > 0 then
		if prototypes.tile[oldTile.name].mineable_properties.minable then
			player.mine_tile(oldTile)
		end

		player.surface.set_tiles(placeTile)
	end
end

local function HappifyFeet(player)
	if Pause.IsPaused(player.index) or Pause.IsVehiclePaused(player.index) then
		return
	end

	if not player.get_main_inventory() then
		--Probably haven't finished the opening cutscene yet
		return
	end

	local newTdata = TileData.FindOnPlayer(player) or false
	if not newTdata then
		return
	end

	local range = Range.GetRange(player)
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

local placement = {}
--placement.TileCanBePlaced = TileCanBePlaced
--placement.WalkingSpeedIsGreater = WalkingSpeedIsGreater
--placement.PlaceTileFromInventory = PlaceTileFromInventory
placement.HappifyFeet = HappifyFeet
return placement
