local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local function HeaderDropdownEntry(props)
	return withTheme(function(theme)
		return Roact.createElement("TextButton", {
			Size = UDim2.new(0, props.Width or 20, 0, Constants.HEADER_HEIGHT - 4),
			Text = "  " .. props.Text,
			Font = props.Current and Enum.Font.GothamBold or Enum.Font.Gotham,
			LayoutOrder = props.LayoutOrder or 0,
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,

			TextColor3 = theme.headerButton.text,
			BackgroundColor3 = theme.headerButton.background,
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Left,

			ZIndex = 10,

			[Roact.Event.Activated] = function()
				props.OnClick(props.Text)
			end,
		})
	end)
end

return HeaderDropdownEntry
