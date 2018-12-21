--[[
	Props:
		Text
		Header
		Buttons
]]

local DRAWER_HEIGHT = 80
local HEADER_HEIGHT = 30

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local RoundTextBox = require(Plugin.Src.Components.RoundTextBox)
local ButtonBar = require(Plugin.Src.Components.ButtonBar)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local BottomDrawer = Roact.PureComponent:extend("BottomDrawer")

function BottomDrawer:init()
	self.textCompleted = function()
		self.props.Submitted(self.text)
	end

	self.text = ""
end

function BottomDrawer:render()
	return withTheme(function(theme)
		local buttons = {
			{Default = true, Name = self.props.ButtonName, Value = true, Active = true},
		}

		return Roact.createElement("Frame", {
			ZIndex = 4,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.7,
			Size = UDim2.new(1, 0, 1, 0),
		}, {
			Drawer = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, DRAWER_HEIGHT),
				Position = UDim2.new(0, 0, 1, 0),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = theme.drawer.background,
				BorderSizePixel = 3,
				BorderColor3 = theme.drawer.border,
				ZIndex = 5,
			}, {
				Header = Roact.createElement("TextLabel", {
					Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
					Position = UDim2.new(0, 17, 0, 0),
					Text = self.props.Header,
					Font = Enum.Font.Gotham,
					TextSize = 16,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					TextColor3 = theme.mainText,
					ZIndex = 6,
				}),
				Items = Roact.createElement("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, DRAWER_HEIGHT - HEADER_HEIGHT),
					Position = UDim2.new(0, 0, 1, 0),
					AnchorPoint = Vector2.new(0, 1),
					ZIndex = 6,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 15),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					Padding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 15),
						PaddingRight = UDim.new(0, 15),
						PaddingBottom = UDim.new(0, 10),
					}),
					TextEntry = Roact.createElement(RoundTextBox, {
						WidthCut = -140,
						LayoutOrder = 1,
						Active = true,
						StartCaptured = true,
						SetText = function(text)
							self.text = text
						end,

						FocusChanged = self.props.FocusChanged,
						Submitted = self.props.Submitted,
					}),
					Buttons = Roact.createElement(ButtonBar, {
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Buttons = buttons,
						LayoutOrder = 2,
						Width = 200,
						ZIndex = 6,
						ButtonClicked = self.textCompleted,
					}),
				}),
			}),
		})
	end)
end

return BottomDrawer
