--[[
	Changes the Tween table if a descendant was renamed or moved
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SetInstanceStates = require(Plugin.Src.Actions.SetInstanceStates)
local PathUtils = require(Plugin.Src.Util.PathUtils)
local fixCollisions = require(Plugin.Src.Util.fixCollisions)

local function fixIfInvalid(str)
    return str:gsub("([^%w])", "")
end

return function(oldPath, newPath, instance, root)
	return function(store)
		if instance == nil or instance.Parent == nil then
			return oldPath
		end
		local validName, shouldReturn = fixIfInvalid(instance.Name)
		if shouldReturn > 0 then
			instance.Name = validName
			return
		end
		local id = instance:GetDebugId()

		local tweens = store:getState().Tweens.Tweens
		local instanceStates = store:getState().Status.InstanceStates

		newPath = fixCollisions(instance, root, newPath)

		for name, tween in pairs(tweens) do
			for key, props in pairs(tween) do
				if PathUtils.Contains(key, oldPath) then
					local fixedPath = PathUtils.Replace(key, oldPath, newPath)
					tweens = Cryo.Dictionary.join(tweens, {
						[name] = Cryo.Dictionary.join(tweens[name], {
							[key] = Cryo.None,
							[fixedPath] = props,
						})
					})
					break
				end
			end
		end

		if instanceStates[id] then
			instanceStates = Cryo.Dictionary.join(instanceStates, {
				[id] = Cryo.Dictionary.join(instanceStates[id], {
					Name = instance.Name,
				})
			})
		end

		store:dispatch(SetInstanceStates(instanceStates))
		store:dispatch(SetTweens(tweens))

		return newPath
	end
end