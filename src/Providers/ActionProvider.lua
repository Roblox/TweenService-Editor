local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Roact)

local actionKey = require(Plugin.Src.Keys.actionKey)

local ActionProvider = Roact.Component:extend("ActionProvider")

function ActionProvider:init()
	self._context[actionKey] = self.props.actions
end

function ActionProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return ActionProvider