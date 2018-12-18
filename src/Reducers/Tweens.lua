--[[
	Reducer for the current tweens.
	Stores the tween sequence that the user is editing.

	Consider storing:
		Tween that is currently being edited
		Edits to current tweenTable
		All tweens that exist under the current instance
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetCurrentTween = require(Plugin.Src.Actions.SetCurrentTween)
local SetCurrentTable = require(Plugin.Src.Actions.SetCurrentTable)
local SetTweens = require(Plugin.Src.Actions.SetTweens)

local function Tweens(state, action)
	state = state or {
		Tweens = nil,
		CurrentTable = nil,
		CurrentTween = nil,
	}

	if action.type == SetCurrentTween.name then
		return Cryo.Dictionary.join(state, {
			CurrentTween = action.value,
		})
	elseif action.type == SetCurrentTable.name then
		return Cryo.Dictionary.join(state, {
			CurrentTable = action.value,
		})
	elseif action.type == SetTweens.name then
		return Cryo.Dictionary.join(state, {
			Tweens = action.value,
		})
	end

	return state
end

return Tweens