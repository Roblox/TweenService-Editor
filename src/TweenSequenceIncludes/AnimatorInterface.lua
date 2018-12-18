local TweenUtilities = require(script.Parent.TweenUtilities)

local Animator = {}
Animator.__index = Animator

local function checkNil(val)
	if val == nil then
		error("Expected ':', not '.', when calling this function.")
	end
end

function Animator.new(root, tweenTable)
	local self = {
		playing = false,
		DonePlaying = Instance.new("BindableEvent"),
		tweenUtils = TweenUtilities.new(root, tweenTable)
	}
	setmetatable(self, Animator)
	return self
end

function Animator:Play()
	checkNil(self)
	self.playing = true
	self.tweenUtils:ResetValues()
	self.tweenUtils:PlayTweens(function()
		self:OnDonePlaying()
	end)
end

function Animator:Loop(cycles)
	checkNil(self)
	if cycles ~= nil and cycles == 0 then
		self:OnDonePlaying()
		return
	end
	self.playing = true
	self.tweenUtils:ResetValues()
	self.tweenUtils:PlayTweens(function()
		if self.playing then
			self:Loop(cycles and cycles - 1)
		else
			self:OnDonePlaying()
		end
	end)
end

function Animator:Stop()
	checkNil(self)
	self.playing = false
	self.tweenUtils:PauseTweens()
	self.tweenUtils:ResetValues()
end

function Animator:OnDonePlaying()
	self.DonePlaying:Fire()
end

return Animator
