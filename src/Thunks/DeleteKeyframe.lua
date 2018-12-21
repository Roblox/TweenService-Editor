--[[
	Removes a keyframe
	TODO: Confirmation popup
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)

local function keyframeExists(keyframes, playhead)
	for i, keyframe in ipairs(keyframes) do
		if keyframe.Time == playhead then
			return i
		end
	end
	return nil
end

return function(path, prop, time)
	return function(store)
		local tweens = store:getState().Tweens.Tweens
		local currentTween = store:getState().Tweens.CurrentTween
		local tweenTable = tweens[currentTween]

		if not tweenTable then
			return
		end

		if tweenTable[path] and tweenTable[path][prop] then
			local oldKeyframes = tweenTable[path][prop].Keyframes
			local index = keyframeExists(oldKeyframes, time)
			if index then
				local newKeyframes = Cryo.List.join(oldKeyframes, {})
				table.remove(newKeyframes, index)
				tweens = Cryo.Dictionary.join(tweens, {
					[currentTween] = Cryo.Dictionary.join(tweenTable, {
						[path] = Cryo.Dictionary.join(tweenTable[path], {
							[prop] = Cryo.Dictionary.join(tweenTable[path][prop], {
								Keyframes = newKeyframes,
							})
						})
					}),
				})
				store:dispatch(SetTweens(tweens))
			end
		end
	end
end