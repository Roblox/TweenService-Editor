--[[
	Props:
		Scale
		Start
		Width
		Selected
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local Constants = require(Plugin.Src.Util.Constants)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local Keyframe = Roact.PureComponent:extend("Keyframe")

function Keyframe:init()
	self.dragging = false
	self.state = {
		TimeDrag = nil,
		Dragging = false
	}

	self.buttonRef = Roact.createRef()
	self.frameRef = Roact.createRef()

	self.reportMousePos = function(input, doneDragging, offset)
		if doneDragging then
			if self.state.TimeDrag then
				self.props.OnDragEnded(self.state.TimeDrag)
			end
		else
			local scale = self.props.Scale
			local start = self.props.Start

			local xpos = input.Position.X - offset
			local scaled = (xpos / (scale * 10)) + start

			scaled = math.floor((scaled * 10) + 0.5) / 10

			self:setState({
				TimeDrag = scaled,
			})
		end
	end

	self.inputChanged = function(rbx, input)
		if self.state.Dragging then
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				self.reportMousePos(input, false, rbx.AbsolutePosition.X)
			end
		end
	end

	self.inputBegan = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.props.OnClick()
			if self.props.Time == 0 then
				return
			end
			self:setState({
				Dragging = true,
				TimeDrag = self.props.Time,
			})
		end
	end

	self.inputEnded = function(rbx, input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.reportMousePos(input, true, rbx.AbsolutePosition.X)
			wait()
			self:setState({
				Dragging = false,
				TimeDrag = Roact.None,
			})
		end
	end
end

function Keyframe:render()
	return withTheme(function(theme)
		local scale = self.props.Scale
		local start = self.props.Start
		local time = (self.state.Dragging and self.state.TimeDrag) or self.props.Time
		local selected = self.props.Selected

		local xpos = start + (time * (scale * 10)) + Constants.TIMELINE_PADDING

		return Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
		}, {
			Ghost = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				ZIndex = 3,
				Visible = self.state.Dragging,

				[Roact.Ref] = self.frameRef,

				[Roact.Event.InputChanged] = self.inputChanged,
			}),
			Button = Roact.createElement("ImageButton", {
				Size = UDim2.new(0, 13, 0, 13),
				ImageTransparency = 1,
				Rotation = 45,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 0,
				Position = UDim2.new(0, xpos, 0.5, 0),
				BorderSizePixel = 2,
				BorderColor3 = selected and theme.keyframe.selected.border or theme.keyframe.border,
				BackgroundColor3 = selected and theme.keyframe.selected.background or theme.keyframe.background,

				[Roact.Ref] = self.buttonRef,
				[Roact.Event.InputBegan] = self.inputBegan,
				[Roact.Event.InputEnded] = self.inputEnded,
				ZIndex = 3,
			}),
		})
	end)
end

return Keyframe
