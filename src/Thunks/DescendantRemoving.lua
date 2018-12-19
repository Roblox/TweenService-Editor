--[[
	Changes the Tween table if a descendant was removed
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SetExpandedItems = require(Plugin.Src.Actions.SetExpandedItems)

return function(path)
	return function(store)
		local tweens = store:getState().Tweens.Tweens
		local expandedItems = store:getState().Status.ExpandedItems

		for name, tween in pairs(tweens) do
			for key, _ in pairs(tween) do
				if key == path then
					tweens = Cryo.Dictionary.join(tweens, {
						[name] = Cryo.Dictionary.join(tweens[name], {
							[key] = Cryo.None,
						})
					})
					break
				end
			end
		end

		if expandedItems[path] ~= nil then
			expandedItems = Cryo.Dictionary.join(expandedItems, {
				[path] = Cryo.None,
			})
		end

		store:dispatch(SetExpandedItems(expandedItems))
		store:dispatch(SetTweens(tweens))
	end
end