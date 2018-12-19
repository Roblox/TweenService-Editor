local function VisitDescendants(instance, func)
	if instance:IsA("ModuleScript") or instance:IsA("Script") then
		return
	end
	local continue = func(instance)
	if continue == nil or continue then
		for _, ch in pairs(instance:GetChildren()) do
			VisitDescendants(ch, func)
		end
	end
end

return VisitDescendants
