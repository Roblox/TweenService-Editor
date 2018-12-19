local function VisitDescendants(instance, func)
	if instance:IsA("ModuleScript") or instance:IsA("Script") then
		return
	end
	func(instance)
	for _, ch in pairs(instance:GetChildren()) do
		VisitDescendants(ch, func)
	end
end

return VisitDescendants
