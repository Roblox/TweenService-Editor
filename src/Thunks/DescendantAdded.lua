--[[
	Changes the Tween table if a descendant was added
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetInstanceStates = require(Plugin.Src.Actions.SetInstanceStates)
local PathUtils = require(Plugin.Src.Util.PathUtils)
local fixCollisions = require(Plugin.Src.Util.fixCollisions)

return function(instance, root, id)
	return function(store)
		local path = PathUtils.RelativePath(root, instance)
		local instanceStates = store:getState().Status.InstanceStates

		fixCollisions(instance, root, path)

		if instanceStates[id] == nil then
			instanceStates = Cryo.Dictionary.join(instanceStates, {
				[id] = {
					Expanded = true,
					Name = instance.Name,
					SubscribedProps = {},
				},
			})
		end

		store:dispatch(SetInstanceStates(instanceStates))
	end
end