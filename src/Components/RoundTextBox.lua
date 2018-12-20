--[[
	A TextBox with rounded corners that allows single-line entry.
	maximum character count, and error messages.

	Props:
		bool Active = Whether this component can be interacted with.
		int Height = The vertical size of this TextBox, in pixels.
		int LayoutOrder = The sort order of this component in a UIListLayout.

		string ErrorMessage = A general override message used to display an error.
			A non-nil ErrorMessage will border the TextBox in red.

		string Text = The text to display in the TextBox
		function SetText(text) = Callback to tell parent that text has changed
		function FocusChanged(focused) = Callback when this TextBox is focused.
		function HoverChanged(hovering) = Callback when the mouse enters or leaves this TextBox.
]]

local DEFAULT_HEIGHT = 42
local PADDING = UDim.new(0, 10)

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Cryo = require(Plugin.Cryo)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local TextEntry = require(Plugin.Src.Components.TextEntry)

local RoundTextBox = Roact.PureComponent:extend("RoundTextBox")

function RoundTextBox:init()
	self.state = {
		Focused = false,
	}

	self.focusChanged = function(focused)
		if self.props.Active then
			self:setState(Cryo.Dictionary.join(self.state, {
				Focused = focused,
			}))
			if self.props.FocusChanged then
				self.props.FocusChanged(focused)
			end
		end
	end

	self.mouseHoverChanged = function(hovering)
		if self.props.Active then
			--getMouse(self).setHoverIcon("IBeam", hovering)

			if self.state.Focused and self.props.HoverChanged then
				self.props.HoverChanged(hovering)
			end
		end
	end
end

function RoundTextBox:render()
	return withTheme(function(theme)
		local active = self.props.Active
		local focused = self.state.Focused
		local text = self.props.Text or ""
		local errorState = self.props.ErrorMessage

		local backgroundProps = {
			-- Necessary to make the rounded background
			BackgroundTransparency = 1,
			Image = Constants.ROUNDED_BACKGROUND_IMAGE,
			ImageTransparency = 0,
			ImageColor3 = active and theme.textBox.background or theme.textBox.disabled,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Constants.ROUNDED_FRAME_SLICE,

			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, self.props.WidthCut or 0, 0, self.props.Height or DEFAULT_HEIGHT),

			LayoutOrder = self.props.LayoutOrder or 1,
			ZIndex = 5,
		}

		local borderColor
		if active then
			if errorState then
				borderColor = Constants.ERROR_COLOR
			elseif focused then
				borderColor = theme.textBox.borderHover
			else
				borderColor = theme.textBox.borderDefault
			end
		else
			borderColor = theme.textBox.borderDefault
		end

		local textEntryProps = {
			Visible = self.props.Active,
			Text = text,
			FocusChanged = self.focusChanged,
			HoverChanged = self.mouseHoverChanged,
			SetText = self.props.SetText,
			TextColor3 = theme.textBox.text,
			StartCaptured = self.props.StartCaptured,
			Submitted = self.props.Submitted,
		}

		local textEntry = Roact.createElement(TextEntry, textEntryProps)

		return Roact.createElement("ImageLabel", backgroundProps, {
			Border = Roact.createElement("ImageLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Image = Constants.ROUNDED_BORDER_IMAGE,
				ImageColor3 = borderColor,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Constants.ROUNDED_FRAME_SLICE,
				ZIndex = 6,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingLeft = PADDING,
					PaddingRight = PADDING,
					PaddingTop = PADDING,
					PaddingBottom = PADDING,
				}),
				Text = textEntry,
			}),
		})
	end)
end

return RoundTextBox
