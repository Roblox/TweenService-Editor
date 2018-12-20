--[[
	Removes a property from the current Tween table
	TODO: Confirmation popup
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local PathUtils = require(Plugin.Src.Util.PathUtils)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local isEmpty = require(Plugin.Src.Util.isEmpty)

return function(instance, prop, root)
	return function(store)
		local tweens = store:getState().Tweens.Tweens
		local currentTween = store:getState().Tweens.CurrentTween
		local tweenTable = tweens[currentTween]

		local path = PathUtils.RelativePath(root, instance)

		if not tweenTable then
			return
		end

		for key, props in pairs(tweenTable) do
			if key == path then
				for propName, _ in pairs(props) do
					if propName == prop then
						tweenTable = Cryo.Dictionary.join(tweenTable, {
							[path] = Cryo.Dictionary.join(tweenTable[path], {
								[prop] = Cryo.None,
							})
						})
						if isEmpty(tweenTable[path]) then
							tweenTable = Cryo.Dictionary.join(tweenTable, {
								[path] = Cryo.None,
							})
						end
						break
					end
				end
				break
			end
		end

		tweens = Cryo.Dictionary.join(tweens, {
			[currentTween] = tweenTable,
		})

		store:dispatch(SetTweens(tweens))
	end
end