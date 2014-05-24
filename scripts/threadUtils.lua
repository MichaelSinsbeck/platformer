
print = function( ... )
	local args = {...}
	if printChannel then
		local str = ""
		for k, v in pairs(args) do
			str = str .. "\t" .. v
		end
		printChannel:push(str)
	end
end
