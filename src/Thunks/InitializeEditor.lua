--[[
	Initializes a TweenSequence at the given root instance.
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)

local Exporting = require(Plugin.Src.Util.Exporting)
local SetCurrentInstance = require(Plugin.Src.Actions.SetCurrentInstance)
local SetCurrentTween = require(Plugin.Src.Actions.SetCurrentTween)
local SetInstanceStates = require(Plugin.Src.Actions.SetInstanceStates)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local visitDescendants = require(Plugin.Src.Util.visitDescendants)
local fixCollisions = require(Plugin.Src.Util.fixCollisions)
local SetDirty = require(Plugin.Src.Actions.SetDirty)
local SelectKeyframe = require(Plugin.Src.Thunks.SelectKeyframe)
local SetPlayhead = require(Plugin.Src.Actions.SetPlayhead)

return function(instance)
	return function(store)
		local animator = Exporting.ExportAnimator(instance)

		local tweens, firstTag
		if #animator.Tweens:GetChildren() == 0 then
			tweens = {NewTween = {}}
			firstTag = "NewTween"
		else
			tweens, firstTag = Exporting.GetTweensForAnimator(animator)
		end

		store:dispatch(SetCurrentInstance(instance))
		store:dispatch(SetTweens(tweens))
		local firstKey = next(tweens)

		if firstTag and tweens[firstTag] then --Previous tween was being worked on, return to it
			store:dispatch(SetCurrentTween(firstTag))
		elseif firstKey ~= nil then --Fallback if no previous saved tween
			store:dispatch(SetCurrentTween(firstKey))
			Exporting.TagAnimatorWithKey(animator, firstKey)
		end

		local instanceStates = {}
		visitDescendants(instance, function(descendant)
			fixCollisions(descendant, instance)
			instanceStates = Cryo.Dictionary.join(instanceStates, {
				[descendant:GetDebugId()] = {
					Expanded = true,
					Name = descendant.Name,
				}
			})
		end)

		if #animator.Tweens:GetChildren() == 0 then
			Exporting.SaveAll(instance, tweens)
		end

		store:dispatch(SetInstanceStates(instanceStates))
		store:dispatch(SelectKeyframe(nil))
		store:dispatch(SetPlayhead(0))
		store:dispatch(SetDirty(false))
	end
end