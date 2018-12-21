--[[
	The top level container of the TweenService Editor window.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local InstanceSelector = require(Plugin.Src.Components.InstanceSelector)
local Editor = require(Plugin.Src.Components.Editor)
local BottomDrawer = require(Plugin.Src.Components.BottomDrawer)
local Exporting = require(Plugin.Src.Util.Exporting)
local PathUtils = require(Plugin.Src.Util.PathUtils)
local AddProperty = require(Plugin.Src.Thunks.AddProperty)
local SaveAll = require(Plugin.Src.Thunks.SaveAll)
local SetTweenName = require(Plugin.Src.Thunks.SetTweenName)
local StartRenameTween = require(Plugin.Src.Thunks.StartRenameTween)
local DeleteTween = require(Plugin.Src.Thunks.DeleteTween)

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

	self.drawerFocusChanged = function(focused)
		if not focused and self.props.Polling then
			self.props.AddProperty(nil)
		end
	end

	self.drawerSubmitted = function(val)
		local polling = self.props.Polling
		if polling.Value == "Property" then
			self.props.AddProperty(polling.Instance, val, polling.Root)
		elseif polling.Value == "Name" then
			self.props.SetTweenName(val)
		end
	end

	self.headerButtonPressed = function(button)
		if button == "SaveAll" then
			self.props.SaveAll()
		elseif button == "Reload" then
			if self.props.CurrentInstance then
				self.props.InitializeEditor(self.props.CurrentInstance)
			end
		elseif button == "Rename" then
			self.props.StartRenameTween()
		elseif button == "Delete" then
			self.props.DeleteTween()
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
	local polling = self.props.Polling
	local currentInstance = self.props.CurrentInstance
	local selection = self.state.Selection
	local selectionDiffers, canImport = SelectionDiffers(currentInstance, selection)
	local editorOpen = currentInstance and not selectionDiffers

	return withTheme(function(theme)
		return Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = theme.backgroundColor,
		}, {
			Selector = (not editorOpen) and Roact.createElement(InstanceSelector, {
				Selection = selection,
				SelectionDiffers = selectionDiffers,
				CanImport = canImport or self.state.CanAnimate,
				CreateNew = self.initializeEditor,
			}),
			Editor = editorOpen and Roact.createElement(Editor, {
				CurrentTable = self.props.CurrentTable,
				CurrentInstance = currentInstance,
				Selection = selection,
				InstanceStates = self.props.InstanceStates,
				HeaderButtonPressed = self.headerButtonPressed,
			}),
			PollProperty = editorOpen and polling and polling.Value == "Property" and Roact.createElement(BottomDrawer, {
				Header = "Please enter the name of the Property to add to " .. polling.Path .. ":",
				FocusChanged = self.drawerFocusChanged,
				Submitted = self.drawerSubmitted,
				ButtonName = "Add",
			}),
			PollName = editorOpen and polling and polling.Value == "Name" and Roact.createElement(BottomDrawer, {
				Header = "Please enter the name of the new name for " .. polling.Tween .. ":",
				FocusChanged = self.drawerFocusChanged,
				Submitted = self.drawerSubmitted,
				ButtonName = "Rename",
			}),
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
			Polling = state.Status.Polling,
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
			AddProperty = function(instance, prop, root)
				local result, err = dispatch(AddProperty(instance, prop, root))
				if not result and err then
					warn(err)
				end
			end,
			SetTweenName = function(newName)
				dispatch(SetTweenName(newName))
			end,
			StartRenameTween = function()
				dispatch(StartRenameTween())
			end,
			DeleteTween = function()
				dispatch(DeleteTween())
			end,
			SaveAll = function()
				dispatch(SaveAll())
			end,
		}
	end
)(MainView)

return MainView