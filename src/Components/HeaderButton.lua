local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local HeaderButton = Roact.PureComponent:extend("HeaderButton")

function HeaderButton:render()
	return withTheme(function(theme)
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
		})
	end)
end

return HeaderButton
