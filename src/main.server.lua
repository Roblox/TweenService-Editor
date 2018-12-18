local ICON = "rbxassetid://2658642540"
local DOCK_WIDGET_INFO = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Bottom,
	false, false, 800, 250, 400, 200
)
local LOG_STORE_STATE_AND_EVENTS = false

local Plugin = script.Parent.Parent
local Roact = require(Plugin.Roact)
local Rodux = require(Plugin.Rodux)
local ExternalServicesWrapper = require(Plugin.Src.Components.ExternalServicesWrapper)
local MainReducer = require(Plugin.Src.Reducers.MainReducer)
local MainView = require(Plugin.Src.Components.MainView)
local Theme = require(Plugin.Src.Util.Theme)
local SetIsOpen = require(Plugin.Src.Actions.SetIsOpen)

local pluginGui
local tweenEditorHandle

local middlewares = {Rodux.thunkMiddleware}
if LOG_STORE_STATE_AND_EVENTS then
	table.insert(middlewares, Rodux.loggerMiddleware)
end

local mainStore = Rodux.Store.new(MainReducer, nil, middlewares)

local function closeTweenEditor()
	mainStore:dispatch(SetIsOpen(false))

	if tweenEditorHandle then
		Roact.unmount(tweenEditorHandle)
	end
end

local function openTweenEditor()
	local servicesProvider = Roact.createElement(ExternalServicesWrapper, {
		store = mainStore,
		theme = Theme.new(),
		mouse = plugin:GetMouse()
	}, {
		mainView = Roact.createElement(MainView),
	})

	mainStore:dispatch(SetIsOpen(true))

	tweenEditorHandle = Roact.mount(servicesProvider, pluginGui)
	pluginGui.Enabled = true
end

local function toggleView()
	pluginGui.Enabled = not pluginGui.Enabled
	if pluginGui.Enabled then
		openTweenEditor()
	else
		closeTweenEditor()
	end
end

local function main()
	pluginGui = plugin:CreateDockWidgetPluginGui("TweenSequenceEditor", DOCK_WIDGET_INFO)
	pluginGui.Title = "TweenSequence Editor"
	plugin.Name = "TweenSequenceEditor"

	local toolbar = plugin:CreateToolbar("TweenService")
	local mainButton = toolbar:CreateButton(
		"TweenSequence Editor",
		"Easily create Tweens to animate objects using a visual editor",
		ICON
	)

	mainButton:SetActive(pluginGui.Enabled)
	pluginGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		mainButton:SetActive(pluginGui.Enabled)
	end)

	mainButton.Enabled = true
	mainButton.Click:connect(toggleView)

	if pluginGui.Enabled then
		openTweenEditor()
	else
		closeTweenEditor()
	end
end

main()