local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)
local HeaderDropdownEntry = require(Plugin.Src.Components.HeaderDropdownEntry)

local HeaderDropdown = Roact.PureComponent:extend("HeaderDropdown")

function HeaderDropdown:init()
	self.state = {
		Open = false,
	}

	self.open = function()
		self:setState({
			Open = not self.state.Open
		})
	end

	self.close = function()
		self:setState({
			Open = false
		})
	end

	self.inputBegan = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.close()
		end
	end

	self.selectEntry = function(entry)
		self.close()
		self.props.SelectEntry(entry)
	end

	self.createTween = function()
		self.close()
		self.props.CreateTween()
	end
end

function HeaderDropdown:render()
	return withTheme(function(theme)
		local entries = self.props.Entries
		local selectedEntry = self.props.SelectedEntry
		local open = self.state.Open

		if entries then
			table.sort(entries)
		end

		local buttons = {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			})
		}

		if open then
			if self.props.AddNew then
				table.insert(buttons, Roact.createElement(HeaderDropdownEntry, {
					Text = "New...",
					Width = self.props.Width,
					LayoutOrder = 0,
					Current = false,
					OnClick = self.createTween,
				}))
			end
			for i, entry in ipairs(entries) do
				table.insert(buttons, Roact.createElement(HeaderDropdownEntry, {
					Text = entry,
					Width = self.props.Width,
					LayoutOrder = i,
					Current = entry == selectedEntry,
					OnClick = self.selectEntry,
				}))
			end
		end

		return Roact.createElement("TextButton", {
			Size = UDim2.new(0, self.props.Width or 20, 0, Constants.HEADER_HEIGHT - 4),
			BorderSizePixel = 1,
			Text = "  " .. self.props.Prompt .. selectedEntry,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Font = Enum.Font.Gotham,
			LayoutOrder = self.props.LayoutOrder or 0,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,

			TextColor3 = theme.headerButton.text,
			BackgroundColor3 = theme.headerButton.background,
			BorderColor3 = self.props.Highlight and theme.headerButton.highlight or theme.headerButton.border,

			ZIndex = 8,

			[Roact.Event.Activated] = self.open,
		}, {
			Modal = open and Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1000, 0, 1000, 0),
				Position = UDim2.new(0.5, 0, 0, 0),
				AnchorPoint = Vector2.new(0.5, 0),
				ZIndex = 7,

				[Roact.Event.InputBegan] = self.inputBegan,
			}),
			Dropdown = open and Roact.createElement("Frame", {
				Size = UDim2.new(0, self.props.Width, 0,
					(Constants.HEADER_HEIGHT - 4) * (#entries + (self.props.AddNew and 1 or 0))),
				Position = UDim2.new(0, 0, 0, Constants.HEADER_HEIGHT - 4),
				BackgroundColor3 = theme.headerButton.background,
				BorderColor3 = theme.headerButton.border,
				BorderSizePixel = 1,
				ZIndex = 9,
			}, buttons)
		})
	end)
end

return HeaderDropdown
