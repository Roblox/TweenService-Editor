local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
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
		})
	end)
end

return Header
