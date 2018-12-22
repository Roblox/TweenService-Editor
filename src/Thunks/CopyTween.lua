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
		local currentTween = store:getState().Tweens.CurrentTween
		local currentTable = Cryo.Dictionary.join(tweens[currentTween], {})

		local newTween = currentTween
		local i = 1
		while tweens[newTween] ~= nil do
			newTween = currentTween .. i
			i = i + 1
		end

		tweens = Cryo.Dictionary.join(tweens, {
			[newTween] = currentTable,
		})

		store:dispatch(SetTweens(tweens))
		store:dispatch(SetCurrentTween(newTween))
	end
end