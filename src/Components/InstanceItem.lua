--[[
	Props:
		bool LighterColor = Whether to display this item with a lighter color
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local PathUtils = require(Plugin.Src.Util.PathUtils)
--local getMouse = require(Plugin.Src.Consumers.getMouse)
local InstanceChanged = require(Plugin.Src.Thunks.InstanceChanged)
local ToggleExpanded = require(Plugin.Src.Actions.ToggleExpanded)

local ListItem = require(Plugin.Src.Components.ListItem)

local InstanceItem = Roact.PureComponent:extend("InstanceItem")

function InstanceItem:init(initialProps)
	local root = initialProps.Root
	local instance = initialProps.Instance
	local oldPath = PathUtils.RelativePath(root, instance)

	self.changed = function()
		local newPath = PathUtils.RelativePath(root, instance)
		self.props.InstanceChanged(oldPath, newPath)
		oldPath = newPath
	end

	self.nameConnection = instance:GetPropertyChangedSignal("Name"):Connect(self.changed)
	self.parentConnection = instance:GetPropertyChangedSignal("Parent"):Connect(self.changed)
end

function InstanceItem:willUnmount()
	if self.nameConnection then
		self.nameConnection:Disconnect()
	end
	if self.parentConnection then
		self.parentConnection:Disconnect()
	end
end

function InstanceItem:render()
	local name = self.props.Name
	local instance = self.props.Instance
	local expanded = self.props.Expanded

	return withTheme(function(theme)
		return Roact.createElement(ListItem, {
			LighterColor = self.props.LighterColor,
			LayoutOrder = self.props.LayoutOrder,
			Indentation = self.props.Indentation,
			Selected = self.props.Selected,
		}, {
			Name = Roact.createElement("TextButton", {
				TextColor3 = theme.listItem.brightText,
				BackgroundTransparency = 1,
				Text = name,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 20, 0, 0),
				Font = Enum.Font.Gotham,

				TextSize = Constants.ITEM_TEXT_SIZE,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 2,

				[Roact.Event.Activated] = function()
					if instance then
						game.Selection:Set({instance})
					end
				end,
			}),
			ExpandButton = Roact.createElement("ImageButton", {
				Size = UDim2.new(0, 20, 0, 20),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 10, 0.5, 0),
				BackgroundTransparency = 1,
				ImageTransparency = 1,
				ZIndex = 3,

				[Roact.Event.Activated] = function()
					self.props.ToggleExpanded(self.props.Path)
				end,
			}),
			ExpandIcon = self.props.HasProps and Roact.createElement("ImageLabel", {
				BackgroundTransparency = 1,
				Image = expanded and Constants.EXPANDED_IMAGE or Constants.HIDDEN_IMAGE,
				ImageColor3 = theme.listItem.brightText,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.new(0, 9, 0, 9),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 5, 0.5, 0),
				ZIndex = 2,
			})
		})
	end)
end

InstanceItem = RoactRodux.connect(
	function(state, props)
		if not state then return end
		return {
		}
	end,
	function(dispatch)
		return {
			InstanceChanged = function(oldPath, newPath)
				dispatch(InstanceChanged(oldPath, newPath))
			end,
			ToggleExpanded = function(path)
				dispatch(ToggleExpanded(path))
			end,
		}
	end
)(InstanceItem)

return InstanceItem