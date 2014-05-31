-- This file should load all files in this category and sort them into place using their categories.
-- Meant to be run after every time a new background object has been added.

-- Goal: to generate lines like this:
--self:addToCategory( list["houses"], "house1.lua", 0, 0 )

local maxX, maxY = 22, 7	-- max number of tiles allowed per category:

local errors = {}
local results = {}
local files = love.filesystem.getDirectoryItems(".")

local cats = {} 	-- list of categories.
local layouts = {} 	-- list of categories.

function automaticSort()
	for k, file in pairs(files) do
		if file:match(".*lua$") and
				not file:match(".*automaticSort.*") and
				not file:match(".*main.*") then
			print(k, file)
			local img, coords, category = dofile(file)
			if not cats[category] then
				print("\tNew category:", category)
				layouts[category] = newLayout()
				-- list["misc"] = {}
				table.insert( results,
					"list[\"" .. category .. "\"] = {}" )
				cats[category] = {}
			end
			table.insert( cats[category], {coords=coords, name=file} )
		end
	end

	for name, cat in pairs(cats) do
		-- Sort the cagegory's objects by number of tiles. Large objects should be placed
		-- onto the layout before smaller objects
		table.sort(cat, sortByTileNumber)
		print( name )
		for i, object in ipairs( cat ) do
			print( "\t", object.name, #object.coords )
			local added = false
			for y = 0, maxY do
				for x = 0, maxX do
					if checkFit( layouts[name], object.coords, x, y ) then
						addToLayout( layouts[name], object.coords, x, y )
						table.insert( results,
							"self:addToCategory( list[\"" .. name.. "\"], \"" .. object.name .. "\", " .. x .. "," .. y .. ")" )
						added = true
						break
					end
				end
				if added then break end
			end
			if not added then
				table.insert( errors, "Could not add " .. object.name )
			end
		end
	end

	print("Resulting list: (Add this to BgObject:init())" )
	for k, v in ipairs(results) do
		print(v)
	end
	print("Errors list:")
	for k, v in ipairs(errors) do
		print(v)
	end
end

function newLayout()
	local l = {}
	for x = 0, maxX do
			l[x] = {}
		for y = 0, maxY do
			l[x][y] = '0'
		end
	end
	return l
end

function sortByTileNumber( a, b )
	if #a.coords > #b.coords then
		return true
	elseif #b.coords > #a.coords then
		return false
	else return false
	end
end

function checkFit( t, coords, x, y )
	for k, coord in pairs(coords) do
		if not t[coord.x + x] or not t[coord.x + x][coord.y + y] then return false end
		if t[coord.x + x][coord.y + y] ~= '0' then
			return false
		end
	end
	return true
end

function addToLayout( t, coords, x, y )
	for k, coord in pairs(coords) do
		t[coord.x + x][coord.y + y] = 1
	end
end
