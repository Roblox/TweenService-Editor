local function Clamp(val, minimum, maximum)
	if val > maximum then
		return maximum
	end
	if val < minimum then
		return minimum
	end
	return val
end

return Clamp
