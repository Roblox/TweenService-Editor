--[[
	The top level container of the TweenService Editor window.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local InstanceSelector = require(Plugin.Src.Components.InstanceSelector)

local MainView = Roact.PureComponent:extend("MainView")

function MainView:init()
	self.state = {
		Selection = game.Selection:Get(),
	}
	self.selectionChanged = function(selection)
		self:setState({
			Selection = game.Selection:Get(),
		})
	end

	self.selectionConnection = game.Selection.SelectionChanged:Connect(self.selectionChanged)
end

function MainView:willUnmount()
	self.selectionConnection:Disconnect()
end

function MainView:render(props)
	local currentInstance = self.props.CurrentInstance
	local selection = self.state.Selection

	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = theme.backgroundColor,
		}, {
			Selector = (currentInstance == nil) and Roact.createElement(InstanceSelector, {
				Selection = selection,
			}),
		})
	end)
end

MainView = RoactRodux.connect(
	function(state, props)
		if not state then return end
		return {
			CurrentInstance = state.Status.CurrentInstance,
		}
	end
)(MainView)

return MainView