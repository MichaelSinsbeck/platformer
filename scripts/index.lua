--[[
	Indexing values by tuple keys, implemented as a hash tree
	Any array works as a key, even arrays with holes, provided keys.n is set
	or n is passed as parameter to get() and set().

	Procedural interface:
		set(t, keys, e, [n])
		get(t, keys, [n]) -> e

		values(t) -> iterator -> e

		t[k1][k2]...[kn][E] -> e

	Objectual interface:
		([t]) -> idx
		wrap(t) -> idx
		idx.index -> t

		idx[keys] = e			idx:set(keys, e, [n])
		idx[keys] -> e			idx:get(keys, [n]) -> e

		idx:values() -> iterator -> e

]]

local coroutine, pairs, next, select, setmetatable =
	  coroutine, pairs, next, select, setmetatable

setfenv(1, {})

local function const(name)
	return setmetatable({}, {__tostring = function() return name end})
end

local NIL = const'NIL'
local NAN = const'NAN'
local E = const'E'

local function tokey(k)
	return (k == nil and NIL) or (k ~= k and NAN) or k
end

local function fromkey(k)
	return (k == NAN and 0/0) or (k ~= NIL and k) or nil
end

local function add(t, keys, e, n)
	n = n or keys.n or #keys
	for i=1,n do
		local k = tokey(keys[i])
		if not t[k] then
			t[k] = {}
		end
		t = t[k]
	end
	t[E] = e
end

local function many(t)
	return next(t,next(t))
end

local function remove(t, keys, n)
	n = n or keys.n or #keys
	local lastt, cleart, cleark
	for i=1,n do
		local k = tokey(keys[i])
		local tk = t[k]
		if not tk then return end
		if many(tk) then
			cleart, cleark = nil,nil
		elseif not cleart then
			cleart, cleark = t,k
		end
		t = tk
	end
	if not t[E] then return end
	if cleart then
		cleart[cleark] = nil
	else
		t[E] = nil
	end
end

local function set(t, keys, e, n)
	if e ~= nil then
		add(t, keys, e, n)
	else
		remove(t, keys, n)
	end
end

local function get(t, keys, n)
	n = n or keys.n or #keys
	for i=1,n do
		t = t[tokey(keys[i])]
		if not t then return end
	end
	return t[E]
end

local function yield_values(t)
	for k,t in pairs(t) do
		if k == E then
			coroutine.yield(t)
		else
			yield_values(t)
		end
	end
end

local function values(t)
	return coroutine.wrap(yield_values), t
end

--objectual interface

local methods = {}
function methods:set(keys, e, n) set(self.index, keys, e, n) end
function methods:get(keys, n) return get(self.index, keys, n) end
function methods:values() return values(self.index) end

local meta = {__type = 'index'}
function meta:__index(k) return methods[k] or get(self.index, k) end
function meta:__newindex(k, v) return set(self.index, k, v) end

local function wrap(t)
	return setmetatable({index = t}, meta)
end

local M = {
	meta = meta,
	methods = methods,
	set = set,
	get = get,
	values = values,
	wrap = wrap,
}

return setmetatable(M, {__call = function(_,t) return wrap(t or {}) end})
