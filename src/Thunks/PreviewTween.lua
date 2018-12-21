--[[
	Runs the current tween
]]

local RunService = game:GetService("RunService")

local Plugin = script.Parent.Parent.Parent
local SetIsPlaying = require(Plugin.Src.Actions.SetIsPlaying)
local AnimatorInterface = require(Plugin.Src.TweenSequenceIncludes.AnimatorInterface)

return function()
	return function(store)
		local currentTween = store:getState().Tweens.CurrentTween
		local tweens = store:getState().Tweens.Tweens
		local root = store:getState().Status.CurrentInstance

		local animator = AnimatorInterface.new(root, tweens[currentTween])

		store:dispatch(SetIsPlaying(true))

		RunService:Run()
		local playingConnection = nil
		playingConnection = animator.DonePlaying.Event:Connect(function()
			animator:Stop()
			RunService:Stop()
			playingConnection:Disconnect()
			store:dispatch(SetIsPlaying(false))
		end)

		animator:Play()
	end
end