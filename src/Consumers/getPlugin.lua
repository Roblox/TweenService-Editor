local Plugin = script.Parent.Parent.Parent

local pluginKey = require(Plugin.Src.Keys.pluginKey)

return function(component)
	return component._context[pluginKey]
end