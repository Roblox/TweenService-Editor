--[[
	Move a keyframe from one time to another.
	TODO: Confirmation popup
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SelectKeyframe = require(Plugin.Src.Thunks.SelectKeyframe)

--Last keyframe needs to adjust to end at this keyframe
--This keyframe needs to end at the next keyframe
local function getInsertIndex(keyframes, playhead)
	local i = 1
	for _, keyframe in ipairs(keyframes) do
		if keyframe.Time > playhead then
			return i
		end
		i = i + 1
	end
	return i
end

local function keyframeExists(keyframes, playhead)
	for i, keyframe in ipairs(keyframes) do
		if keyframe.Time == playhead then
			return i
		end
	end
	return nil
end

return function(path, prop, index, newTime)
	return function(store)
		local tweens = store:getState().Tweens.Tweens
		local currentTween = store:getState().Tweens.CurrentTween
		local tweenTable = tweens[currentTween]

		if not tweenTable then
			return
		end

		if tweenTable[path] and tweenTable[path][prop] then
			local oldKeyframes = tweenTable[path][prop].Keyframes

			if keyframeExists(oldKeyframes, newTime) or newTime == 0 then
				return --Don't overlap keyframes
			end

			local oldKeyframe = oldKeyframes[index]
			local newKeyframe = Cryo.Dictionary.join(oldKeyframe, {
				Time = newTime,
			})

			local newKeyframes = Cryo.List.join(oldKeyframes, {})
			table.remove(newKeyframes, index)
			--Make a new keyframe at this time for this value
			local newIndex = getInsertIndex(newKeyframes, newTime)
			table.insert(newKeyframes, newIndex, newKeyframe)

			tweenTable = Cryo.Dictionary.join(tweenTable, {
				[path] = Cryo.Dictionary.join(tweenTable[path], {
					[prop] = Cryo.Dictionary.join(tweenTable[path][prop], {
						Keyframes = newKeyframes,
					})
				})
			})

			tweens = Cryo.Dictionary.join(tweens, {
				[currentTween] = tweenTable,
			})

			store:dispatch(SetTweens(tweens))

			if newIndex then
				store:dispatch(SelectKeyframe(path, prop, newIndex))
			end
		end
	end
end