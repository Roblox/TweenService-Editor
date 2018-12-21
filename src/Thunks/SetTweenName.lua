--[[
	Sets the name of the current edit tween
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local Exporting = require(Plugin.Src.Util.Exporting)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SetCurrentTween = require(Plugin.Src.Actions.SetCurrentTween)
local SetPolling = require(Plugin.Src.Actions.SetPolling)

return function(newName)
	return function(store)
		store:dispatch(SetPolling(Cryo.None))

		if newName ~= "" then
			local tweens = store:getState().Tweens.Tweens
			local currentTween = store:getState().Tweens.CurrentTween
			local tweenTable = tweens[currentTween]

			local newTweens = Cryo.Dictionary.join(tweens, {
				[newName] = tweenTable,
				[currentTween] = Cryo.None,
			})

			local root = store:getState().Status.CurrentInstance

			if root then
				Exporting.TagAnimatorWithKey(root.Animator, newName)
			end

			store:dispatch(SetTweens(newTweens))
			store:dispatch(SetCurrentTween(newName))
		end
	end
end