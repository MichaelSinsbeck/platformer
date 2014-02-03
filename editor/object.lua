-------------------------------------------
-- Interactable/Moving Objects for the map
-------------------------------------------
-- Objects can consist of an arbitary number of tiles.
-- Each object object knows what tilesheet its tiles are from and
-- how to place them onto the map.

-- An object can either be a single rectangle or multiple ones.
-- The coords given through tilelist are tables containing:
-- tileX, tileY, x, y. tileX and tileY give the coordinates of the square on
-- the tile map, x and y give the rendering position.
-- x and y MUST start at 0 for the lowest tiles, tileX and tileY are relative
-- to the upper left corner of the corresponding tilesheet.

local Object = {}
Object.__index = Object

function Object:new( name, tileset, tileList, sorted )
	local o = {}
	setmetatable( o, self )

	o.name = name or ""
	o.sorted = false

	if not editor.images[tileset] then
		editor.images[tileset] = love.graphics.newImage( "images/" .. Camera.scale*8 .. tileset .. ".png")
	end

	o.tileset = editor.images[tileset]

	o.tileList = tileList

	o.quadList = {}

	o.tileArray = {}
	o.coordsArray = {}
	--[[o.sortedTileArray = {}
	local minX, minY = math.huge, math.huge
	local maxY, maxY = -math.huge, -math.huge]]
	-- add all coords into lists:
	for k, coords in pairs(tileList) do
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
	end
	o.bBox = {
		x = o.minX,
		y = o.minY,
		maxX = o.maxX + 1,
		maxY = o.maxY + 1,
	}

	o:calculateQuads()
	
	o.batch = love.graphics.newSpriteBatch( o.tileset )
	o:addToBatch( o.batch, {}, 0, 0 )

	o.tileWidth = (o.maxX - o.minX)
	o.tileHeight = (o.maxY - o.minY)
	
	o.width = (o.tileWidth+1)*Camera.scale*8
	o.height = (o.tileHeight+1)*Camera.scale*8

	return o end 
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
function Object:calculateQuads()

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
				coords.tileX*Camera.scale*10, coords.tileY*Camera.scale*10,
				Camera.scale*10, Camera.scale*10,
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

function Object:addToBatch( spriteBatch, emptyIDs, x, y )

	local usedIDs = {}
	local quad, xOffset, yOffset
	for k, element in pairs(self.quadList) do
		quad = element.quad
		xOffset = element.coordX
		yOffset = element.coordY
		local k, id
		if emptyIDs then
			k, id = next(emptyIDs)
		end

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

--[[
function Object:init()
	local list = {}
	local coords, img, name

	print("Loading objects:")

	files = love.filesystem.getDirectoryItems("editor/objects/")
	for i, file in ipairs(files) do
		name = file:match("([^/]*).lua$")
		if name then
			print("\t...", name)
			img, coords = dofile( "editor/objects/" .. file )
			new = Object:new( name, img, coords )
			table.insert( list, new )
		end
	end

	return list
end]]

function Object:init()
	local list = {}

	local new

	new = {
		name = "player",
		objType = spriteFactory("player"),
	}
	new.objType:init()
	if new.objType.vis then
		new.width, new.height = new.objType.width, new.objType.height
	else
		new.width, new.height = 10,10
	end

	table.insert( list, new )

	return list
end

return Object
