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

local BgObject = {}
BgObject.__index = BgObject

function BgObject:new( name, tilesheet, tileList, sorted )
	local o = {}
	setmetatable( o, BgObject )

	o.name = name or ""
	o.sorted = false

	if not editor.images[tilesheet] then
		editor.images[tilesheet] = love.graphics.newImage( "images/tilesets/" .. Camera.scale*8 .. tilesheet .. ".png")
	end

	self.tilesheet = editor.images[tilesheet]

	self.tileList = tileList

	self.quadList = {}

	self.tileArray = {}
	self.coordsArray = {}
	--[[self.sortedTileArray = {}
	local minX, minY = math.huge, math.huge
	local maxY, maxY = -math.huge, -math.huge]]
	-- add all coords into lists:
	for k, coords in pairs(tileList) do
		if not self.tileArray[coords.tileX] then
			self.tileArray[coords.tileX] = {}
		end
		if not self.coordsArray[coords.x] then
			self.coordsArray[coords.x] = {}
		end
		--self.tileArray[coords.tileX][coords.tileY] = coords
		self.coordsArray[coords.x][coords.y] = coords
	end

	-- calculate bounding box:
	self.minX, self.minY = math.huge, math.huge
	self.maxX, self.maxY = -math.huge,-math.huge
	for x,v in pairs(self.tileList) do
		self.minX = math.min(self.minX, v.x)
		self.maxX = math.max(self.maxX, v.x)
		self.minY = math.min(self.minY, v.y)
		self.maxY = math.max(self.maxY, v.y)
	end
	self.bBox = {
		x = self.minX,
		y = self.minY,
		maxX = self.maxX,
		maxY = self.maxY,
	}


	self:calculateQuads()

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
				self.tilesheet:getWidth(), self.tilesheet:getHeight()
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
	local quad, xOffset, yOffset
	for k, element in pairs(self.quadList) do
		quad = element.quad
		xOffset = element.coordX
		yOffset = element.coordY
		local k, id = next(emptyIDs)
		
		if id then
			spriteBatch:set( id, quad, (x + xOffset)*Camera.scale*8, (y + yOffset)*Camera.scale*8)
			table.remove(emptyIDs, k)
		else
			id = spriteBatch:add( quad, (x + xOffset)*Camera.scale*8, (y + yOffset)*Camera.scale*8)
		end
		table.insert( usedIDs, id )
	end
	return usedIDs, self.bBox
end

function BgObject:init()
	local list = {}
	local new = nil
	local coords

	coords = dofile("editor/objects/tree1.lua")
	new = BgObject:new( "tree1", "background1", coords)
	table.insert( list, new )

	coords = dofile("editor/objects/tree2.lua")
	new = BgObject:new( "tree2", "background1", coords)
	table.insert( list, new )

	return list
end

return BgObject
