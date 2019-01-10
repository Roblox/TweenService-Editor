local actionKey = newproxy(true)

getmetatable(actionKey).__tostring = function()
	return "Symbol(Plugin)"
end

return actionKey