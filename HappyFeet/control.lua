local Blacklist = require('req/blacklist')
local Pause = require('req/pause')
local Placement = require('req/placement')
local Range = require('req/range')
local TileData = require('req/tile_data')

local function On_Initialize(event, forceful)
	--We need to rebuild this each time, in case the prototypes have changed
	TileData.RebuildTileData()
	Blacklist.RebuildBlacklists()
end

local function On_PlayerPosition(event)
	local player = game.players[event.player_index]
	Placement.HappifyFeet(player)
end

local function On_SettingsChanged(event)
	Blacklist.UpdatePlayerBlacklist(event.player_index)
	TileData.RebuildTileData()
end

local function On_PausePlacement(event)
	Pause.TogglePause(event.player_index)
end

local function On_IncreasePlacementRange(event)
	Range.IncrementRange(event.player_index, true)
end

local function On_DecreasePlacementRange(event)
	Range.IncrementRange(event.player_index, false)
end

local function On_VehicleChange(event)
	Pause.VehiclePause(event.player_index, event.entity)
end

script.on_init(On_Initialize)
script.on_configuration_changed(On_Initialize)
script.on_event(defines.events.on_player_changed_position, On_PlayerPosition)
script.on_event(defines.events.on_runtime_mod_setting_changed, On_SettingsChanged)
script.on_event(defines.events.on_player_driving_changed_state, On_VehicleChange)

-- Handle hotkey presses.
script.on_event('happyfeet-pause', On_PausePlacement)
script.on_event('happyfeet-increase', On_IncreasePlacementRange)
script.on_event('happyfeet-decrease', On_DecreasePlacementRange)
