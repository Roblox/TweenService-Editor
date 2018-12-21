--[[
	Fires when a property that was being watched changed its value.
	TODO: Check if recording?
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SelectKeyframe = require(Plugin.Src.Thunks.SelectKeyframe)

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

local function isValidProperty(prop)
	local valType = typeof(prop)
	return valType == "number" or
		valType == "bool" or
		valType == "CFrame" or
		valType == "Vector3" or
		valType == "Vector3int16" or
		valType == "Vector2" or
		valType == "Rect" or
		valType == "Color3" or
		valType == "UDim" or
		valType == "UDim2" or
		valType == "UDim2"
end

return function(path, prop, instance)
	return function(store)
		if store:getState().Status.HasFocus or store:getState().Status.IsPlaying then
			--The plugin itself has focus. Most likely during playback.
			return
		end

		if instance == nil or prop == nil or prop == "" then
			return
		end

		if instance:FindFirstChild(prop) then
			return
		end

		local value
		if not pcall(function()
			value = instance[prop]
		end) then
			return
		end

		if not isValidProperty(value) then
			return
		end

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
						})
						newSelectedIndex = index
					else
						--Make a new keyframe at this time for this value
						local index = getInsertIndex(oldKeyframes, playhead)
						table.insert(newKeyframes, index, {
							Value = value,
							Time = playhead,
							EasingStyle = Enum.EasingStyle.Linear,
							EasingDirection = Enum.EasingDirection.Out,
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
			end
		end
	end
end