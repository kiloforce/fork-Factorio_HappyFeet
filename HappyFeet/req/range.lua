local String = require('utils/strings')

local PlayerData = require('req/player_data')

local function _GetRange(player_index)
	PlayerData.LazyPlayer(player_index)
	return storage.player_data[player_index].range or 2
end

local function _SetRange(player_index, value)
	PlayerData.LazyPlayer(player_index)
	storage.player_data[player_index].range = value
end

local function DrawRange(player_index, range)
	local p = game.players[player_index]
	if not p.character then
		return
	end

	local tile_width = range * 2 - 1
	local position = p.character.position  -- Get character's current position

	-- Calculate the exact top-left and bottom-right positions
	local left_top = {position.x - tile_width / 2, position.y - tile_width / 2}
	local right_bottom = {position.x + tile_width / 2, position.y + tile_width / 2}

	rendering.draw_rectangle {
		color = {r = 0, g = 1, b = 0},
		width = 1,
		left_top = left_top,
		right_bottom = right_bottom,
		surface = p.surface,
		time_to_live = 30,
		players = {p}
	}
end

local function IncrementRange(player_index, positive)
	local c = -1
	if positive then
		c = 1
	end
	local old_range = _GetRange(player_index)
	local new_range = old_range + (c * 1)
	if new_range < 1 then
		new_range = 1
	elseif new_range > 20 then
		new_range = 20
	end
	_SetRange(player_index, new_range)

	DrawRange(player_index, new_range)

	String.printOrFlyIndex(player_index, "Happy Feet range is " .. new_range)
end

local function GetRangeByIndex(player_index)
	return _GetRange(player_index)
end

local function GetRange(player)
	return GetRangeByIndex(player.index)
end



local range = {}
--range.DrawRange = DrawRange
range.IncrementRange = IncrementRange
--range.GetRangeByIndex = GetRangeByIndex
range.GetRange = GetRange
return range
