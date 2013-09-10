-- miscellaneous functions:

function tableFind( tbl, value )
	for k,v in pairs(tbl) do
		if v == value then return k end
	end
	return nil
end


-- prints tables recursively with nice indentation.
function tablePrint( tbl, level )
	level = level or 1
	if level > 5 then return end	-- beware of loops!
	
	local indentation = string.rep("\t", level)
	for k, v in pairs( tbl ) do 
		if type(v) == "table" then
			print (indentation, k .. " = {")
			tablePrint( v, level + 1 )
			print( indentation, "}")
		else
			print( indentation, k," =", v)
		end
	end
end
function tablePrintBooleans( tbl )
	for i = 1, #tbl do
		str = ""
		for j = 1, #tbl[i] do
			if tbl[i][j].solid then
				str = str .. "1 "
			else
				str = str .. "  "
			end
		end
		print(str)
	end
end
