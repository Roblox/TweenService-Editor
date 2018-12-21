--[[
	Props:
		CurrentTable = The current tween table.
		CurrentInstance
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local Constants = require(Plugin.Src.Util.Constants)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local visitDescendants = require(Plugin.Src.Util.visitDescendants)
local visitChildren = require(Plugin.Src.Util.visitChildren)
local PathUtils = require(Plugin.Src.Util.PathUtils)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local Header = require(Plugin.Src.Components.Header)
local PropsList = require(Plugin.Src.Components.PropsList)
local Timeline = require(Plugin.Src.Components.Timeline)

local Editor = Roact.PureComponent:extend("Editor")

function Editor:init()
	self.state = {
		Width = 0,
	}
	self.frameRef = Roact.createRef()

	self.sizeChanged = function(rbx)
		self:setState({
			Width = self.frameRef.current.AbsoluteSize.X
		})
	end
end

function Editor:didMount()
	self:setState({
		Width = self.frameRef.current.AbsoluteSize.X
	})
end

function Editor:render()
	local selection = self.props.Selection and #self.props.Selection == 1 and self.props.Selection[1]
	local width = self.state.Width

	return withTheme(function(theme)
		local currentTable = self.props.CurrentTable
		local currentInstance = self.props.CurrentInstance
		local instanceStates = self.props.InstanceStates

		local listItems = {}

		if currentTable then
			visitDescendants(currentInstance, function(instance)
				if instance == nil then return end
				local relativePath = PathUtils.RelativePath(currentInstance, instance)
				local id = instance:GetDebugId()
				local props = currentTable[relativePath]
				local state = instanceStates[id]
				if state then
					table.insert(listItems, {
						Type = "Instance",
						Instance = instance,
						Path = relativePath,
						Expanded = state.Expanded,
						Props = props ~= nil,
						Children = visitChildren(instance) > 0,
						Selected = selection == instance,
					})
					if state.Expanded then
						if props then
							for name in pairs(props) do
								table.insert(listItems, {
									Type = "Property",
									Instance = instance,
									Path = relativePath,
									Values = props[name],
									Name = name,
								})
							end
						end
					end
					return state.Expanded
				else
					return false
				end
			end)
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			Header = Roact.createElement(Header, {
			}),
			Body = Roact.createElement("Frame", {
				BackgroundColor3 = theme.backgroundColor,
				BorderColor3 = theme.header.border,
				BorderSizePixel = 1,
				Size = UDim2.new(1, 0, 1, -Constants.HEADER_HEIGHT),

				[Roact.Change.AbsoluteSize] = self.sizeChanged,
				[Roact.Ref] = self.frameRef,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 3)
				}),
				PropsList = Roact.createElement(PropsList, {
					CurrentInstance = self.props.CurrentInstance,
					ListItems = listItems,
				}),
				Timeline = Roact.createElement(Timeline, {
					CurrentTable = self.props.CurrentTable,
					Width = width,
					ListItems = listItems,
				}),
			}),
		})
	end)
end

return Editor
