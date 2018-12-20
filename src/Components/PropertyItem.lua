--[[
	Props:
		bool LighterColor = Whether to display this item with a lighter color
]]

local DELETE_ICON = "rbxasset://textures/CollisionGroupsEditor/delete.png"
local DELETE_ICON_HOVER = "rbxasset://textures/CollisionGroupsEditor/delete-hover.png"

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local DeleteProperty = require(Plugin.Src.Thunks.DeleteProperty)
--local getMouse = require(Plugin.Src.Consumers.getMouse)
local IconButton = require(Plugin.Src.Components.IconButton)

local ListItem = require(Plugin.Src.Components.ListItem)

local PropertyItem = Roact.PureComponent:extend("PropertyItem")

function PropertyItem:init()
	self.deleteProperty = function()
		self.props.DeleteProperty(self.props.Instance,
			self.props.Property,
			self.props.Root)
	end
end

function PropertyItem:render()
	local property = self.props.Property
	local instance = self.props.Instance

	return withTheme(function(theme)
		return Roact.createElement(ListItem, {
			LighterColor = self.props.LighterColor,
			LayoutOrder = self.props.LayoutOrder,
			Indentation = self.props.Indentation,
		}, {
			Name = Roact.createElement("TextButton", {
				TextColor3 = theme.listItem.text,
				BackgroundTransparency = 1,
				Text = property,
				Size = UDim2.new(1, -40, 1, 0),
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
			RemoveButton = Roact.createElement(IconButton, {
				IdleIcon = DELETE_ICON,
				HoverIcon = DELETE_ICON_HOVER,
				Size = UDim2.new(0, 16, 0, 16),
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Tooltip = "Delete this Property",
				ImageRectSize = Vector2.new(32, 32),
				ImageRectOffset = Vector2.new(9, 8),

				OnClick = self.deleteProperty,
				ZIndex = 2,
			})
		})
	end)
end

PropertyItem = RoactRodux.connect(
	function(state, props)
		if not state then return end
		return {
		}
	end,
	function(dispatch)
		return {
			DeleteProperty = function(instance, prop, root)
				dispatch(DeleteProperty(instance, prop, root))
			end,
		}
	end
)(PropertyItem)

return PropertyItem
