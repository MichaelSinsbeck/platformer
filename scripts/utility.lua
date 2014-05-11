utility = {}

-- Source http://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
function utility.copy(t, deep, seen)
    seen = seen or {}
    if t == nil then return nil end
    if seen[t] then return seen[t] end

    local nt = {}
    for k, v in pairs(t) do
        if deep and type(v) == 'table' then
            nt[k] = utility.copy(v, deep, seen)
        else
            nt[k] = v
        end
    end
    setmetatable(nt, utility.copy(getmetatable(t), deep, seen))
    seen[t] = nt
    return nt
end

function utility.pyth(dx,dy)
	return math.sqrt(dx^2+dy^2)
end

function utility.directions(collisionResult)
	local right = (collisionResult%2 == 1)
	local left = (math.floor(collisionResult/2)%2 == 1)
	local up = (math.floor(collisionResult/4)%2 == 1)
	local down = collisionResult >= 8
	return right, left, up, down
end

function utility.newProperty(values, names, default)
	local newProp = {}
	newProp.values = values
	names = names or values
	newProp.names = {}
	for i,v in ipairs(values) do
		newProp.names[v] = names[i]
	end
	newProp.default = default or 1
	newProp.cycle = false
	return newProp
end

function utility.newCycleProperty(values, names, default)
	local newProp = utility.newProperty(values, names, default)
	newProp.cycle = true
	return newProp
end

-- miscellaneous functions:

function utility.tableFind( tbl, value )
	for k,v in pairs(tbl) do
		if v == value then return k end
	end
	return nil
end


-- prints tables recursively with nice indentation.
function utility.tablePrint( tbl, level )
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
function utility.tablePrintBooleans( tbl )
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

function utility.isInteger(number)
	return number == math.floor(number)
end
