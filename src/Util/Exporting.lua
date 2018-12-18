local Plugin = script.Parent.Parent.Parent
local CollectionService = game:GetService("CollectionService")

local WriteTween = Plugin.Src.Util.WriteTween

local INCLUDES_TAG = "Instance(TweenSequenceUtils)"
local ANIMATOR_TAG = "Instance(Animator)"

local Exporting = {}

function Exporting.ExportIncludes()
	local TweenSequenceUtils = CollectionService:GetTagged(INCLUDES_TAG)
	if #TweenSequenceUtils == 0 then
		local newIncludes = Plugin.Src.TweenSequenceIncludes:Clone()
		CollectionService:AddTag(newIncludes, INCLUDES_TAG)
		newIncludes.Parent = game.ReplicatedStorage
	end
end

function Exporting.GetAnimator(instance)
	for _, child in pairs(instance:GetChildren()) do
		if CollectionService:HasTag(child, ANIMATOR_TAG) then
			return child
		end
	end
end

function Exporting.ExportAnimator(instance)
	local animator = Exporting.GetAnimator(instance)
	if animator == nil then
		local newAnimator = Plugin.Src.Animator.Animator:Clone()
		CollectionService:AddTag(newAnimator, ANIMATOR_TAG)
		newAnimator.Parent = instance
		local tweens = Instance.new("Folder", instance)
		tweens.Name = "Tweens"
		return newAnimator
	else
		return animator
	end
end

function Exporting.ExportTween(instance, tweenInfo, name)
	local animator = Exporting.ExportAnimator(instance)
	local tweens = animator.Tweens
	local tween = WriteTween(tweenInfo, name)
	tween.Parent = tweens
end

return Exporting