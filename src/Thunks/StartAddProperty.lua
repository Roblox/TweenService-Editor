--[[
	Adds a property to the current Tween table
]]

local Plugin = script.Parent.Parent.Parent
local PathUtils = require(Plugin.Src.Util.PathUtils)
local SetPolling = require(Plugin.Src.Actions.SetPolling)

return function(instance, root)
	return function(store)
		local path = PathUtils.RelativePath(root, instance)
		store:dispatch(SetPolling({
			Path = path,
			Instance = instance,
			Root = root,
		}))
	end
end