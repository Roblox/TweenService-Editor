--[[
	Sets the current edit tween
]]

local Plugin = script.Parent.Parent.Parent
local SetCurrentTween = require(Plugin.Src.Actions.SetCurrentTween)
local SelectKeyframe = require(Plugin.Src.Thunks.SelectKeyframe)
local SetPlayhead = require(Plugin.Src.Actions.SetPlayhead)
local Exporting = require(Plugin.Src.Util.Exporting)

return function(tween)
	return function(store)
		store:dispatch(SetCurrentTween(tween))
		store:dispatch(SelectKeyframe(nil))
		store:dispatch(SetPlayhead(0))

		local root = store:getState().Status.CurrentInstance

		if root then
			Exporting.TagAnimatorWithKey(root.Animator, tween)
		end
	end
end