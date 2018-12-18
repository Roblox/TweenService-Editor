--[[
	Appears when an instance has not been selected.

	Props:
		table Selection = The current game selection.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local withTheme = require(Plugin.Src.Consumers.withTheme)

local InstanceSelector = Roact.PureComponent:extend("InstanceSelector")

function InstanceSelector:render(props)
	local selection = self.props.Selection
	local text
	if selection == nil then
		text = "Select a root instance to begin animating."
	elseif #selection > 1 then
		text = "Please select only one instance to use as a root."
	elseif #selection == 1 then
		text = selection[1]:GetFullName()
	else
		text = "Select a root instance to begin animating."
	end

	return withTheme(function(theme)
		return Roact.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = theme.backgroundColor,
			Text = text,
			TextColor3 = theme.mainText,
		})
	end)
end

return InstanceSelector