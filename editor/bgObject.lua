-------------------------------------------
-- Background Objects for the map
-------------------------------------------
-- Background objects can consist of an arbitary number of tiles.
-- Each background object knows what tilesheet its tiles are from and
-- how to place them onto the map.
-- 
-- A background object can either be a single rectangle or multiple ones.
-- The coords given through tilelist are tables containing:
-- tileX, tileY, x, y. tileX and tileY give the coordinates of the square on
-- the tile map, x and y give the rendering position.
-- x and y MUST start at 0 for the lowest tiles, tileX and tileY are relative
-- to the upper left corner of the corresponding tilesheet.
--
local CATEGORY_HOUSES = "houses"
local CATEGORY_MISC = "misc"
local CATEGORY_GARDEN = "garden"
local CATEGORY_STATUES = "statues"
local CATEGORY_TREES = "trees"

local categories = {}
categories[CATEGORY_HOUSES] = {
	roof = [[7x5, 7x6, 1x7, 2x7, 3x7, 4x7, 5x7, 6x7, 7x7,
			1x8, 2x8, 3x8, 4x8, 5x8, 6x8, 7x8,
			3x9, 4x9, 5x9, 1x11, 2x11,
			3x14, 4x14, 5x14, 6x14, 7x15,
			0x15, 1x15, 2x15, 3x15, 4x15,
			2x16, 3x16, 4x16, 5x16, 6x16, 7x16
			3x17, 4x17, 5x17, 6x17,
			0x27, 1x27,
			]],
	wall = [[2x9, 6x9, 7x9,
			3x10, 4x10, 5x10, 6x10, 7x10,
			3x11, 4x11, 5x11, 6x11, 7x11,
			5x12, 6x12, 7x12
			5x13, 6x13, 7x13
			1x14, 2x14, 0x12, 0x11
			]],
	door = [[0x9, 0x10,
			1x12, 2x12, 3x12, 4x12,
			1x13, 2x13, 3x13, 4x13,
			]],
	rope = [[1x9, 1x10,]],
	wall_water = [[0x21, 1x21, 2x21,]],
	other = [[2x10]],
}
categories[CATEGORY_GARDEN] = {
	fences = [[2x17,
			0x18, 1x18, 2x18, 3x19, 4x18, 5x18, 6x18, 7x18,
			3x22,]],
	plants = [[0x22, 1x22, 2x22, 4x32, 4x33,
			0x32, 1x32, 0x22, 1x33, 0x34, 1x34,
			]],
	other = [[4x22, 5x30, 6x30, 7x30 ]],
}

local BgObject = {}
BgObject.__index = BgObject

function BgObject:new( name, tileset, coords, cat_major, cat_minor )
	local o = {}
	setmetatable( o, self )

	o.name = name or ""

	if not editor.images[tileset] then
		editor.images[tileset] = love.graphics.newImage( "images/tilesets/" .. Camera.scale*8 .. tileset .. ".png")
	end

	o.tileset = editor.images[tileset]

	--o.tileList = tileList

	--o.quadList = {}

	--o.tileArray = {}
	--o.coordsArray = {}

	--o.category_major = cat_major or CATEGORY_MISC
	--o.category_minor = cat_minor or ""

	--[[o.sortedTileArray = {}
	local minX, minY = math.huge, math.huge
	local maxY, maxY = -math.huge, -math.huge]]
	-- add all coords into lists:
	--[[for k, coords in pairs(tileList) do
		if not o.tileArray[coords.tileX] then
			o.tileArray[coords.tileX] = {}
		end
		if not o.coordsArray[coords.x] then
			o.coordsArray[coords.x] = {}
		end
		--o.tileArray[coords.tileX][coords.tileY] = coords
		o.coordsArray[coords.x][coords.y] = coords
	end

	-- calculate bounding box:
	o.minX, o.minY = math.huge, math.huge
	o.maxX, o.maxY = -math.huge,-math.huge
	for x,v in pairs(o.tileList) do
		o.minX = math.min(o.minX, v.x)
		o.maxX = math.max(o.maxX, v.x)
		o.minY = math.min(o.minY, v.y)
		o.maxY = math.max(o.maxY, v.y)
	end]]
	--[[o.bBox = {
		x = o.minX,
		y = o.minY,
		maxX = o.maxX + 1,
		maxY = o.maxY + 1,
	}]]

	--o:calculateQuads()
	o.quad = love.graphics.newQuad(
			coords.tileX*Camera.scale*8, coords.tileY*Camera.scale*8,
			Camera.scale*8, Camera.scale*8,
			o.tileset:getWidth(), o.tileset:getHeight() )
	
	o.batch = love.graphics.newSpriteBatch( o.tileset )
	o:addToBatch( o.batch, {}, 0, 0 )

	o.tileWidth = 1--(o.maxX - o.minX)
	o.tileHeight = 1--(o.maxY - o.minY)
	
	o.width = (o.tileWidth)*Camera.scale*8
	o.height = (o.tileHeight)*Camera.scale*8

	return o
end

