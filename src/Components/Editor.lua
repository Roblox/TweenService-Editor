--[[
	Props:
		CurrentTable = The current tween table.
		CurrentInstance
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local Header = require(Plugin.Src.Components.Header)
local PropsList = require(Plugin.Src.Components.PropsList)

local Editor = Roact.PureComponent:extend("Editor")

function Editor:render()
	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			Header = Roact.createElement(Header, {
			}),
			Body = Roact.createElement("Frame", {
				BackgroundColor3 = theme.backgroundColor,
				BorderColor3 = theme.header.border,
				BorderSizePixel = 1,
				Size = UDim2.new(1, 0, 1, -Constants.HEADER_HEIGHT)
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 3)
				}),
				PropsList = Roact.createElement(PropsList, {
					CurrentTable = self.props.CurrentTable,
					CurrentInstance = self.props.CurrentInstance,
					Selection = self.props.Selection,
					ExpandedItems = self.props.ExpandedItems,
				}),
			}),
		})
	end)
end

return Editor
