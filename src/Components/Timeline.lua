--[[
	Props:
		CurrentTable = The current tween table.
		CurrentInstance
		InstanceStates
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)
local ListItem = require(Plugin.Src.Components.ListItem)

local Timeline = Roact.PureComponent:extend("Timeline")

function Timeline:init()
	self.iterator = 0
	self.iterator2 = 0
	self.listItems = nil
end

function Timeline:AddPropertyItem(instance, name)
	local i = self.iterator
	local j = self.iterator2
	self.listItems[instance:GetDebugId() .. " " .. name] = Roact.createElement(ListItem, {
		LighterColor = j % 2 == 0,
		LayoutOrder = i,
	})
	self.iterator = i + 1
	self.iterator2 = j + 1
end

function Timeline:AddInstanceItem(instance, selected, color)
	local i = self.iterator
	self.listItems[instance:GetDebugId()] = Roact.createElement(ListItem, {
		Selected = selected,
		Color = (not selected and color) or nil,
		LayoutOrder = i,
	})
	self.iterator = i + 1
end

function Timeline:AddSeparator(color)
	local i = self.iterator
	self.listItems[".Sep"] = Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BorderSizePixel = 1,
		BorderColor3 = color,
		LayoutOrder = i,
	})
	self.iterator = i + 1
end

function Timeline:render()
	return withTheme(function(theme)
		self.iterator = 1
		self.iterator2 = 1
		self.listItems = nil

		self.listItems = {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
		}

		for _, item in pairs(self.props.ListItems) do
			if item.Type == "Property" then
				self:AddPropertyItem(item.Instance, item.Name)
			elseif item.Type == "Instance" then
				self:AddInstanceItem(item.Instance, item.Selected, theme.listItem.na)
			end
		end

		self:AddSeparator(theme.propsList.border)

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 0,
			BackgroundColor3 = theme.listItem.na,
			LayoutOrder = 2,
		}, self.listItems)
	end)
end

return Timeline
