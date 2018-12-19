local PathUtils = {}

local function escape(str)
    return str:gsub("([^%w])", "%%%1")
end

local function Split(str)
	local names = {}

	for name in str:gmatch("[^.]+") do
		table.insert(names, name)
	end

	return names
end

function PathUtils.RelativePath(root, instance)
	local path = instance.Name
	while instance ~= root and instance ~= nil do
		instance = instance.Parent
		if instance ~= nil then
			path = instance.Name .. "." .. path
		else
			return nil
		end
	end
	return path
end

function PathUtils.Replace(str, oldPath, newPath)
	newPath = escape(newPath)
	oldPath = escape(oldPath)
	return string.gsub(str, oldPath, newPath)
end

function PathUtils.StepsFromRoot(path)
	local steps = select(2, string.gsub(path, "%.", "."))
	return steps
end

function PathUtils.Contains(path1, path2)
	return string.find(path1, path2) ~= nil
end

function PathUtils.FinalName(path)
	local splitPath = Split(path)
	return splitPath[#splitPath]
end

return PathUtils