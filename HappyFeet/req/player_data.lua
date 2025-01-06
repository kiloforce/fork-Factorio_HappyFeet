local function Lazy()
	if not storage.player_data then
		storage.player_data = {}
	end
end

local function LazyPlayer(player_index)
	Lazy()
	if not storage.player_data[player_index] then
		storage.player_data[player_index] = {}
	end
end



local player_data = {}
player_data.Lazy = Lazy
player_data.LazyPlayer = LazyPlayer
return player_data
