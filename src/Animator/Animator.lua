--[[
	TweenSequence Editor Animator
	Created by ZeroIndex

	Usage:
		Initialize by requiring this module:
			animator = require(instance.Animator)

		Play the tween named TrackName:
			animator.TrackName:Play()

		Stop the tween named TrackName:
			animator.TrackName:Stop()

		Loop the tween named TrackName twice:
			animator.TrackName:Loop(2)

		Loop the tween named TrackName indefinitely until stopped:
			animator.TrackName:Loop()

		Connect a function named doneFunc to the end of the tween named TrackName:
			animator.TrackName.DonePlaying.Event:Connect(doneFunc)

		Stop all tweens for this instance:
			animator.StopAll()
]]

local CollectionService = game:GetService("CollectionService")
local TweenSequenceUtils = CollectionService:GetTagged("Instance(TweenSequenceUtils)")[1]
local AnimatorInterface = require(TweenSequenceUtils.AnimatorInterface)

local Animator = {}
local tweens = script:WaitForChild("Tweens")

local function init()
	local root = script.Parent

	for _, tween in pairs(tweens:GetChildren()) do
		local tweenTable = require(tween)
		Animator[tween.Name] = AnimatorInterface.new(root, tweenTable)
	end

	Animator.StopAll = function()
		for _, animation in pairs(Animator) do
			if type(animation) == "table" then
				animation:Stop()
			end
		end
	end

	return Animator
end

return init()
