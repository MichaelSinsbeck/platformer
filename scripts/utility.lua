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

function newProperty(values, names, default)
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

function newCycleProperty(values, names, default)
	local newProp = newProperty(values, names, default)
	newProp.cycle = true
	return newProp
end
