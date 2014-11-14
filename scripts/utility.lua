utility = {}

utility.bandana2color = {
white = {255,255,255},
yellow = {255,255,0},
green = {0,212,0},
blue = {40,90,160},
red = {212,0,0},
}

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
function utility.newTextProperty()
	local newProp = {}
	newProp.values = {""}
	newProp.default = 1
	newProp.isTextProperty = true
	return newProp
end
function utility.newNumericTextProperty( default, min, max )
	local newProp = {}
	newProp.values = { default }
	newProp.default = 1
	newProp.isNumericTextProperty = true
	newProp.max = max
	newProp.min = min
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


-- Returns the coordinates of a char (often the cursor) in a multi-lined text
-- if the character is the num-th character in the text:
function utility.getCharPos( wrappedLines, num )
	local i = 0
	local x, y = 0,0
	for k, l in ipairs( wrappedLines ) do
		if i + #l >= num then
			num = num - i
			x = fontSmall:getWidth( l:sub(1, num) )
			y = k*fontSmall:getHeight()
		else
			i = i + #l
		end
	end
	return x, y
end


function utility.wrap( front, back, width )
	local lines = {}
	local plain = front .. back .. "\n"
	local num = #front
	for line in plain:gmatch( "([^\n]-\n)" ) do
		table.insert( lines, line )
	end

	local wLines = {}	-- lines that have been wrapped
	local shortLine
	local restLine
	local word = "[^ ]* "	-- not space followed by space
	local tmpLine
	local letter = "[%z\1-\127\194-\244][\128-\191]*"

	for k, line in ipairs(lines) do
		if fontSmall:getWidth( line ) <= width then
			table.insert( wLines, line )
		else
			restLine = line .. " " -- start with full line
			while #restLine > 0 do
				local i = 1
				local breakingCondition = false
				tmpLine = nil
				shortLine = nil
				repeat		-- look for spaces!
					tmpLine = restLine:match( word:rep(i) )
					if tmpLine then
						if fontSmall:getWidth(tmpLine) > width then
							breakingCondition = true
						else
							shortLine = tmpLine
						end
					else
						breakingCondition = true
					end
					i = i + 1
				until breakingCondition
				if not shortLine then -- if there weren't enough spaces then:
					breakingCondition = false
					i = 1
					repeat			-- ... look for letters:
						tmpLine = restLine:match( letter:rep(i) )
						if tmpLine then
							if fontSmall:getWidth(tmpLine) > width then
								breakingCondition = true
							else
								shortLine = tmpLine
							end
						else
							breakingCondition = true
						end
						i = i + 1
					until breakingCondition
				end
				table.insert( wLines, shortLine )
				restLine = restLine:sub( #shortLine+1 )
			end
		end
	end

	local cursorX, cursorY = utility.getCharPos( wLines, num )
	return wLines, cursorX, cursorY
end


function utility.interpolateCos( rel )
	return -math.cos(math.pi*rel)*0.5 + 0.5
end
