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
