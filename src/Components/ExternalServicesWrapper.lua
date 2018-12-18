--[[
	Top-level component that wraps several providers into one.
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local RoactRodux = require(Plugin.RoactRodux)

local ThemeProvider = require(Plugin.Src.Providers.ThemeProvider)

local function ExternalServicesWrapper(props)
	return Roact.createElement(RoactRodux.StoreProvider, {
		store = props.store
	}, {
		Roact.createElement(ThemeProvider, {
			theme = props.theme,
		}, props[Roact.Children])
	})
end

return ExternalServicesWrapper