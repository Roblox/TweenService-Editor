--[[
	Props:
		CurrentTable = The current tween table.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local PathUtils = require(Plugin.Src.Util.PathUtils)
--local getMouse = require(Plugin.Src.Consumers.getMouse)
local InstanceItem = require(Plugin.Src.Components.InstanceItem)
local PropertyItem = require(Plugin.Src.Components.PropertyItem)

local PropsList = Roact.PureComponent:extend("PropsList")

function PropsList:init()
	self.iterator = 0
	self.iterator2 = 0
	self.listItems = nil

	self.inputChanged = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			self.props.OnScroll(input.Position.Z, #self.props.ListItems)
		end
	end
end

function PropsList:AddPropertyItem(name, path, instance, root)
	local i = self.iterator
	local j = self.iterator2
	self.listItems[instance:GetDebugId() .. " " .. name] = Roact.createElement(PropertyItem, {
		LighterColor = j % 2 == 0,
		LayoutOrder = i,
		Indentation = PathUtils.StepsFromRoot(path) + 1,
		Property = name,
		Instance = instance,
		Root = root,
	})
	self.iterator = i + 1
	self.iterator2 = j + 1
end

function PropsList:AddInstanceItem(root, instance, path, selected, expandable, expanded, color)
	local i = self.iterator
	self.listItems[instance:GetDebugId()] = Roact.createElement(InstanceItem, {
		LayoutOrder = i,
		Indentation = PathUtils.StepsFromRoot(path),
		Instance = instance,
		Root = root,
		Name = instance == root and (instance.Name .. " (Root)") or instance.Name,
		Expanded = expanded,
		Expandable = expandable,
		Selected = selected,
		Color = not selected and color or nil,
	})
	self.iterator = i + 1
end

function PropsList:AddSeparator(color)
	local i = self.iterator
	self.listItems[".Sep"] = Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BorderSizePixel = 1,
		BorderColor3 = color,
		LayoutOrder = i,
	})
	self.iterator = i + 1
end

function PropsList:render()
	return withTheme(function(theme)
		self.iterator = 1
		self.iterator2 = 1
		self.listItems = nil
		local currentInstance = self.props.CurrentInstance
		local startIndex = self.props.StartIndex

		self.listItems = {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			Padding = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = theme.timeline.background,
				BorderSizePixel = 0,
				LayoutOrder = 0,
			}, {
				HiddenItems = startIndex > 1 and Roact.createElement("TextLabel", {
					Text = string.format("Hidden items (%i) - Scroll up to show", startIndex - 1),
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = theme.dimmedText,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
				}),
			}),
		}

		for i, item in ipairs(self.props.ListItems) do
			if i >= startIndex then
				if item.Type == "Property" then
					self:AddPropertyItem(item.Name, item.Path, item.Instance, currentInstance)
				elseif item.Type == "Instance" then
					self:AddInstanceItem(currentInstance, item.Instance, item.Path, item.Selected,
						item.Props or item.Children, item.Expanded, theme.listItem.na)
				end
			end
		end

		self:AddSeparator(theme.propsList.border)

		return Roact.createElement("Frame", {
			Size = UDim2.new(0, Constants.PROPS_WIDTH, 1, 0),
			BackgroundColor3 = theme.propsList.background,
			BorderColor3 = theme.propsList.border,
			BorderSizePixel = 3,

			[Roact.Event.InputChanged] = self.inputChanged,
		}, self.listItems)
	end)
end

return PropsList
