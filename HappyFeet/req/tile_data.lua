local Blacklist = require('blacklist')

local function LazyInit()
	if not global.tile_data then
		RebuildTileData()
	end
end

local function RebuildTileData()
	global.tile_data = {}
	for _, item in pairs(game.item_prototypes) do
		local tdata = {}
		if item.place_as_tile_result ~= nil then
			local result = item.place_as_tile_result.result

			tdata.item_name = item.name
			tdata.tile_name = result.name
			tdata.walking_speed_modifier = result.walking_speed_modifier

			table.insert(global.tile_data, tdata)
		end
	end
	table.sort(global.tile_data, function(a, b)
			return a.walking_speed_modifier > b.walking_speed_modifier
		end)

	-- for k,v in pairs(global.tile_data) do
	-- 	log(k .. " : " .. v.item_name .. " : " .. v.tile_name .. " : " .. v.walking_speed_modifier)
	-- end
end

local function FindOnPlayer(player)
	LazyInit()

	for i = 1, #global.tile_data do
		local tdata = global.tile_data[i]
		local item_stack = player.get_main_inventory().find_item_stack(tdata.item_name)
		if item_stack and not Blacklist.Exists(player.index, tdata.item_name) then
			tdata.inv_count = item_stack.count
			return tdata
		end
	end
end



local tile_data = {}
tile_data.RebuildTileData = RebuildTileData
tile_data.FindOnPlayer = FindOnPlayer
return tile_data
