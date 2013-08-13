-- miscellaneous functions:

function tableFind( tbl, value )
	for k,v in pairs(tbl) do
		if v == value then return k end
	end
	return nil
end
