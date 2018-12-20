--[[
	Adds a property to the current Tween table
]]

local Plugin = script.Parent.Parent.Parent
local Cryo = require(Plugin.Cryo)
local PathUtils = require(Plugin.Src.Util.PathUtils)
local SetTweens = require(Plugin.Src.Actions.SetTweens)
local SetPolling = require(Plugin.Src.Actions.SetPolling)

return function(instance, prop, root)
	return function(store)
		if instance == nil then
			return false
		end

		store:dispatch(SetPolling(Cryo.None))

		if instance:FindFirstChild(prop) then
			return false, "Property can't be added. Rename the selected instance."
		end

		local value
		if not pcall(function()
			value = instance[prop]
		end) then
			return false, (prop .. " is not a property of " .. instance.Name .. ".")
		end

		local tweens = store:getState().Tweens.Tweens
		local currentTween = store:getState().Tweens.CurrentTween
		local tweenTable = tweens[currentTween]

		local path = PathUtils.RelativePath(root, instance)

		if not tweenTable then
			return false
		end

		if tweenTable[path] == nil then
			tweenTable = Cryo.Dictionary.join(tweenTable, {
				[path] = {},
			})
		end

		if tweenTable[path][prop] ~= nil then
			return false, "Property already added." --Property already exists. Whoops.
		end

		tweenTable = Cryo.Dictionary.join(tweenTable, {
			[path] = Cryo.Dictionary.join(tweenTable[path], {
				[prop] = {
					InitialValue = value,
					Keyframes = {},
				}
			}),
		})

		tweens = Cryo.Dictionary.join(tweens, {
			[currentTween] = tweenTable,
		})

		store:dispatch(SetTweens(tweens))
		return true
	end
end