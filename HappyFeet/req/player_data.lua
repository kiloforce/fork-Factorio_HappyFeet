local function Lazy()
	if not global.player_data then
		global.player_data = {}
	end
end

local function LazyPlayer(player_index)
	Lazy()
	if not global.player_data[player_index] then
		global.player_data[player_index] = {}
	end
end



local player_data = {}
player_data.Lazy = Lazy
player_data.LazyPlayer = LazyPlayer
return player_data
