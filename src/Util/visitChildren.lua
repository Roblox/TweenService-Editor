local function VisitChildren(instance, func)
	local numChildren = 0
	for _, child in pairs(instance:GetChildren()) do
		if not (child:IsA("ModuleScript") or child:IsA("Script")) then
			numChildren = numChildren + 1
			if func then
				func(child)
			end
		end
	end
	return numChildren
end

return VisitChildren
