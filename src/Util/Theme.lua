local Plugin = script.Parent.Parent.Parent

local createSignal = require(Plugin.Src.Util.createSignal)
local Cryo = require(Plugin.Cryo)
local Constants = require(Plugin.Src.Util.Constants)

local Theme = {}

function Theme.new(override)
	local self = {
		overrideTheme = override or nil,
		signal = createSignal(),
		externalThemeChangedConnection = nil,

		values = {},
	}

	setmetatable(self, {
		__index = Theme
	})

	if override == nil then
		self.externalThemeChangedConnection = settings().Studio.ThemeChanged:Connect(function()
			self:recalculateTheme()
		end)
	end

	self:recalculateTheme()

	return self
end

function Theme:subscribe(...)
	return self.signal:subscribe(...)
end

function Theme:destroy()
	if self.externalThemeChangedConnection then
		self.externalThemeChangedConnection:Disconnect()
	end
end

function Theme:update(changedValues)
	self.values = Cryo.Dictionary.join(self.values, changedValues)
	self.signal:fire(self.values)
end

function Theme:getExternalTheme()
	local overrideTheme = self.overrideTheme
	if overrideTheme then
		return overrideTheme
	end

	return settings().Studio.Theme
end

function Theme:isDarkerTheme()
	-- Assume "darker" theme if the average main background colour is darker
	local mainColour = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	return (mainColour.r + mainColour.g + mainColour.b) / 3 < 0.5
end

function Theme:recalculateTheme()
	local externalTheme = self:getExternalTheme()
	local isDark = self:isDarkerTheme()

	-- Shorthands for getting a color
	local c = Enum.StudioStyleGuideColor
	local m = Enum.StudioStyleGuideModifier

	local function color(...)
		return externalTheme:GetColor(...)
	end

	self:update({
		isDarkerTheme = isDark,

		playhead = Constants.BLUE,
		white = Color3.new(1, 1, 1),

		backgroundColor = color(c.MainBackground),
		mainText = color(c.MainText),
		dimmedText = color(c.DimmedText),

		header = {
			background = color(c.MainBackground),
			border = color(c.Border),
		},

		drawer = {
			background = color(c.RibbonTab),
			border = color(c.Border),
		},

		tooltip = {
			background = isDark and color(c.GameSettingsTooltip) or color(c.RibbonTab, m.Default),
			border = color(c.Border),
			text = isDark and color(c.SubText) or color(c.DimmedText),
		},

		propsList = {
			background = color(c.MainBackground),
			border = color(c.Border),
		},

		headerButton = {
			background = color(c.Button),
			border = color(c.Border),
			text = color(c.MainText),
			highlight = Constants.BLUE,
		},

		keyframe = {
			background = color(c.Light),
			border = color(c.Dark),
			selected = {
				background = color(c.CurrentMarker),
				border = color(c.Button, m.Selected),
			},
		},

		listItem = {
			text = color(c.MainText),
			brightText = color(c.BrightText),
			light = color(c.RibbonButton, m.Selected),
			dark = isDark and color(c.RibbonButton, m.Hover) or color(c.GameSettingsTableItem),
			na = color(c.MainBackground),
			selected = color(c.Item, m.Selected),
			selectedText = isDark and color(c.BrightText) or Color3.new(1, 1, 1),
		},

		timeline = {
			background = color(c.RibbonButton, m.Hover),
			tick = isDark and color(c.Light) or color(c.RibbonButton, m.Hover),
			mainTick = color(c.Dark),
		},

		cancelButton = {
			ButtonColor = color(c.Button),
			ButtonColor_Hover = color(c.Button, m.Hover),
			ButtonColor_Disabled = color(c.Button, m.Disabled),
			TextColor = color(c.MainText),
			TextColor_Disabled = color(c.DimmedText),
			BorderColor = color(c.Border),
		},

		defaultButton = {
			ButtonColor = isDark and color(c.MainButton) or color(c.CurrentMarker),
			ButtonColor_Hover = color(c.LinkText),
			ButtonColor_Disabled = isDark and color(c.Button, m.Disabled) or Constants.BLUE_DISABLED,
			TextColor = Color3.new(1, 1, 1),
			TextColor_Disabled = isDark and color(c.DimmedText) or Color3.new(1, 1, 1),
			BorderColor = color(c.Light),
		},

		textBox = {
			background = color(c.InputFieldBackground),
			disabled = color(c.Tab),
			borderDefault = color(c.Border),
			borderHover = isDark and color(c.MainButton) or color(c.CurrentMarker),
			tooltip = color(c.DimmedText),
			text = color(c.MainText),
		},
--[[
		hyperlink = color(c.LinkText),
		warningColor = color(c.WarningText),

		separator = isDark and color(c.Border) or color(c.Titlebar),

		scrollBar = isDark and color(c.ScrollBar) or color(c.Border),
		scrollBarBackground = isDark and color(c.ScrollBarBackground) or Color3.fromRGB(245, 245, 245),

		menuBar = {
			backgroundColor = isDark and color(c.ScrollBarBackground) or color(c.MainBackground),
		},

		menuEntry = {
			hover = isDark and color(c.CurrentMarker) or color(c.RibbonTab),
			highlight = isDark and color(c.TableItem, m.Selected) or color(c.CurrentMarker),
			text = color(c.BrightText),
		},

		header = {
			text = color(c.BrightText),
		},

		footer = {
			gradient = color(c.MainText),
		},

		titledFrame = {
			text = color(c.SubText),
		},

		radioButton = {
			background = color(c.InputFieldBackground),
			title = color(c.BrightText),
			description = color(c.DimmedText),
		},

		checkBox = {
			background = color(c.InputFieldBackground),
			title = color(c.BrightText),
		},

		dropDown = {
			background = color(c.Button),
			hover = color(c.Button, m.Hover),
			text = color(c.BrightText),
			disabled = color(c.Tab),
			handle = color(c.MainText),
			border = color(c.Border),
			gradient = color(c.Dark)
		},

		dropDownEntry = {
			background = color(c.MainBackground),
			hover = isDark and color(c.CurrentMarker) or color(c.RibbonTab),
			highlight = isDark and color(c.TableItem, m.Selected) or color(c.CurrentMarker),
			text = color(c.MainText),
		},

		dialog = {
			background = color(c.MainBackground),
			text = color(c.MainText),
		},

		thumbnail = {
			background = color(c.Dark),
			count = color(c.DimmedText),
		},

		newThumbnail = {
			background = color(c.TableItem),
			border = isDark and color(c.Dark) or color(c.Titlebar),
			plus = isDark and color(c.MainText) or color(c.DimmedText),
		},

		thumbnailDrag = {
			background = color(c.CurrentMarker, m.Selected),
			border = color(c.CurrentMarker, m.Selected),
		},
]]
	})
end

function Theme.newDummyTheme()
	return Theme.new({
		GetColor = function()
			return Color3.fromRGB(0, 0, 0)
		end,
	})
end

return Theme