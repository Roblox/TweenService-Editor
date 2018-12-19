--[[
	Changes the Tween table if a descendant was added
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetExpandedItems = require(Plugin.Src.Actions.SetExpandedItems)

return function(path)
	return function(store)
		local expandedItems = store:getState().Status.ExpandedItems

		if expandedItems[path] == nil then
			expandedItems = Cryo.Dictionary.join(expandedItems, {
				[path] = false,
			})
		end

		store:dispatch(SetExpandedItems(expandedItems))
	end
end