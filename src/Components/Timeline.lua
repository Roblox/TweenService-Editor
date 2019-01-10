--[[
	Props:
		CurrentTable = The current tween table.
		CurrentInstance
		InstanceStates
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)
local ListItem = require(Plugin.Src.Components.ListItem)
local TimelineScale = require(Plugin.Src.Components.TimelineScale)
local SelectKeyframe = require(Plugin.Src.Thunks.SelectKeyframe)
local DeleteSelectedKeyframe = require(Plugin.Src.Thunks.DeleteSelectedKeyframe)
local MoveKeyframe = require(Plugin.Src.Thunks.MoveKeyframe)
local CopyKeyframe = require(Plugin.Src.Thunks.CopyKeyframe)
local PasteKeyframe = require(Plugin.Src.Thunks.PasteKeyframe)
local SetPlayhead = require(Plugin.Src.Actions.SetPlayhead)
local Keyframe = require(Plugin.Src.Components.Keyframe)
local clamp = require(Plugin.Src.Util.clamp)
local getActions = require(Plugin.Src.Consumers.getActions)
local UpdateInstances = require(Plugin.Src.Thunks.UpdateInstances)

local Timeline = Roact.PureComponent:extend("Timeline")

function Timeline:init()
	self.iterator = 0
	self.iterator2 = 0
	self.listItems = nil
	self.middleMouseDragging = false
	self.state = {
		Scale = 50,
		Start = 0,
	}

	self.dragPlayhead = function(time, doneDragging)
		self.props.SetPlayhead(time)
	end

	self.dragStart = function(move)
		local start = self.state.Start
		if self.middleMouseDragging then
			self:setState({
				Start = clamp(start - move, 0, 600)
			})
		end
	end

	self.inputChanged = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local scale = self.state.Scale
			local newScale = clamp(scale + input.Position.Z * 2, 20, 200)
			self:setState({
				Scale = newScale
			})
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			local move = math.floor(input.Delta.X * 10) / 10
			self.dragStart(move)
		end
	end

	self.inputBegan = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton3 then
			self.middleMouseDragging = true
		end
	end

	self.inputEnded = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton3 then
			self.middleMouseDragging = false
		end
	end

	self.deleteConnection = getActions(self).DeleteKeyframe.Triggered:Connect(function()
		self.props.DeleteSelectedKeyframe()
	end)
	self.copyConnection = getActions(self).CopyKeyframe.Triggered:Connect(function()
		self.props.CopyKeyframe()
	end)
	self.pasteConnection = getActions(self).PasteKeyframe.Triggered:Connect(function()
		self.props.PasteKeyframe()
	end)
end

function Timeline:willUnmount()
	if self.deleteConnection then
		self.deleteConnection:Disconnect()
	end
	self.props.SetPlayhead(0)
end

function Timeline:MakeKeyframe(kf, item, scale, start, index, time)
	local selected = false
	if kf then
		if kf.Path == item.Path and kf.Prop == item.Name and kf.Index == index then
			selected = true
		end
	end
	return Roact.createElement(Keyframe, {
		Scale = scale,
		Time = time,
		Start = start,
		Selected = selected,
		Clipboard = self.props.Clipboard ~= nil,
		OnClick = function()
			self.props.SelectKeyframe(item.Path, item.Name, index)
		end,
		OnDragEnded = function(newTime)
			self.props.MoveKeyframe(item.Path, item.Name, index, newTime)
		end
	})
end

function Timeline:AddPropertyItem(item)
	local i = self.iterator
	local j = self.iterator2
	local kf = self.props.SelectedKeyframe

	local keyframes = {}
	table.insert(keyframes, self:MakeKeyframe(kf, item,
		self.state.Scale, self.state.Start, 0, 0))
	for i, keyframe in ipairs(item.Values.Keyframes) do
		table.insert(keyframes, self:MakeKeyframe(kf, item,
			self.state.Scale, self.state.Start, i, keyframe.Time))
	end

	self.listItems[item.Instance:GetDebugId() .. " " .. item.Name] = Roact.createElement(ListItem, {
		LighterColor = j % 2 == 0,
		LayoutOrder = i,
	}, keyframes)
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
		local scale = self.state.Scale
		local start = self.state.Start
		local startIndex = self.props.StartIndex

		self.listItems = {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			Topbar = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundColor3 = theme.timeline.background,
				BorderSizePixel = 0,
				LayoutOrder = 0,
			}),
		}

		for i, item in ipairs(self.props.ListItems) do
			if i >= startIndex then
				if item.Type == "Property" then
					self:AddPropertyItem(item)
				elseif item.Type == "Instance" then
					self:AddInstanceItem(item.Instance, item.Selected, theme.listItem.na)
				end
			end
		end

		self:AddSeparator(theme.propsList.border)

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 0,
			BackgroundColor3 = theme.listItem.na,
			ClipsDescendants = true,
			LayoutOrder = 2,

			[Roact.Event.InputChanged] = self.inputChanged,
			[Roact.Event.InputBegan] = self.inputBegan,
			[Roact.Event.InputEnded] = self.inputEnded,
		}, {
			Scale = Roact.createElement(TimelineScale, {
				Scale = scale,
				Start = start,
				Width = self.props.Width,
				Playhead = self.props.Playhead,
				OnDrag = self.dragPlayhead,
				Clipboard = self.props.Clipboard ~= nil,
			}),
			List = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0)
			}, self.listItems)
		})
	end)
end

Timeline = RoactRodux.connect(
	function(state, props)
		if not state then return end
		return {
			Playhead = state.Status.Playhead,
			SelectedKeyframe = state.Status.SelectedKeyframe,
			Clipboard = state.Status.Clipboard,
		}
	end,
	function(dispatch)
		return {
			SelectKeyframe = function(path, prop, time)
				dispatch(SelectKeyframe(path, prop, time))
			end,
			SetPlayhead = function(playhead)
				dispatch(SetPlayhead(playhead))
				dispatch(SelectKeyframe(nil))
				dispatch(UpdateInstances())
			end,
			DeleteSelectedKeyframe = function()
				dispatch(DeleteSelectedKeyframe())
			end,
			CopyKeyframe = function()
				dispatch(CopyKeyframe())
			end,
			PasteKeyframe = function()
				dispatch(PasteKeyframe())
			end,
			MoveKeyframe = function(path, prop, index, newTime)
				dispatch(MoveKeyframe(path, prop, index, newTime))
			end,
		}
	end
)(Timeline)

return Timeline
