--[[
	Copy a keyframe to the clipboard.
]]

local Plugin = script.Parent.Parent.Parent
local SetClipboard = require(Plugin.Src.Actions.SetClipboard)

return function()
	return function(store)
		local tweens = store:getState().Tweens.Tweens
		local currentTween = store:getState().Tweens.CurrentTween
		local tweenTable = tweens[currentTween]
		local selectedKeyframe = store:getState().Status.SelectedKeyframe

		if not tweenTable or not selectedKeyframe then
			return
		end

		local path = selectedKeyframe.Path
		local prop = selectedKeyframe.Prop
		local index = selectedKeyframe.Index

		if tweenTable[path] and tweenTable[path][prop] then
			local oldKeyframes = tweenTable[path][prop].Keyframes
			local kf = oldKeyframes[index]

			if kf then
				store:dispatch(SetClipboard({
					Value = kf.Value,
					EasingDirection = kf.EasingDirection,
					EasingStyle = kf.EasingStyle,
					Path = path,
					Prop = prop,
				}))
			end
		end
	end
end