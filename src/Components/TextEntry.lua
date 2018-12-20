--[[
	A text entry that is only one line.
	Used in a RoundTextBox.

	Props:
		string Text = The text to display
		bool Visible = Whether to display this component
		function SetText(text) = Callback to tell parent that text has changed
		function FocusChanged(focus) = Callback to tell parent that this component has focus
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)

local TextEntry = Roact.PureComponent:extend("TextEntry")

function TextEntry:init()
	self.textBoxRef = Roact.createRef()
	self.onTextChanged = function(rbx)
		if rbx.TextFits then
			rbx.TextXAlignment = Enum.TextXAlignment.Left
		else
			rbx.TextXAlignment = Enum.TextXAlignment.Right
		end
		if rbx.Text ~= self.props.Text then
			self.props.SetText(rbx.Text)
		end
	end

	self.mouseEnter = function()
		self.props.HoverChanged(true)
	end
	self.mouseLeave = function()
		self.props.HoverChanged(false)
	end
end

function TextEntry:didMount()
	spawn(function()
		if self.props.StartCaptured then
			self.textBoxRef.current:CaptureFocus()
		end
	end)
end

function TextEntry:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 7,
	}, {
		Text = Roact.createElement("TextBox", {
			Visible = self.props.Visible,

			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			ClearTextOnFocus = false,
			Font = Enum.Font.Gotham,
			TextSize = 22,
			TextColor3 = self.props.TextColor3,
			Text = self.props.Text,
			TextXAlignment = Enum.TextXAlignment.Left,

			[Roact.Ref] = self.textBoxRef,

			[Roact.Event.MouseEnter] = self.mouseEnter,
			[Roact.Event.MouseLeave] = self.mouseLeave,

			[Roact.Event.Focused] = function()
				self.props.FocusChanged(true)
			end,

			[Roact.Event.FocusLost] = function(enterPressed)
				local textBox = self.textBoxRef.current
				textBox.TextXAlignment = Enum.TextXAlignment.Left
				if enterPressed then
					self.props.Submitted(textBox.Text)
				else
					self.props.FocusChanged(false)
				end
			end,

			[Roact.Change.Text] = self.onTextChanged,
			ZIndex = 7,
		}),
	})
end

return TextEntry
