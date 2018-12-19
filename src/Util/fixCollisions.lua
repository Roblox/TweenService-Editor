local Plugin = script.Parent.Parent.Parent
local PathUtils = require(Plugin.Src.Util.PathUtils)

local function escape(str)
    return str:gsub("([^%w])", "")
end

local function FixCollisions(instance, root, path)
	instance.Name = escape(instance.Name)
	local ok = true
	for _, child in pairs(instance.Parent:GetChildren()) do
		if child.Name == instance.Name then
			if child ~= instance then
				ok = false
				break
			end
		end
	end
	if ok then
		return path
	end
	local i = 1
	repeat
		ok = false
		local newName = string.format("%s %i", instance.Name, i)
		if instance.Parent:FindFirstChild(newName) == nil then
			instance.Name = newName
			ok = true
		else
			i = i + 1
		end
	until ok
	return PathUtils.RelativePath(root, instance)
end

return FixCollisions
