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
local visitChildren = require(Plugin.Src.Util.visitChildren)

local PropsList = Roact.PureComponent:extend("PropsList")

function PropsList:init()
	self.iterator = 0
	self.listItems = nil
end

function PropsList:AddPropertyItem(name, path, parent)
	local i = self.iterator
	self.listItems[parent:GetDebugId() .. " " .. name] = Roact.createElement(PropertyItem, {
		LighterColor = i % 2 == 0,
		LayoutOrder = i,
		Indentation = PathUtils.StepsFromRoot(path) + 1,
		Property = name,
		Path = path,
	})
	self.iterator = i + 1
end

function PropsList:AddInstanceItem(root, instance, path, selected, expandable, expanded)
	local i = self.iterator
	self.listItems[instance:GetDebugId()] = Roact.createElement(InstanceItem, {
		LighterColor = i % 2 == 0,
		LayoutOrder = i,
		Indentation = PathUtils.StepsFromRoot(path),
		Instance = instance,
		Root = root,
		Name = instance.Name,
		Expanded = expanded,
		Expandable = expandable,
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
	local instanceStates = self.props.InstanceStates

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
				if instance == nil then return end
				local relativePath = PathUtils.RelativePath(currentInstance, instance)
				local id = instance:GetDebugId()
				local props = currentTable[relativePath]
				local state = instanceStates[id]
				if state then
					self:AddInstanceItem(currentInstance, instance, relativePath,
						selection == instance, props ~= nil or visitChildren(instance) > 0, state.Expanded)
					if state.Expanded then
						if props then
							for name in pairs(props) do
								self:AddPropertyItem(name, relativePath, instance)
							end
						end
					end
					return state.Expanded
				else
					return false
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
