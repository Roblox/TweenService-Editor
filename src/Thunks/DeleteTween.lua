--[[
	Deletes the current tween
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SetCurrentTween = require(Plugin.Src.Thunks.SetCurrentTween)
local SetCurrentInstance = require(Plugin.Src.Actions.SetCurrentInstance)
local SetInstanceStates = require(Plugin.Src.Actions.SetInstanceStates)
local isEmpty = require(Plugin.Src.Util.isEmpty)
local Exporting = require(Plugin.Src.Util.Exporting)

return function()
	return function(store)
		local tweens = store:getState().Tweens.Tweens
		local currentTween = store:getState().Tweens.CurrentTween

		local newTweens = Cryo.Dictionary.join(tweens, {
			[currentTween] = Cryo.None
		})

		if isEmpty(newTweens) then
			Exporting.DeleteAll(store:getState().Status.CurrentInstance)
			store:dispatch(SetCurrentInstance(nil))
			store:dispatch(SetInstanceStates({}))
		else
			store:dispatch(SetCurrentTween(next(newTweens)))
			store:dispatch(SetTweens(newTweens))
		end
	end
end