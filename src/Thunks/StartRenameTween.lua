--[[
	Start renaming the current tween
]]

local Plugin = script.Parent.Parent.Parent
local SetPolling = require(Plugin.Src.Actions.SetPolling)

return function(instance, root)
	return function(store)
		store:dispatch(SetPolling({
			Value = "Name",
			Tween = store:getState().Tweens.CurrentTween,
		}))
	end
end