local PathUtils = {}

local function Split(str)
	local names = {}

	for name in str:gmatch("[^.]+") do
		table.insert(names, name)
	end

	return names
end

function PathUtils.RelativePath(root, instance)
	local path = instance.Name
	while instance ~= root do
		instance = instance.Parent
		path = string.format("%s.%s",instance.Name, path)
	end
	return path
end

function PathUtils.StepsFromRoot(path)
	local steps = select(2, string.gsub(path, "%.", "."))
	return steps
end

function PathUtils.FinalName(path)
	local splitPath = Split(path)
	return splitPath[#splitPath]
end

return PathUtils