--[[
-- looks for the largest possible quads:
function getLargestRectangle( tbl, minX, maxX, minY, maxY )
	-- make a copy of the table of tiles:
	local rects = {}
	if next(tbl) then	-- as long as list is not empty
		-- find the largest possible rectangle (brute-force approach)
		for x = minX, maxX do
			for y = minY, maxY do
				if tbl[x] and tbl[x][y] then
					--if x == 10 and y == 1 then

					-- try every point as starting point
					startX, startY = x, y
					curX, curY = x, y
					maxWidth, maxHeight = 1,0

					-- go as far right as possible
					while tbl[curX+1] and tbl[curX+1][y] do
						curX = curX + 1
						maxWidth = curX - startX + 1
					end
					-- expand this line southwards:
					while maxWidth > 0 do
						local i = 0
						curX, curY = startX, startY
						while curX-startX < maxWidth do
							if tbl[curX][curY+maxHeight] then
								i = i + 1
							else
								break
							end
							curX = curX+1
						end

						if i == maxWidth then
							maxHeight = maxHeight + 1
							--print("\trect", maxWidth, maxHeight, maxHeight*maxWidth)
							local new = {x=startX, y=startY, w=maxWidth, h=maxHeight, a = maxHeight*maxWidth}
							table.insert(rects, new)
						else
							maxWidth = maxWidth - 1
						end
					end

				end
			end
		end

		-- find the largest rectangle
		table.sort( rects, function(a,b) return a.a > b.a end )

		for k,r in ipairs(rects) do
		end

		-- remove all parts of the rectangle from the list
		if rects[1] then
			for curX = rects[1].x, rects[1].x+rects[1].w-1 do
				for curY = rects[1].y, rects[1].y+rects[1].h-1 do
					tbl[curX][curY] = nil
				end
			end
		end

	end

	return tbl, rects[1]
end]]

-- looks for the largest possible quads:
function BgObject:calculateQuads()

	-- if object is "sorted", that means that neighbouring tiles are also neighbouring on the tile sheet:
	--[[if self.sorted then
	tbl = {}
	for x,v in pairs(self.tileArray) do
		tbl[x] = {}
		for y,v2 in pairs(v) do
			tbl[x][y] = v2
		end
	end

	while next(tbl) do
		tbl, rectangle = getLargestRectangle(tbl, self.minX, self.maxX, self.minY, self.maxY)
		if rectangle then
			table.insert( self.quads, rectangle )
		end
	end
	else]]
		for k, coords in pairs(self.tileList) do
			local quad = love.graphics.newQuad(
				coords.tileX*Camera.scale*8, coords.tileY*Camera.scale*8,
				Camera.scale*8, Camera.scale*8,
				self.tileset:getWidth(), self.tileset:getHeight()
				)
			local new = {
				quad = quad,
				coordX = coords.x,
				coordY = coords.y
			}
			table.insert( self.quadList, new )
		end
	--end
end

function BgObject:addToBatch( spriteBatch, emptyIDs, x, y )
	local usedIDs = {}
	--local quad, xOffset, yOffset
	--for k, element in pairs(self.quadList) do
		--xOffset = self.coordX
		--yOffset = self.coordY
		local k, id
		if emptyIDs then
			k, id = next(emptyIDs)
		end

		if id then
			spriteBatch:set( id, self.quad, (x)*Camera.scale*8, (y)*Camera.scale*8)
			table.remove(emptyIDs, k)
		else
			id = spriteBatch:add( self.quad, (x)*Camera.scale*8, (y)*Camera.scale*8)
		end
		table.insert( usedIDs, id )
	--end
	return usedIDs--, self.bBox
end

-- Sort by categories (first by major, then within
-- the major category, sort by minor)
--[[local function sortBgObjectList( a, b )
	if not b then return true end
	if not a then return false end
	if a.category_major ~= b.category_major then
		if a.category_major == "misc" then
			return false
		elseif b.category_major == "misc" then
			return true
		end
		return a.category_major < b.category_major
	else
		if a.category_minor ~= b.category_minor then
			return a.category_minor < b.category_minor
		else
			return a.name < b.name
			--return false
		end
	end
end]]

function BgObject:addToCategory( cat, filename, x, y )
	local img, coords = dofile( "editor/bgObjects/" .. filename )
	for k, c in pairs( coords ) do
		new = BgObject:new( img .. c.tileX .. "x" .. c.tileY, img, c )
		new.panelX = x + c.x
		new.panelY = y + c.y
		table.insert( cat, new )
	end
end

function BgObject:init()
	local list = {}
	local obj, img, coords, category
	local x, y = 1,1
	list["houses"] = {}
	list["plants"] = {}
	list["misc"] = {}
	self:addToCategory( list["houses"], "house1.lua", 0, 0 )
	self:addToCategory( list["houses"], "house2.lua", 6, 0 )
	self:addToCategory( list["houses"], "housewalls.lua", 5, 5 )
	self:addToCategory( list["houses"], "singlehousewalls.lua", 0, 6 )
	self:addToCategory( list["houses"], "doors.lua", 0, 4 )
	self:addToCategory( list["houses"], "roof.lua", 14, 0 )
	self:addToCategory( list["plants"], "tree1.lua", 0, 1 )
	self:addToCategory( list["plants"], "tree2.lua", 15, 1 )
	self:addToCategory( list["plants"], "tree3.lua", 10, 1 )
	self:addToCategory( list["plants"], "tree4.lua", 5, 1 )
	self:addToCategory( list["plants"], "plants.lua", 0, 5 )
	self:addToCategory( list["plants"], "fence.lua", 0, 0 )
	self:addToCategory( list["plants"], "haystack.lua", 10, 0 )
	self:addToCategory( list["misc"], "wagon.lua", 10, 0 )
	self:addToCategory( list["misc"], "well.lua", 9, 0 )
	self:addToCategory( list["misc"], "dragon1.lua", 0, 0 )
	self:addToCategory( list["misc"], "boxes.lua", 6, 0 )
	self:addToCategory( list["misc"], "tools.lua", 7, 2 )
	self:addToCategory( list["misc"], "water.lua", 12, 0 )
	self:addToCategory( list["misc"], "pulley.lua", 16, 0 )
	return list
end

return BgObject
