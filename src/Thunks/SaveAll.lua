--[[
	Export all tweens to the Animator attached to this instance
]]

local Plugin = script.Parent.Parent.Parent
local Exporting = require(Plugin.Src.Util.Exporting)
local SetDirty = require(Plugin.Src.Actions.SetDirty)

return function()
	return function(store)
		local tweens = store:getState().Tweens.Tweens
		local currentTween = store:getState().Tweens.CurrentTween
		local root = store:getState().Status.CurrentInstance

		if tweens and root then
			Exporting.SaveAll(root, tweens)
			Exporting.TagAnimatorWithKey(root.Animator, currentTween)
		end

		store:dispatch(SetDirty(false))
	end
end