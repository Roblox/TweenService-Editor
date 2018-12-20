--[[
	A button with an assigned icon.

	Props:
		string IdleIcon
		string HoverIcon
		callback OnClick
]]

local TOOLTIP_OFFSET = UDim2.new(0, 5, 0, 5)

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
--local getMouse = require(Plugin.Src.Consumers.getMouse)
local Tooltip = require(Plugin.Src.Components.Tooltip)

local IconButton = Roact.PureComponent:extend("IconButton")

function IconButton:init()
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

function IconButton:mouseHoverChanged(hovering)
	--getMouse(self).setHoverIcon("PointingHand", hovering)
	self:setState({
		Hovering = hovering,
	})
end

function IconButton:render()
	local hovering = self.state.Hovering
	local icon = hovering and self.props.HoverIcon or self.props.IdleIcon

	return Roact.createElement("ImageButton", {
		Image = icon,
		ImageTransparency = hovering and 0 or 0.5,
		BackgroundTransparency = 1,
		Size = self.props.Size,
		ImageRectSize = self.props.ImageRectSize,
		ImageRectOffset = self.props.ImageRectOffset,
		AnchorPoint = self.props.AnchorPoint,
		Position = self.props.Position,
		ZIndex = self.props.ZIndex,

		[Roact.Event.Activated] = self.props.OnClick,
		[Roact.Event.MouseEnter] = self.mouseEnter,
		[Roact.Event.MouseLeave] = self.mouseLeave,
	}, {
		Tooltip = self.props.Tooltip and Roact.createElement(Tooltip, {
			Position = self.props.Position + TOOLTIP_OFFSET,
			AnchorPoint = Vector2.new(0, 0.5),
			Text = self.props.Tooltip,
			Active = hovering,
		})
	})
end

return IconButton
