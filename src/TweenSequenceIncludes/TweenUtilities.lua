local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function Split(str)
	local names = {}

	for name in str:gmatch("[^.]+") do
		table.insert(names, name)
	end

	return names
end

local function FindFirstDescendant(root, path)
	local names = Split(path)
	if #names == 1 then
		return root
	else
		local current = root
		for i = 2, #names do
			current = current:FindFirstChild(names[i])
			if current == nil then
				return nil
			end
		end
		return current
	end
end

local function VisitAllInstances(root, tweenTable, func)
	for path, props in pairs(tweenTable) do
		local instance = FindFirstDescendant(root, path)
		if instance == nil then
			error("Could not find descendant along path:", path)
		end
		func(instance, props)
	end
end

-- Builds a set of runnable Tweens from a table of instances and values
local function BuildTweens(root, tweenTable)
	local tweens = {}

	VisitAllInstances(root, tweenTable, function(instance, props)
		for prop, values in pairs(props) do
			local keyframes = values.Keyframes
			local lastTime = 0
			for _, keyframe in ipairs(keyframes) do
				local tweenInfo = TweenInfo.new(keyframe.Time - lastTime,
					keyframe.EasingStyle,keyframe.EasingDirection, 0, false, 0)
				local propTable = {
					[prop] = keyframe.Value
				}
				local tween = TweenService:Create(instance, tweenInfo, propTable)
				table.insert(tweens, {
					Tween = tween,
					DelayTime = lastTime,
				})
				lastTime = keyframe.Time
			end
		end
	end)

	return tweens
end

local TweenUtilities = {}
TweenUtilities.__index = TweenUtilities

function TweenUtilities.new(root, tweenTable)
	local self = {
		running = false,
		root = root,
		tweenTable = tweenTable,
		tweens = BuildTweens(root, tweenTable),
	}
	setmetatable(self, TweenUtilities)
	return self
end

function TweenUtilities:ResetValues()
	VisitAllInstances(self.root, self.tweenTable, function(instance, props)
		for prop, values in pairs(props) do
			local initialValue = values.InitialValue
			instance[prop] = initialValue
		end
	end)
end

function TweenUtilities:PlayTweens(callback)
	if self.running then
		self:PauseTweens()
	end
	self.running = true

	local delayedTweens = {}
	for _, props in pairs(self.tweens) do
		local tween = props.Tween
		local delayTime = props.DelayTime
		if delayTime == 0 then
			tween:Play()
		else
			table.insert(delayedTweens, {
				Tween = tween,
				DelayTime = delayTime,
				Playing = false,
			})
		end
	end

	local heartbeatConnection
	local start = tick()
	local tweensDone = false
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local now = tick() - start
		if not self.running then
			self.running = false
			heartbeatConnection:Disconnect()
			if callback then
				callback()
			end
			return
		end
		if tweensDone then
			local allDone = true
			for _, props in pairs(delayedTweens) do
				local tween = props.Tween
				if tween.PlaybackState == Enum.PlaybackState.Playing then
					allDone = false
				end
			end
			if allDone then
				self.running = false
				heartbeatConnection:Disconnect()
				if callback then
					callback()
				end
				return
			end
		else
			local allPlaying = true
			for _, props in pairs(delayedTweens) do
				if not props.Playing then
					if now > props.DelayTime then
						props.Playing = true
						props.Tween:Play()
					else
						allPlaying = false
					end
				end
			end
			tweensDone = allPlaying
		end
	end)
end

function TweenUtilities:PauseTweens()
	self.running = false
	for _, props in pairs(self.tweens) do
		local tween = props.Tween
		tween:Cancel()
	end
end

return TweenUtilities
