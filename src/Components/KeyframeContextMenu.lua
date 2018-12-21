--[[
	Props:
		Position
		Size
		Active
		Text
]]

local Plugin = script.Parent.Parent.Parent
local Roact = require(Plugin.Roact)
local withTheme = require(Plugin.Src.Consumers.withTheme)
--local getMouse = require(Plugin.Src.Consumers.getMouse)

local KeyframeContextMenu = Roact.PureComponent:extend("KeyframeContextMenu")

function KeyframeContextMenu:render()
	return withTheme(function(theme)
		return Roact.createElement("Frame", {
		})
	end)
end

return KeyframeContextMenu
