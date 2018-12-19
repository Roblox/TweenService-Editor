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
local visitDescendants = require(Plugin.Src.Util.visitDescendants)

local PropsList = Roact.PureComponent:extend("PropsList")

function PropsList:init()
	self.iterator = 0
	self.listItems = nil
end

function PropsList:AddPropertyItem(name, parent)
	local i = self.iterator
	self.listItems[name .. parent] = Roact.createElement(PropertyItem, {
		LighterColor = i % 2 == 0,
		LayoutOrder = i,
		Indentation = PathUtils.StepsFromRoot(parent) + 1,
		Property = name,
		Parent = parent,
	})
	self.iterator = i + 1
end

function PropsList:AddInstanceItem(root, instance, path, selected, expanded, hasProps)
	local i = self.iterator
	self.listItems[path] = Roact.createElement(InstanceItem, {
		LighterColor = i % 2 == 0,
		LayoutOrder = i,
		Indentation = PathUtils.StepsFromRoot(path),
		Instance = instance,
		Root = root,
		Name = instance.Name,
		Path = path,
		Expanded = expanded,
		HasProps = hasProps,
		Selected = selected,
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
	local selection = self.props.Selection and #self.props.Selection == 1 and self.props.Selection[1]
	local expandedItems = self.props.ExpandedItems

	return withTheme(function(theme)
		self.iterator = 1
		self.listItems = nil
		local currentTable = self.props.CurrentTable
		local currentInstance = self.props.CurrentInstance

		self.listItems = {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
		}

		if currentTable then
			visitDescendants(currentInstance, function(instance)
				local relativePath = PathUtils.RelativePath(currentInstance, instance)
				local props = currentTable[relativePath]
				self:AddInstanceItem(currentInstance, instance, relativePath,
					selection == instance, expandedItems[relativePath], props ~= nil)
				if expandedItems[relativePath] then
					if props then
						for name in pairs(props) do
							self:AddPropertyItem(name, relativePath)
						end
					end
				end
			end)
			self:AddSeparator(theme.header.border)
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(0, Constants.PROPS_WIDTH, 1, 0),
			BackgroundColor3 = theme.propsList.background,
			BorderColor3 = theme.propsList.border,
			BorderSizePixel = 3,
		}, self.listItems)
	end)
end

return PropsList
