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
