local String = require('utils/strings')

local PlayerData = require('req/player_data')

local function _GetPaused(player_index)
	PlayerData.LazyPlayer(player_index)
	return storage.player_data[player_index].paused or false
end

local function _SetPaused(player_index, value)
	PlayerData.LazyPlayer(player_index)
	storage.player_data[player_index].paused = value
end

local function _GetVehiclePaused(player_index)
	PlayerData.LazyPlayer(player_index)
	return storage.player_data[player_index].vehicle_paused or false
end

local function _SetVehiclePaused(player_index, value)
	PlayerData.LazyPlayer(player_index)
	storage.player_data[player_index].vehicle_paused = value
end



local function IsPaused(player_index)
	return _GetPaused(player_index)
end

local function SetPause(player_index, bool)
	if bool ~= _GetPaused(player_index) then
		_SetPaused(player_index, bool)
		if bool then
			String.printOrFlyIndex(player_index, "Happy Feet paused!")
		else
			String.printOrFlyIndex(player_index, "Happy Feel unpaused!")
		end
	end
end

local function TogglePause(player_index)
	SetPause(player_index, not _GetPaused(player_index))
end

local function IsVehiclePaused(player_index)
	if not game.players[player_index].mod_settings["happy-vehicle-pause"].value then
		return false
	end
	return _GetVehiclePaused(player_index)
end

local function SetVehiclePause(player_index, bool)
	_SetVehiclePaused(player_index, bool)
end

local function VehiclePause(player_index)
	local vehicle = game.players[player_index].vehicle

	if not vehicle then
		SetVehiclePause(player_index, false)
	else
		SetVehiclePause(player_index, true)
	end
end



local pause = {}
pause.IsPaused = IsPaused
pause.SetPause = SetPause
pause.TogglePause = TogglePause
pause.IsVehiclePaused = IsVehiclePaused
--pause.SetVehiclePause = SetVehiclePause
pause.VehiclePause = VehiclePause
return pause
