
print = function( ... )
	local args = {...}
	if printChannel then
		local str = ""
		for k, v in pairs(args) do
			if type(v) == "table" then
				v = table.concat(v)
			end
			if type(v) ~= "function" and type(v) ~= "userdata" then
			str = str .. "\t" .. v
		end
		end
		printChannel:push(str)
	end
end
