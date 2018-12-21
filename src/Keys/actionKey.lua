local actionKey = newproxy(true)

getmetatable(actionKey).__tostring = function()
	return "Symbol(Action)"
end

return actionKey