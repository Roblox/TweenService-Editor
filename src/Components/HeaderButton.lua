local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)
local Tooltip = require(Plugin.Src.Components.Tooltip)

local TOOLTIP_OFFSET = UDim2.new(0, 10, 0, 38)

local HeaderButton = Roact.PureComponent:extend("HeaderButton")

function HeaderButton:init()
	self.state = {
		Hovering = false,
	}

	self.mouseEnter = function()
		self:mouseHoverChanged(true)
	end

	self.mouseLeave = function()
		self:mouseHoverChanged(false)
	end
end

function HeaderButton:mouseHoverChanged(hovering)
	--getMouse(self).setHoverIcon("PointingHand", hovering)
	self:setState({
		Hovering = hovering,
	})
end

function HeaderButton:render()
	return withTheme(function(theme)
		local hovering = self.state.Hovering

		return Roact.createElement("TextButton", {
			Size = UDim2.new(0, self.props.Width or 20, 0, Constants.HEADER_HEIGHT - 4),
			BorderSizePixel = 1,
			Text = self.props.Text,
			Font = Enum.Font.Gotham,
			LayoutOrder = self.props.LayoutOrder or 0,
			TextSize = 14,

			TextColor3 = theme.headerButton.text,
			BackgroundColor3 = theme.headerButton.background,
			BorderColor3 = self.props.Highlight and theme.headerButton.highlight or theme.headerButton.border,

			ZIndex = 5,

			[Roact.Event.Activated] = self.props.OnClick,
			[Roact.Event.MouseEnter] = self.mouseEnter,
			[Roact.Event.MouseLeave] = self.mouseLeave,
		}, {
			Tooltip = self.props.Tooltip and Roact.createElement(Tooltip, {
				Position = TOOLTIP_OFFSET,
				AnchorPoint = Vector2.new(0, 0.5),
				Text = self.props.Tooltip,
				Active = hovering,
			})
		})
	end)
end

return HeaderButton
