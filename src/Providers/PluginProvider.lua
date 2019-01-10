local Plugin = script.Parent.Parent.Parent

local Roact = require(Plugin.Roact)

local pluginKey = require(Plugin.Src.Keys.pluginKey)

local PluginProvider = Roact.Component:extend("PluginProvider")

function PluginProvider:init()
	self._context[pluginKey] = self.props.plugin
end

function PluginProvider:render()
	return Roact.oneChild(self.props[Roact.Children])
end

return PluginProvider