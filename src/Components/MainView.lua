--[[
	The top level container of the TweenService Editor window.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)
local withTheme = require(Plugin.Src.Consumers.withTheme)
local InstanceSelector = require(Plugin.Src.Components.InstanceSelector)
local Exporting = require(Plugin.Src.Util.Exporting)
local InitializeEditor = require(Plugin.Src.Thunks.InitializeEditor)

local MainView = Roact.PureComponent:extend("MainView")

function MainView:init()
	self.state = {
		Selection = game.Selection:Get(),
		CanAnimate = false,
	}

	self.initializeEditor = function(approved)
		if not approved then
			game.Selection:Set({self.props.CurrentInstance})
		else
			local selection = game.Selection:Get()
			if #selection == 1 then
				self.props.InitializeEditor(selection[1])
			end
		end
	end

	self.selectionChanged = function()
		local selection = game.Selection:Get()
		local canAnimate = #selection == 1 and Exporting.GetAnimator(selection[1]) or false
		self:setState({
			Selection = selection,
			CanAnimate = canAnimate,
		})
	end

	self.selectionConnection = game.Selection.SelectionChanged:Connect(self.selectionChanged)
	self.selectionChanged()
end

function MainView:willUnmount()
	self.selectionConnection:Disconnect()
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
			TextLabel = currentInstance and Roact.createElement("TextLabel", {
				Text = "Blah"
			})
		})
	end)
end

MainView = RoactRodux.connect(
	function(state, props)
		if not state then return end
		return {
			CurrentInstance = state.Status.CurrentInstance,
		}
	end,
	function(dispatch)
		return {
			InitializeEditor = function(instance)
				dispatch(InitializeEditor(instance))
			end,
		}
	end
)(MainView)

return MainView