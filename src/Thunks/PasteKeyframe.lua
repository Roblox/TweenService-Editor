--[[
	Paste a new keyframe from the clipboard.
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SelectKeyframe = require(Plugin.Src.Thunks.SelectKeyframe)
local UpdateInstances = require(Plugin.Src.Thunks.UpdateInstances)

local function keyframeExists(keyframes, playhead)
	for i, keyframe in ipairs(keyframes) do
		if keyframe.Time == playhead then
			return i
		end
	end
	return nil
end

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

return function()
	return function(store)
		local clipboard = store:getState().Status.Clipboard
		if clipboard == nil then
			return
		end

		local path = clipboard.Path
		local prop = clipboard.Prop
		local value = clipboard.Value

		local newSelectedIndex = nil

		local state = store:getState()
		local tweens = state.Tweens.Tweens
		local currentTween = state.Tweens.CurrentTween
		local tweenTable = tweens[currentTween]
		local playhead = state.Status.Playhead

		if tweenTable[path] then
			if tweenTable[path][prop] then
				if playhead == 0 then
					tweenTable = Cryo.Dictionary.join(tweenTable, {
						[path] = Cryo.Dictionary.join(tweenTable[path], {
							[prop] = Cryo.Dictionary.join(tweenTable[path][prop], {
								InitialValue = value,
							})
						})
					})
				else
					local oldKeyframes = tweenTable[path][prop].Keyframes
					local index = keyframeExists(oldKeyframes, playhead)
					local newKeyframes = Cryo.List.join(oldKeyframes, {})
					if index then
						--Keyframe already exists at this time for this value
						newKeyframes[index] = Cryo.Dictionary.join(oldKeyframes[index], {
							Value = value,
							EasingStyle = clipboard.EasingStyle,
							EasingDirection = clipboard.EasingDirection,
						})
						newSelectedIndex = index
					else
						--Make a new keyframe at this time for this value
						local index = getInsertIndex(oldKeyframes, playhead)
						table.insert(newKeyframes, index, {
							Value = value,
							Time = playhead,
							EasingStyle = clipboard.EasingStyle,
							EasingDirection = clipboard.EasingDirection,
						})
						newSelectedIndex = index
					end
					tweenTable = Cryo.Dictionary.join(tweenTable, {
						[path] = Cryo.Dictionary.join(tweenTable[path], {
							[prop] = Cryo.Dictionary.join(tweenTable[path][prop], {
								Keyframes = newKeyframes,
							})
						})
					})
				end
			end

			tweens = Cryo.Dictionary.join(tweens, {
				[currentTween] = tweenTable,
			})

			store:dispatch(SetTweens(tweens))

			if newSelectedIndex then
				store:dispatch(SelectKeyframe(path, prop, newSelectedIndex))
			else
				store:dispatch(UpdateInstances())
			end
		end
	end
end