--[[
	Sets the EasingStyle of a tween.
	TODO: Confirmation popup
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)

return function(style)
	return function(store)
		local tweens = store:getState().Tweens.Tweens
		local currentTween = store:getState().Tweens.CurrentTween
		local skf = store:getState().Status.SelectedKeyframe
		local tweenTable = tweens[currentTween]

		if not tweenTable or not skf then
			return
		end

		local oldKeyframes = tweenTable[skf.Path][skf.Prop].Keyframes

		local newKeyframes = Cryo.List.join(oldKeyframes, {})
		newKeyframes[skf.Index] = Cryo.Dictionary.join(oldKeyframes[skf.Index], {
			EasingStyle = Enum.EasingStyle[style],
		})

		tweenTable = Cryo.Dictionary.join(tweenTable, {
			[skf.Path] = Cryo.Dictionary.join(tweenTable[skf.Path], {
				[skf.Prop] = Cryo.Dictionary.join(tweenTable[skf.Path][skf.Prop], {
					Keyframes = newKeyframes,
				})
			})
		})

		tweens = Cryo.Dictionary.join(tweens, {
			[currentTween] = tweenTable,
		})

		store:dispatch(SetTweens(tweens))
	end
end