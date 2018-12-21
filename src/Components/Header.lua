local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local HeaderButton = require(Plugin.Src.Components.HeaderButton)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local Header = Roact.PureComponent:extend("Header")

function Header:render()
	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, Constants.HEADER_HEIGHT),
			BackgroundColor3 = theme.header.background,
			BorderColor3 = theme.header.border,
			BorderSizePixel = 1,
			ZIndex = 5,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 10),
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
			}),
			SaveAll = Roact.createElement(HeaderButton, {
				Width = 80,
				Text = "Save All",
				LayoutOrder = 1,
				Highlight = self.props.Dirty,
				OnClick = function()
					self.props.ButtonPressed("SaveAll")
				end,
			}),
			Reload = Roact.createElement(HeaderButton, {
				Width = 80,
				Text = "Reload",
				LayoutOrder = 2,
				OnClick = function()
					self.props.ButtonPressed("Reload")
				end,
			}),
		})
	end)
end

Header = RoactRodux.connect(
	function(state, props)
		if not state then return end
		return {
			Dirty = state.Status.Dirty,
		}
	end
)(Header)

return Header
