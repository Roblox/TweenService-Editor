local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local Cryo = require(Plugin.Cryo)

local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local HeaderButton = require(Plugin.Src.Components.HeaderButton)
local HeaderImageButton = require(Plugin.Src.Components.HeaderImageButton)
local HeaderDropdown = require(Plugin.Src.Components.HeaderDropdown)
local SetCurrentTween = require(Plugin.Src.Thunks.SetCurrentTween)
local SetEasingStyle = require(Plugin.Src.Thunks.SetEasingStyle)
local SetEasingDirection = require(Plugin.Src.Thunks.SetEasingDirection)
local CreateTween = require(Plugin.Src.Thunks.CreateTween)
local CopyTween = require(Plugin.Src.Thunks.CopyTween)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local Header = Roact.PureComponent:extend("Header")

local EASING_STYLES
local EASING_DIRECTIONS
local DELETE_IMAGE = "rbxassetid://2668515891"
local RENAME_IMAGE = "rbxassetid://2668514876"
local DELETE_KF_IMAGE = "rbxassetid://2668515160"
local SAVE_IMAGE = "rbxassetid://2668572481"
local PREVIEW_IMAGE = "rbxassetid://2668578577"

function Header:init()
	local styles = {}
	for _, item in pairs(Enum.EasingStyle:GetEnumItems()) do
		table.insert(styles, item.Name)
	end
	EASING_STYLES = styles

	local directions = {}
	for _, item in pairs(Enum.EasingDirection:GetEnumItems()) do
		table.insert(directions, item.Name)
	end
	EASING_DIRECTIONS = directions
end

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
		local selectedKeyframe = self.props.SelectedKeyframe and self.props.SelectedKeyframe.Index > 0
		local selectedStyle, selectedDirection
		if selectedKeyframe then
			local skf = self.props.SelectedKeyframe
			local tweens = self.props.Tweens
			local currentTween = tweens[self.props.CurrentTween]
			local current = currentTween[skf.Path][skf.Prop].Keyframes[skf.Index]
			selectedStyle = current.EasingStyle
			selectedDirection = current.EasingDirection
		end

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
				Padding = UDim.new(0, 8),
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
			}),
			SaveAll = Roact.createElement(HeaderImageButton, {
				Image = SAVE_IMAGE,
				Tooltip = "Save and export all changes.",
				LayoutOrder = 1,
				Highlight = self.props.Dirty,
				OnClick = function()
					self.props.ButtonPressed("SaveAll")
				end,
			}),
			Preview = Roact.createElement(HeaderImageButton, {
				Image = PREVIEW_IMAGE,
				Tooltip = "Preview the current tween.",
				LayoutOrder = 2,
				OnClick = function()
					self.props.ButtonPressed("Preview")
				end,
			}),
			ReloadSeparator = makeSeparator(theme.header.border, 3),
			Reload = Roact.createElement(HeaderImageButton, {
				Image = DELETE_IMAGE,
				Tooltip = "Delete changes and sync with exported tweens.",
				LayoutOrder = 4,
				OnClick = function()
					self.props.ButtonPressed("Reload")
				end,
			}),
			Separator = makeSeparator(theme.header.border, 5),
			Tweens = Roact.createElement(HeaderDropdown, {
				Width = 175,
				Entries = Cryo.Dictionary.keys(self.props.Tweens),
				SelectedEntry = self.props.CurrentTween,
				LayoutOrder = 6,
				SelectEntry = self.props.SetCurrentTween,
				CreateTween = self.props.CreateTween,
				CopyTween = self.props.CopyTween,
				AddNew = true,
				Prompt = "Editing: "
			}),
			Rename = Roact.createElement(HeaderImageButton, {
				Image = RENAME_IMAGE,
				Text = "Rename",
				Tooltip = "Rename the current tween.",
				LayoutOrder = 7,
				OnClick = function()
					self.props.ButtonPressed("Rename")
				end,
			}),
			Delete = Roact.createElement(HeaderImageButton, {
				Image = DELETE_KF_IMAGE,
				Text = "Delete",
				Tooltip = "Delete the current tween.",
				LayoutOrder = 8,
				OnClick = function()
					self.props.ButtonPressed("Delete")
				end,
			}),
			Separator2 = selectedKeyframe and makeSeparator(theme.header.border, 7),
			EasingStyle = selectedKeyframe and Roact.createElement(HeaderDropdown, {
				Width = 153,
				Entries = EASING_STYLES,
				SelectedEntry = selectedStyle.Name,
				LayoutOrder = 9,
				SelectEntry = self.props.SetEasingStyle,
				Prompt = "EasingStyle: "
			}),
			EasingDirection = selectedKeyframe and Roact.createElement(HeaderDropdown, {
				Width = 170,
				Entries = EASING_DIRECTIONS,
				SelectedEntry = selectedDirection.Name,
				LayoutOrder = 10,
				SelectEntry = self.props.SetEasingDirection,
				Prompt = "EasingDirection: "
			}),
		})
	end)
end

Header = RoactRodux.connect(
	function(state, props)
		if not state then return end
		return {
			Dirty = state.Status.Dirty,
			CurrentTween = state.Tweens.CurrentTween,
			Tweens = state.Tweens.Tweens,
			SelectedKeyframe = state.Status.SelectedKeyframe,
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
			CopyTween = function()
				dispatch(CopyTween())
			end,
			SetEasingStyle = function(style)
				dispatch(SetEasingStyle(style))
			end,
			SetEasingDirection = function(direction)
				dispatch(SetEasingDirection(direction))
			end,
		}
	end
)(Header)

return Header
