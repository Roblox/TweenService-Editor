--[[
	Initializes a TweenSequence at the given root instance.
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)

local Exporting = require(Plugin.Src.Util.Exporting)
local SetCurrentInstance = require(Plugin.Src.Actions.SetCurrentInstance)
local SetCurrentTween = require(Plugin.Src.Actions.SetCurrentTween)
local SetExpandedItems = require(Plugin.Src.Actions.SetExpandedItems)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local visitDescendants = require(Plugin.Src.Util.visitDescendants)
local PathUtils = require(Plugin.Src.Util.PathUtils)

return function(instance)
	return function(store)
		local animator = Exporting.ExportAnimator(instance)
		if #animator.Tweens:GetChildren() == 0 then
			Exporting.ExportTween(instance, {}, "Default")
		end

		local tweens, firstTag = Exporting.GetTweensForAnimator(animator)
		store:dispatch(SetCurrentInstance(instance))
		store:dispatch(SetTweens(tweens))
		local firstKey = next(tweens)

		if firstTag and tweens[firstTag] then --Previous tween was being worked on, return to it
			store:dispatch(SetCurrentTween(firstTag))
		elseif firstKey ~= nil then --Fallback if no previous saved tween
			store:dispatch(SetCurrentTween(firstKey))
			Exporting.TagAnimatorWithKey(animator, firstKey)
		end

		local expandedItems = {}
		visitDescendants(instance, function(descendant)
			expandedItems = Cryo.Dictionary.join(expandedItems, {
				[PathUtils.RelativePath(instance, descendant)] = false,
			})
		end)
		store:dispatch(SetExpandedItems(expandedItems))
	end
end