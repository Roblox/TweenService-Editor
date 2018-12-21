local Plugin = script.Parent.Parent.Parent
local CollectionService = game:GetService("CollectionService")

local WriteTween = require(Plugin.Src.Util.WriteTween)

local INCLUDES_TAG = "Instance(TweenSequenceUtils)"
local ANIMATOR_TAG = "Instance(Animator)"

local Cryo = require(Plugin.Cryo)

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
	local current = instance
	while current.Parent do
		local child = current:FindFirstChild("Animator")
		if child and CollectionService:HasTag(child, ANIMATOR_TAG) then
			return child
		end
		current = current.Parent
	end
	return nil
end

function Exporting.ExportAnimator(instance)
	local animator = Exporting.GetAnimator(instance)
	if animator == nil then
		local newAnimator = Plugin.Src.Animator.Animator:Clone()
		CollectionService:AddTag(newAnimator, ANIMATOR_TAG)
		newAnimator.Parent = instance
		local tweens = Instance.new("Folder", newAnimator)
		tweens.Name = "Tweens"
		return newAnimator
	else
		return animator
	end
end

function Exporting.GetTweensForAnimator(animator)
	local tweens = {}
	local modules = animator.Tweens:GetChildren()
	for _, mod in pairs(modules) do
		tweens = Cryo.Dictionary.join(tweens, {
			[mod.Name] = require(mod),
		})
	end
	local firstTween
	local tags = CollectionService:GetTags(animator.Tweens)
	if #tags == 1 then
		firstTween = tags[1]
	end
	return tweens, firstTween
end

function Exporting.TagAnimatorWithKey(animator, key)
	local tags = CollectionService:GetTags(animator.Tweens)
	for _, tag in pairs(tags) do
		CollectionService:RemoveTag(animator.Tweens, tag)
	end
	CollectionService:AddTag(animator.Tweens, key)
end

function Exporting.ExportTween(tweenInfo, name, parent)
	local tween = WriteTween(tweenInfo, name)
	tween.Parent = parent
end

function Exporting.SaveAll(root, tweens)
	local animator = Exporting.ExportAnimator(root)
	animator.Tweens:ClearAllChildren()
	for name, tween in pairs(tweens) do
		Exporting.ExportTween(tween, name, animator.Tweens)
	end
end

function Exporting.DeleteAll(root)
	local animator = Exporting.GetAnimator(root)
	if animator then
		animator:Destroy()
	end
end

return Exporting