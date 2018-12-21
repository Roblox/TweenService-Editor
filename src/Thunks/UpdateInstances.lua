--[[
	Updates the instance properties from the editor.
	TODO: Confirmation popup
]]

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
			warn("Could not find descendant along path:", path)
		end
		func(instance, props)
	end
end

local function Lerp(val1, val2, alpha)
	local valType = typeof(val1)
	if valType == "bool" then
		return val1
	elseif valType == "number" then
		return val1 + ((val2 - val1) * alpha)
	else
		return val1:Lerp(val2, alpha)
	end
end

return function()
	return function(store)
		local state = store:getState()
		local tweens = state.Tweens.Tweens
		local currentTween = state.Tweens.CurrentTween
		local tweenTable = tweens[currentTween]
		local currentInstance = state.Status.CurrentInstance
		local time = state.Status.Playhead

		VisitAllInstances(currentInstance, tweenTable, function(instance, props)
			for name, values in pairs(props) do
				if time == 0 then
					instance[name] = values.InitialValue
				else
					local lastValue = values.InitialValue
					local lastTime = 0
					for _, keyframe in pairs(values.Keyframes) do
						if keyframe.Time == time then
							instance[name] = keyframe.Value
							break
						elseif keyframe.Time > time then
							local alpha = (time - lastTime) / (keyframe.Time - lastTime)
							instance[name] = Lerp(lastValue, keyframe.Value, alpha)
							break
						else
							lastValue = keyframe.Value
							lastTime = keyframe.Time
						end
					end
					if lastTime == 0 then
						local alpha = (time - lastTime) / (values.Keyframes[1].Time - lastTime)
						instance[name] = Lerp(lastValue, values.Keyframes[1].Value, alpha)
					end
				end
			end
		end)
	end
end