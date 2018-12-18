--[[
	Initializes a TweenSequence at the given root instance.
]]

local Plugin = script.Parent.Parent.Parent
local Exporting = require(Plugin.Src.Util.Exporting)
local SetCurrentInstance = require(Plugin.Src.Actions.SetCurrentInstance)
local SetCurrentTween = require(Plugin.Src.Actions.SetCurrentTween)
local SetCurrentTable = require(Plugin.Src.Actions.SetCurrentTable)
local SetTweens = require(Plugin.Src.Actions.SetTweens)

return function(instance)
	return function(store)
		local animator = Exporting.ExportAnimator(instance)
		if #animator.Tweens:GetChildren() == 0 then
			Exporting.ExportTween(instance, {}, "Default")
		end
		local tweens, firstTag = Exporting.GetTweensForAnimator(animator)
		store:dispatch(SetCurrentInstance(instance))
		store:dispatch(SetTweens(tweens))
		local firstKey, firstValue = next(tweens)
		if firstTag and tweens[firstTag] then --Previous tween was being worked on, return to it
			store:dispatch(SetCurrentTable(tweens[firstTag]))
			store:dispatch(SetCurrentTween(firstTag))
		elseif firstKey ~= nil then --Fallback if no previous saved tween
			store:dispatch(SetCurrentTable(firstValue))
			store:dispatch(SetCurrentTween(firstKey))
			Exporting.TagAnimatorWithKey(animator, firstKey)
		end
	end
end