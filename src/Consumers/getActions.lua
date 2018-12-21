local Plugin = script.Parent.Parent.Parent

local actionKey = require(Plugin.Src.Keys.actionKey)

return function(component)
	return component._context[actionKey]
end