--[[
	Adds a new tween to be worked on
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SetCurrentTween = require(Plugin.Src.Thunks.SetCurrentTween)

return function()
	return function(store)
		local tweens = store:getState().Tweens.Tweens

		local newTween = "NewTween"
		local i = 1
		while tweens[newTween] ~= nil do
			newTween = string.format("NewTween%i", i)
			i = i + 1
		end

		tweens = Cryo.Dictionary.join(tweens, {
			[newTween] = {},
		})

		store:dispatch(SetTweens(tweens))
		store:dispatch(SetCurrentTween(newTween))
	end
end