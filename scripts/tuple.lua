--[[

	(...) -> tuple
	wrap(t, [n]) -> tuple

]]

local setmetatable, select, table, tostring =
	  setmetatable, select, table, tostring

setfenv(1, {})

local meta = {__type = 'tuple'}

local function wrap(t, n)
	t.n = n or t.n or #t
	setmetatable(t, meta)
	return t
end

local function new(...)
	return wrap({n=select('#',...),...})
end

function meta:__eq(other)
	if self.n ~= other.n then
		return false
	end
	for i=1,self.n do
		if self[i] ~= other[i] then
			return false
		end
	end
	return true
end

function meta:__tostring()
	local t = {}
	for i=1,self.n do
		t[i] = tostring(self[i])
	end
	return '('..table.concat(t, ', ', 1, self.n)..')'
end

local M = {
	meta = meta,
	wrap = wrap,
	new = new,
}

return setmetatable(M, {__call = function(_,...) return new(...) end})