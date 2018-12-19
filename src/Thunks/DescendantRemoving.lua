--[[
	Changes the Tween table if a descendant was removed
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SetInstanceStates = require(Plugin.Src.Actions.SetInstanceStates)
local PathUtils = require(Plugin.Src.Util.PathUtils)

return function(path, id)
	return function(store)
		local tweens = store:getState().Tweens.Tweens
		local instanceStates = store:getState().Status.InstanceStates

		for name, tween in pairs(tweens) do
			for key, _ in pairs(tween) do
				if PathUtils.Contains(key, path) then
					tweens = Cryo.Dictionary.join(tweens, {
						[name] = Cryo.Dictionary.join(tweens[name], {
							[key] = Cryo.None,
						})
					})
					break
				end
			end
		end

		if instanceStates[id] then
			instanceStates = Cryo.Dictionary.join(instanceStates, {
				[id] = Cryo.None,
			})
		end

		store:dispatch(SetInstanceStates(instanceStates))
		store:dispatch(SetTweens(tweens))
	end
end