--[[
	Props:
		Position
		Size
		Active
		Text
]]

local TextService = game:GetService("TextService")

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local Tooltip = Roact.PureComponent:extend("Tooltip")

function Tooltip:render()
	local active = self.props.Active
	local text = self.props.Text
	local autoScale = TextService:GetTextSize(
		text, 14, Enum.Font.Gotham, Vector2.new(0, 200)
	)

	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Visible = active,
			Size = UDim2.new(0, autoScale.X + 10, 0, autoScale.Y + 10),
			Position = self.props.Position,
			AnchorPoint = self.props.AnchorPoint,
			BackgroundColor3 = theme.tooltip.background,
			BorderColor3 = theme.tooltip.border,
			BorderSizePixel = 3,
			ZIndex = 20,
		}, {
			UIPadding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
			}),
			TextLabel = Roact.createElement("TextLabel", {
				Text = text,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextWrapped = true,
				TextColor3 = theme.tooltip.text,
				ZIndex = 21,
			}),
		})
	end)
end

return Tooltip
