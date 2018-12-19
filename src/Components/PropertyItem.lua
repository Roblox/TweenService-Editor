--[[
	Props:
		bool LighterColor = Whether to display this item with a lighter color
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local ListItem = require(Plugin.Src.Components.ListItem)

local PropertyItem = Roact.PureComponent:extend("PropertyItem")

function PropertyItem:render()
	local property = self.props.Property

	return withTheme(function(theme)
		return Roact.createElement(ListItem, {
			LighterColor = self.props.LighterColor,
			LayoutOrder = self.props.LayoutOrder,
			Indentation = self.props.Indentation,
		}, {
			Name = Roact.createElement("TextLabel", {
				TextColor3 = theme.listItem.text,
				BackgroundTransparency = 1,
				Text = property,
				Size = UDim2.new(1, -Constants.ITEM_HEIGHT, 1, 0),
				Position = UDim2.new(0, 20, 0, 0),
				Font = Enum.Font.Gotham,

				TextSize = Constants.ITEM_TEXT_SIZE,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 2,
			}),
		})
	end)
end

return PropertyItem
