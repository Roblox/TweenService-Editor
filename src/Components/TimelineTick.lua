--[[
	Props:
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local TimelineTick = Roact.PureComponent:extend("TimelineTick")

local function closeTo(num, otherNum)
	return math.abs(num - otherNum) < 0.01
end

function TimelineTick:render()
	return withTheme(function(theme)
		local time = self.props.Time
		local scale = self.props.Scale
		local playhead = self.props.Playhead
		local decimal = time - math.floor(time)
		local show = scale > 35 or playhead
			or closeTo(decimal, 0)
			or closeTo(decimal, 0.5)

		return Roact.createElement("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			BorderSizePixel = 1,
			BorderColor3 = playhead and theme.playhead or theme.timeline.tick,
			LayoutOrder = self.props.LayoutOrder,
			ZIndex = playhead and 5 or 3,
		}, {
			Label = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0),
				Size = UDim2.new(0, 25, 0, 20),
				BackgroundColor3 = playhead and theme.playhead or theme.timeline.background,
				BorderSizePixel = 0,
				TextColor3 = playhead and theme.white or theme.dimmedText,
				Text = show and time or "",
				Font = playhead and Enum.Font.GothamBold or Enum.Font.Gotham,
				TextSize = 12,
				ZIndex = playhead and 5 or 3,
			})
		})
	end)
end

return TimelineTick
