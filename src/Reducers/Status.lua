--[[
	Reducer for the current status of the application.

	Consider storing:
		Timeline zoom level
		Timeline position
		Currently selected keyframe?
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetHasFocus = require(Plugin.Src.Actions.SetHasFocus)
local SetIsOpen = require(Plugin.Src.Actions.SetIsOpen)
local SetIsPlaying = require(Plugin.Src.Actions.SetIsPlaying)
local SetCurrentInstance = require(Plugin.Src.Actions.SetCurrentInstance)
local SetInstanceStates = require(Plugin.Src.Actions.SetInstanceStates)
local SetPolling = require(Plugin.Src.Actions.SetPolling)
local ToggleExpanded = require(Plugin.Src.Actions.ToggleExpanded)
local SetSelectedKeyframe = require(Plugin.Src.Actions.SetSelectedKeyframe)
local SetPlayhead = require(Plugin.Src.Actions.SetPlayhead)
local SetDirty = require(Plugin.Src.Actions.SetDirty)
local SetClipboard = require(Plugin.Src.Actions.SetClipboard)
local SetTweens = require(Plugin.Src.Actions.SetTweens)

local function Status(state, action)
	state = state or {
		HasFocus = false,
		IsOpen = false,
		IsPlaying = false,
		CurrentInstance = nil,
		Polling = nil,
		InstanceStates = {},
		SelectedKeyframe = nil,
		Playhead = 0,
		Clipboard = nil,
		Dirty = false,
	}

	if action.type == SetHasFocus.name then
		return Cryo.Dictionary.join(state, {
			HasFocus = action.value,
		})
	elseif action.type == SetIsOpen.name then
		return Cryo.Dictionary.join(state, {
			IsOpen = action.value,
		})
	elseif action.type == SetIsPlaying.name then
		return Cryo.Dictionary.join(state, {
			IsPlaying = action.value,
		})
	elseif action.type == SetCurrentInstance.name then
		return Cryo.Dictionary.join(state, {
			CurrentInstance = action.value or Cryo.None,
		})
	elseif action.type == SetInstanceStates.name then
		return Cryo.Dictionary.join(state, {
			InstanceStates = action.value or {},
		})
	elseif action.type == ToggleExpanded.name then
		local oldValue = state.InstanceStates[action.path].Expanded
		return Cryo.Dictionary.join(state, {
			InstanceStates = Cryo.Dictionary.join(state.InstanceStates, {
				[action.path] = Cryo.Dictionary.join(state.InstanceStates[action.path], {
					Expanded = not oldValue,
				})
			})
		})
	elseif action.type == SetPolling.name then
		return Cryo.Dictionary.join(state, {
			Polling = action.value,
		})
	elseif action.type == SetSelectedKeyframe.name then
		return Cryo.Dictionary.join(state, {
			SelectedKeyframe = action.value,
		})
	elseif action.type == SetPlayhead.name then
		if action.value and action.value >= 0 then
			return Cryo.Dictionary.join(state, {
				Playhead = action.value,
			})
		else
			return Cryo.Dictionary.join(state, {
				Playhead = 0,
			})
		end
	elseif action.type == SetDirty.name then
		return Cryo.Dictionary.join(state, {
			Dirty = action.value,
		})
	elseif action.type == SetTweens.name then
		return Cryo.Dictionary.join(state, {
			Dirty = true,
		})
	elseif action.type == SetClipboard.name then
		return Cryo.Dictionary.join(state, {
			Clipboard = action.value,
		})
	end

	return state
end

return Status