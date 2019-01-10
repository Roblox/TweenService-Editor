--[[
	Writes a tween to a ModuleScript.

	Params:
		table tweenTable = The table to write
	Returns:
		ModuleScript
--]]

local function prettyPrint(val)
	if typeof(val) == "CFrame" then
		return string.format("CFrame.new(%s)", tostring(val))
	elseif typeof(val) == "Vector3" or typeof(val) == "Vector3int16" then
		return string.format("Vector3.new(%s)", tostring(val))
	elseif typeof(val) == "Vector2" then
		return string.format("Vector2.new(%s)", tostring(val))
	elseif typeof(val) == "Rect" then
		return string.format("Rect.new(%s)", tostring(val))
	elseif typeof(val) == "Color3" then
		return string.format("Color3.new(%s)", tostring(val))
	elseif typeof(val) == "UDim" then
		return string.format("UDim.new(%s, %s)", val.Scale, val.Offset)
	elseif typeof(val) == "UDim2" then
		return string.format("UDim2.new(%s, %s, %s, %s)", val.X.Scale, val.X.Offset, val.Y.Scale, val.Y.Offset)
	else
		return tostring(val)
	end
end

local function addLine(indent, str1, str2)
	return str1 .. string.rep("\t", indent) .. str2 .. "\n"
end

local function addLineOpen(indent, str1, str2)
	return str1 .. string.rep("\t", indent) .. str2 .. "\n", indent + 1
end

local function addLineClose(indent, str1, addComma)
	indent = indent - 1
	return str1 .. string.rep("\t", indent) .. string.format("}%s\n", addComma and "," or ""), indent
end

local function WriteTween(tweenTable, name)
	local tween = "return {\n"
	local indent = 1

	for instance, props in pairs(tweenTable) do
		tween, indent = addLineOpen(indent, tween, string.format("[\"%s\"] = {", instance))
		for name, prop in pairs(props) do
			tween, indent = addLineOpen(indent, tween, string.format("%s = {", name))
			tween = addLine(indent, tween, string.format("InitialValue = %s,", prettyPrint(prop.InitialValue)))
			tween, indent = addLineOpen(indent, tween, "Keyframes = {")
				for _, keyframe in pairs(prop.Keyframes) do
					tween, indent = addLineOpen(indent, tween, "{")
					for key, value in pairs(keyframe) do
						tween = addLine(indent, tween, string.format("%s = %s,", key, prettyPrint(value)))
					end
					tween, indent = addLineClose(indent, tween, true)
				end
			tween, indent = addLineClose(indent, tween, true)
			tween, indent = addLineClose(indent, tween, true)
		end
		tween, indent = addLineClose(indent, tween, true)
	end

	tween = addLineClose(indent, tween)

	local mod = Instance.new("ModuleScript")
	mod.Source = tween
	mod.Name = name
	return mod
end

return WriteTween