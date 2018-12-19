--[[
	Changes the Tween table if a descendant was renamed
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SetExpandedItems = require(Plugin.Src.Actions.SetExpandedItems)

return function(oldPath, newPath)
	return function(store)
		local tweens = store:getState().Tweens.Tweens
		local expandedItems = store:getState().Status.ExpandedItems

		for name, tween in pairs(tweens) do
			for key, props in pairs(tween) do
				if key == oldPath then
					tweens = Cryo.Dictionary.join(tweens, {
						[name] = Cryo.Dictionary.join(tweens[name], {
							[oldPath] = Cryo.None,
							[newPath] = props,
						})
					})
					break
				end
			end
		end

		if expandedItems[oldPath] ~= nil then
			local oldSetting = expandedItems[oldPath]
			expandedItems = Cryo.Dictionary.join(expandedItems, {
				[oldPath] = Cryo.None,
				[newPath] = oldSetting,
			})
		end

		store:dispatch(SetExpandedItems(expandedItems))
		store:dispatch(SetTweens(tweens))
	end
end