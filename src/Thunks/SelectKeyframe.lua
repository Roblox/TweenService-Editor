--[[
	Selects a keyframe
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetSelectedKeyframe = require(Plugin.Src.Actions.SetSelectedKeyframe)
local SetPlayhead = require(Plugin.Src.Actions.SetPlayhead)

return function(path, prop, index)
	return function(store)
		if path == nil or prop == nil or index == nil then
			store:dispatch(SetSelectedKeyframe(Cryo.None))
			return
		end

		local tweens = store:getState().Tweens.Tweens
		local currentTween = store:getState().Tweens.CurrentTween
		local tweenTable = tweens[currentTween]

		if not tweenTable then
			return
		end

		store:dispatch(SetSelectedKeyframe({
			Path = path,
			Prop = prop,
			Index = index,
		}))

		if index > 0 then
			if tweenTable[path] and tweenTable[path][prop] then
				local oldKeyframes = tweenTable[path][prop].Keyframes
				store:dispatch(SetPlayhead(oldKeyframes[index].Time))
			end
		else
			store:dispatch(SetPlayhead(0))
		end
	end
end