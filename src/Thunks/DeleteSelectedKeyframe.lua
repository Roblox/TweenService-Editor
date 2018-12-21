--[[
	Removes the selected keyframe
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local DeleteKeyframe = require(Plugin.Src.Thunks.DeleteKeyframe)
local SetSelectedKeyframe = require(Plugin.Src.Actions.SetSelectedKeyframe)

return function()
	return function(store)
		local selected = store:getState().Status.SelectedKeyframe
		if selected == nil or selected.Index == 0 then
			return
		end

		local tweens = store:getState().Tweens.Tweens
		local currentTween = store:getState().Tweens.CurrentTween
		local tweenTable = tweens[currentTween]

		if not tweenTable then
			return
		end

		local path = selected.Path
		local prop = selected.Prop
		local index = selected.Index

		if tweenTable[path] and tweenTable[path][prop] then
			local oldKeyframes = tweenTable[path][prop].Keyframes
			store:dispatch(DeleteKeyframe(path, prop, oldKeyframes[index].Time))
			store:dispatch(SetSelectedKeyframe(Cryo.None))
		end
	end
end