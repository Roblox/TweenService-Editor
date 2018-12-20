--[[
	Props:
		bool LighterColor = Whether to display this item with a lighter color
		LayoutOrder
		Indentation
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local ListItem = Roact.PureComponent:extend("ListItem")

function ListItem:render()
	local light = self.props.LighterColor
	local color = self.props.Color
	local indentation = self.props.Indentation or 0
	local selected = self.props.Selected

	return withTheme(function(theme)
		local backgroundColor
		if selected then
			backgroundColor = theme.listItem.selected
		else
			backgroundColor = color or (light and theme.listItem.light or theme.listItem.dark)
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, Constants.ITEM_HEIGHT),
			BackgroundColor3 = backgroundColor,
			BorderSizePixel = color == nil and 1 or 0,
			BorderColor3 = theme.header.border,
			LayoutOrder = self.props.LayoutOrder,
			ZIndex = color == nil and 2 or 1,
		}, self.props[Roact.Children] and Cryo.Dictionary.join(self.props[Roact.Children], {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 5 + indentation * 5),
				PaddingRight = UDim.new(0, 5),
			})
		}))
	end)
end

return ListItem
