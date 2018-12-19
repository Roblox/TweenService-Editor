--[[
	The top level container of the TweenService Editor window.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local InstanceSelector = require(Plugin.Src.Components.InstanceSelector)
local Editor = require(Plugin.Src.Components.Editor)
local Exporting = require(Plugin.Src.Util.Exporting)
local PathUtils = require(Plugin.Src.Util.PathUtils)

local InitializeEditor = require(Plugin.Src.Thunks.InitializeEditor)
local DescendantRemoving = require(Plugin.Src.Thunks:WaitForChild'DescendantRemoving')
local DescendantAdded = require(Plugin.Src.Thunks:WaitForChild'DescendantAdded')

local MainView = Roact.PureComponent:extend("MainView")

function MainView:init()
	self.state = {
		Selection = game.Selection:Get(),
		CanAnimate = false,
	}

	self.selectionChanged = function()
		local selection = game.Selection:Get()
		local canAnimate = #selection == 1 and Exporting.GetAnimator(selection[1]) or false
		self:setState({
			Selection = selection,
			CanAnimate = canAnimate,
		})
	end

	self.initializeEditor = function(approved)
		if not approved then
			game.Selection:Set({self.props.CurrentInstance})
		else
			local selection = game.Selection:Get()
			local current = selection[1]
			if #selection == 1 then
				self.props.InitializeEditor(current)
			end
			if self.addedConnection then
				self.addedConnection:Disconnect()
			end
			if self.removedConnection then
				self.removedConnection:Disconnect()
			end
			self.addedConnection = current.DescendantAdded:Connect(function(instance)
				self.props.DescendantAdded(instance, self.props.CurrentInstance, instance:GetDebugId())
			end)
			self.removedConnection = current.DescendantRemoving:Connect(function(instance)
				self.props.DescendantRemoving(PathUtils.RelativePath(
					self.props.CurrentInstance, instance), instance:GetDebugId())
			end)
		end
	end

	self.selectionConnection = game.Selection.SelectionChanged:Connect(self.selectionChanged)
	self.addedConnection = nil
	self.removedConnection = nil
	self.selectionChanged()
end

function MainView:willUnmount()
	self.selectionConnection:Disconnect()
	if self.addedConnection then
		self.addedConnection:Disconnect()
	end
	if self.removedConnection then
		self.removedConnection:Disconnect()
	end
end

local function SelectionDiffers(currentInstance, selection)
	if currentInstance == nil then
		return false, false
	end
	if #selection == 1 then
		local animator = Exporting.GetAnimator(selection[1])
		if animator then
			return animator.Parent ~= currentInstance, true
		else
			return true, false
		end
	end
	return false, false
end

function MainView:render(props)
	local currentInstance = self.props.CurrentInstance
	local selection = self.state.Selection
	local selectionDiffers, canImport = SelectionDiffers(currentInstance, selection)

	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = theme.backgroundColor,
		}, {
			Selector = (not currentInstance or selectionDiffers) and Roact.createElement(InstanceSelector, {
				Selection = selection,
				SelectionDiffers = selectionDiffers,
				CanImport = canImport or self.state.CanAnimate,
				CreateNew = self.initializeEditor,
			}),
			Editor = currentInstance and not selectionDiffers and Roact.createElement(Editor, {
				CurrentTable = self.props.CurrentTable,
				CurrentInstance = currentInstance,
				Selection = selection,
				InstanceStates = self.props.InstanceStates,
			})
		})
	end)
end

MainView = RoactRodux.connect(
	function(state, props)
		if not state then return end
		return {
			CurrentInstance = state.Status.CurrentInstance,
			CurrentTable = state.Tweens.Tweens and state.Tweens.Tweens[state.Tweens.CurrentTween],
			InstanceStates = state.Status.InstanceStates,
		}
	end,
	function(dispatch)
		return {
			InitializeEditor = function(instance)
				dispatch(InitializeEditor(instance))
			end,
			DescendantRemoving = function(path, id)
				dispatch(DescendantRemoving(path, id))
			end,
			DescendantAdded = function(instance, root, id)
				dispatch(DescendantAdded(instance, root, id))
			end,
		}
	end
)(MainView)

return MainView