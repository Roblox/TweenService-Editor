--[[
	Appears when an instance has not been selected.

	Props:
		table Selection = The current game selection.
		function CreateNew = callback function for button clicked
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local ButtonBar = require(Plugin.Src.Components.ButtonBar)

local InstanceSelector = Roact.PureComponent:extend("InstanceSelector")

function InstanceSelector:render(props)
	local selection = self.props.Selection
	local text
	local canSelect = false
	if selection == nil then
		text = "Select an instance to begin animating."
	elseif #selection > 1 then
		text = "Please select only one instance."
	elseif #selection == 1 then
		canSelect = true
		text = selection[1]:GetFullName()
	else
		text = "Select an instance to begin animating."
	end

	return withTheme(function(theme)
		local canImport = self.props.CanImport
		local selectionDiffers = self.props.SelectionDiffers
		local buttons
		if canImport then
			buttons = {
				{Default = true, Name = "Import", Value = true, Active = canSelect},
			}
		else
			buttons = {
				{Default = true, Name = "Create", Value = true, Active = canSelect},
			}
		end
		if selectionDiffers then
			table.insert(buttons, {Default = false, Name = "Cancel", Value = false, Active = true})
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(0, 400, 0, 200),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BackgroundTransparency = 1,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 30),
				PaddingTop = UDim.new(0, 30),
			}),
			InstanceName = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Text = text,
				Font = Enum.Font.Gotham,
				TextSize = 16,
				TextColor3 = theme.mainText,
				Size = UDim2.new(1, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
			}),
			Buttons = Roact.createElement(ButtonBar, {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Buttons = buttons,
				ButtonClicked = self.props.CreateNew,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, 0),
			}),
		})
	end)
end

return InstanceSelector