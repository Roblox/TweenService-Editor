--[[
	Props:
		Scale
		Start
		Width
		Playhead
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local Constants = require(Plugin.Src.Util.Constants)
--local getMouse = require(Plugin.Src.Consumers.getMouse)
local TimelineTick = require(Plugin.Src.Components.TimelineTick)

local TimelineScale = Roact.PureComponent:extend("TimelineScale")

function TimelineScale:init()
	self.frameRef = Roact.createRef()
	self.dragging = false

	self.reportMousePos = function(input, doneDragging)
		local scale = self.props.Scale
		local start = self.props.Start

		local xpos = input.Position.X - self.frameRef.current.AbsolutePosition.X
		local scaled = (xpos / (scale * 10)) + start

		scaled = math.floor((scaled * 10) + 0.5) / 10
		self.props.OnDrag(scaled, doneDragging)
	end

	self.inputBegan = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.dragging = true
		end
	end

	self.inputEnded = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.dragging = false
			self.reportMousePos(input, true)
		end
	end

	self.inputChanged = function(rbx, input)
		if self.dragging then
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				self.reportMousePos(input, false)
			end
		end
	end
end

local function closeTo(num, otherNum)
	return math.abs(num - otherNum) < 0.01
end

function TimelineScale:render()
	return withTheme(function(theme)
		local scale = self.props.Scale
		local start = self.props.Start
		local width = self.props.Width
		local playhead = self.props.Playhead

		local ticks = {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, scale)
			}),
		}
		local j = start
		for i = 1, width / scale do
			table.insert(ticks, Roact.createElement(TimelineTick, {
				LayoutOrder = i,
				Time = j * 0.1,
				Playhead = (closeTo(j * 0.1, playhead)),
				Scale = scale,
			}))
			j = j + 1
		end

		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, Constants.TIMELINE_PADDING, 0, 0),
			BackgroundTransparency = 1,

			[Roact.Ref] = self.frameRef,
			[Roact.Event.InputChanged] = self.inputChanged,
			[Roact.Event.InputBegan] = self.inputBegan,
			[Roact.Event.InputEnded] = self.inputEnded,
		}, ticks)
	end)
end

return TimelineScale
