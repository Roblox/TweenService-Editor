local Plugin = script.Parent.Parent.Parent
local Action = require(Plugin.Src.Actions.Action)

return Action(script.Name, function(path)
	return {
		path = path,
	}
end)