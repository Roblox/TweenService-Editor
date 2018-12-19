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
local SetExpandedItems = require(Plugin.Src.Actions.SetExpandedItems)
local ToggleExpanded = require(Plugin.Src.Actions.ToggleExpanded)

local function Status(state, action)
	state = state or {
		HasFocus = false,
		IsOpen = false,
		IsPlaying = false,
		CurrentInstance = nil,
		ExpandedItems = {},
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
	elseif action.type == SetExpandedItems.name then
		return Cryo.Dictionary.join(state, {
			ExpandedItems = action.value or {},
		})
	elseif action.type == ToggleExpanded.name then
		local oldValue = state.ExpandedItems[action.path]
		return Cryo.Dictionary.join(state, {
			ExpandedItems = Cryo.Dictionary.join(state.ExpandedItems, {
				[action.path] = not oldValue
			})
		})
	end

	return state
end

return Status