local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)
local Tooltip = require(Plugin.Src.Components.Tooltip)

local TOOLTIP_OFFSET = UDim2.new(0, 10, 0, 38)

local HeaderImageButton = Roact.PureComponent:extend("HeaderImageButton")

function HeaderImageButton:init()
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

function HeaderImageButton:mouseHoverChanged(hovering)
	--getMouse(self).setHoverIcon("PointingHand", hovering)
	self:setState({
		Hovering = hovering,
	})
end

function HeaderImageButton:render()
	return withTheme(function(theme)
		local hovering = self.state.Hovering

		return Roact.createElement("ImageButton", {
			Size = UDim2.new(0, self.props.Width or Constants.HEADER_HEIGHT - 4, 0, Constants.HEADER_HEIGHT - 4),
			BorderSizePixel = 1,
			LayoutOrder = self.props.LayoutOrder or 0,
			ImageTransparency = 1,

			BackgroundColor3 = theme.headerButton.background,
			BorderColor3 = self.props.Highlight and theme.headerButton.highlight or theme.headerButton.border,

			ZIndex = 5,

			[Roact.Event.Activated] = self.props.OnClick,
			[Roact.Event.MouseEnter] = self.mouseEnter,
			[Roact.Event.MouseLeave] = self.mouseLeave,
		}, {
			Image = Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -6, 1, -6),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = self.props.Image,
				ZIndex = 5,
			}),
			Tooltip = self.props.Tooltip and Roact.createElement(Tooltip, {
				Position = TOOLTIP_OFFSET,
				AnchorPoint = Vector2.new(0, 0.5),
				Text = self.props.Tooltip,
				Active = hovering,
			})
		})
	end)
end

return HeaderImageButton
