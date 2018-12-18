--[[
	Reducer that combines the Tweens and Status reducers.
]]

local Plugin = script.Parent.Parent.Parent
local Rodux = require(Plugin.Rodux)

local Status = require(Plugin.Src.Reducers.Status)
local Tweens = require(Plugin.Src.Reducers.Tweens)

return Rodux.combineReducers({
	Status = Status,
    Tweens = Tweens,
})