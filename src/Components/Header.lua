local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local Cryo = require(Plugin.Cryo)

local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local HeaderButton = require(Plugin.Src.Components.HeaderButton)
local HeaderDropdown = require(Plugin.Src.Components.HeaderDropdown)
local SetCurrentTween = require(Plugin.Src.Thunks.SetCurrentTween)
local CreateTween = require(Plugin.Src.Thunks.CreateTween)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local Header = Roact.PureComponent:extend("Header")

local function makeSeparator(color, index)
	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 0, 0, Constants.HEADER_HEIGHT - 4),
		BorderSizePixel = 1,
		BorderColor3 = color,
		ZIndex = 5,
		LayoutOrder = index,
	})
end

function Header:render()
	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, Constants.HEADER_HEIGHT),
			BackgroundColor3 = theme.header.background,
			BorderColor3 = theme.header.border,
			BorderSizePixel = 1,
			ZIndex = 5,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 10),
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
			}),
			SaveAll = Roact.createElement(HeaderButton, {
				Width = 80,
				Text = "Save All",
				Tooltip = "Save and export all changes.",
				LayoutOrder = 1,
				Highlight = self.props.Dirty,
				OnClick = function()
					self.props.ButtonPressed("SaveAll")
				end,
			}),
			Reload = Roact.createElement(HeaderButton, {
				Width = 80,
				Text = "Reload",
				Tooltip = "Delete changes and sync with exported tweens.",
				LayoutOrder = 2,
				OnClick = function()
					self.props.ButtonPressed("Reload")
				end,
			}),
			Separator = makeSeparator(theme.header.border, 3),
			Tweens = Roact.createElement(HeaderDropdown, {
				Width = 175,
				Entries = self.props.Tweens,
				SelectedEntry = self.props.CurrentTween,
				LayoutOrder = 4,
				SelectEntry = self.props.SetCurrentTween,
				CreateTween = self.props.CreateTween,
			})
		})
	end)
end

Header = RoactRodux.connect(
	function(state, props)
		if not state then return end
		return {
			Dirty = state.Status.Dirty,
			CurrentTween = state.Tweens.CurrentTween,
			Tweens = Cryo.Dictionary.keys(state.Tweens.Tweens),
		}
	end,
	function(dispatch)
		return {
			SetCurrentTween = function(tween)
				dispatch(SetCurrentTween(tween))
			end,
			CreateTween = function()
				dispatch(CreateTween())
			end,
		}
	end
)(Header)

return Header
