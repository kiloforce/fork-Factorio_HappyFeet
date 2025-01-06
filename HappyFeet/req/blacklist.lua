local String = require('utils/strings')

local PlayerData = require('req/player_data')

local function _GetBlacklist(player_index)
	PlayerData.LazyPlayer(player_index)
	return storage.player_data[player_index].blacklist or {"stone","stone-path"}
end

local function _SetBlacklist(player_index, value)
	PlayerData.LazyPlayer(player_index)
	storage.player_data[player_index].blacklist = value
end



local function UpdatePlayerBlacklist(player_index)
	local blacklist_raw = game.players[player_index].mod_settings["tile-blacklist"].value
	local bl = String.split(blacklist_raw,",")

	for i = 1, #bl do
		bl[i] = String.trim(bl[i])
	end

	_SetBlacklist(player_index,bl)
end

local function RebuildBlacklists()
	for player_index = 1, #game.players do
		UpdatePlayerBlacklist(player_index)
	end
end

local function Exists(player_index, item_name)
	local blacklist = _GetBlacklist(player_index)

	for i = 1, #blacklist do
		if (blacklist[i] == item_name) then
			return true
		end
	end

	return false
end



local blacklist = {}
blacklist.RebuildBlacklists = RebuildBlacklists
blacklist.UpdatePlayerBlacklist = UpdatePlayerBlacklist
blacklist.Exists = Exists
return blacklist
