local EditorMap = {}
EditorMap.__index = EditorMap

local MAX_TILES_PER_FRAME = 500
local MAX_FLOOD_FILL_RECURSION = 1500
local MAX_NUMBER_BG_OBJECTS = 50000

local MIN_MAP_SIZE = 3

-- Offset for the markers in the corners of the map border (pin needles).
-- This offset is the offset between the position where the image should be drawn
-- and the actual map border. It is different for all pins, because the pins are
-- oriented differently. Update these when changing the pin images!
local markerOffset1 = {x=0.5, y=0.9}
local markerOffset2 = {x=0.5, y=1.1}
local markerOffset3 = {x=0.7, y=0.9}
local markerOffset4 = {x=0.7, y=1.1}

function EditorMap:new( backgroundList )
	local o = {}
	setmetatable( o, EditorMap )
	o.MAP_SIZE = 1000

	o.backgroundList = backgroundList

	o.groundBatch = love.graphics.newSpriteBatch( editor.images.tilesetGround,
					o.MAP_SIZE*o.MAP_SIZE, "stream" )
	o.backgroundBatch = {}
	o.bgIDs = {}
	for i,bg in pairs(backgroundList) do
		o.backgroundBatch[i] = love.graphics.newSpriteBatch( editor.images.tilesetBackground,
						o.MAP_SIZE*o.MAP_SIZE, "stream" )
		o.bgIDs[bg] = i
	end
	o.spikeBatch = love.graphics.newSpriteBatch( editor.images.tilesetGround,
					o.MAP_SIZE*o.MAP_SIZE, "stream" )
	--o.backgroundBatch = love.graphics.newSpriteBatch( editor.images.tilesetBackground,
					--100000, "dynamic" )

	o.groundArray = {}
	o.backgroundArray = {}
	o.tilesToModify = {}
	o.tilesModifiedThisFrame = 0

	--o.selectedBgObjects = {}
	o.selectedObjects = {}
	
	o.tileSize = Camera.scale*8

	o.minX = 1
	o.maxX = 30
	o.minY = 1
	o.maxY = 16
	
	o.width, o.height = o.maxX-o.minX+1,o.maxY-o.minY+1	-- fallback

	o.border = {}	-- the border which to draw around the map...
	o.borderMarkers = {}
	o.borderMarkers[1] = {x=0,y=0,img=editor.images.pinLeft}
	o.borderMarkers[2] = {x=0,y=0,img=editor.images.pinLeft}
	o.borderMarkers[3] = {x=0,y=0,img=editor.images.pinRight}
	o.borderMarkers[4] = {x=0,y=0,img=editor.images.pinRight}

	EditorMap.updateBorder(o)

	o.bgList = {}	-- list of background objects
	o.bgObjectSpriteBatch = love.graphics.newSpriteBatch(
			editor.images.background1, MAX_NUMBER_BG_OBJECTS )
	o.objectList = {}	-- list of objects
	o.lines = {}
	--[[
	for x = 0, o.MAP_SIZE-1 do
		o.groundArray[x] = {}
		for y = 0, o.MAP_SIZE-1 do
			o.groundArray[x][y] = {}
			-- store type to remember what's in the tile:
			o.groundArray[x][y].gType = nil
			-- store id returned by the spritebatch to be able to modify image:
			o.groundArray[x][y].batchID = nil
		end
	end]]

	o.xStart = 1
	o.yStart = 1

	o.name = ""

	return o
end

-------------------------------------------------------
-- Ground Manupulations (Walls the player collides with)
-------------------------------------------------------

function EditorMap:queueGroundTileUpdate( x, y, noMoreRecursion )
	local data = {
		command = "update",
		x = x,
		y = y,
		noMoreRecursion = noMoreRecursion,
	}
	self.tilesToModify[#self.tilesToModify + 1] = data
end

function EditorMap:setGroundTile( x, y, ground, updateSurrounding )
	if not self.groundArray[x] then
		self.groundArray[x] = {}
	end
	if not self.groundArray[x][y] then
		self.groundArray[x][y] = { batchID = {} }
	end

	self:queueGroundTileUpdate( x, y )
	-- determine whether or not the old and new ground types are the same:
	local oldGroundType = ""
	local newGroundType = ""
	if self.groundArray[x][y].gType then
		oldGroundType = (self.groundArray[x][y].gType.name == "spikesConcrete" or
					self.groundArray[x][y].gType.name == "spikesSoil") and "spikes" or "noSpikes"
	end

	if ground.name == "spikesConcrete" or ground.name == "spikesSoil" then
		newGroundType = "spikes"
	else
		newGroundType = "noSpikes"
	end

	-- if the ground type changed, remove the old:
	if oldGroundType ~= "" and newGroundType ~= oldGroundType then
		self:eraseGroundTile( x, y, false )
	end

	local quad = ground.tiles.cm
	-- if there's already a tile there, update it:
	if newGroundType == "spikes" then
		if self.groundArray[x][y].batchID["spikes"] then
			self.spikeBatch:set( self.groundArray[x][y].batchID["spikes"],
				quad, x*self.tileSize - Camera.scale, y*self.tileSize - Camera.scale )
		else
			self.groundArray[x][y].batchID["spikes"] = self.spikeBatch:add(
				quad, x*self.tileSize - Camera.scale, y*self.tileSize - Camera.scale )
		end
	else
		if self.groundArray[x][y].batchID["noSpikes"] then
			self.groundBatch:set( self.groundArray[x][y].batchID["noSpikes"],
				quad, x*self.tileSize - Camera.scale, y*self.tileSize - Camera.scale )
		else
			self.groundArray[x][y].batchID["noSpikes"] = self.groundBatch:add(
				quad, x*self.tileSize - Camera.scale, y*self.tileSize - Camera.scale )
		end
	end
	-- set the new ground type:
	self.groundArray[x][y].gType = ground


	if updateSurrounding then
		--print("left:")
		self:queueGroundTileUpdate( x-1, y )
		--print("right:")
		self:queueGroundTileUpdate( x+1, y )
		--print("above:")
		self:queueGroundTileUpdate( x, y-1 )
		--print("below:")
		self:queueGroundTileUpdate( x, y+1 )
	end
end


function EditorMap:updateGroundTile( x, y, noMoreRecursion )
	--if updateSurrounding then print("---------------") end
	
	self.tilesModifiedThisFrame = self.tilesModifiedThisFrame + 1

	local ground = self.groundArray[x][y].gType

	-- load the surrounding ground types:
	local l,r,b,t = nil,nil,nil,nil
	local forbiddenTransitions = ""
	if self.groundArray[x-1] and self.groundArray[x-1][y] then
		l = self.groundArray[x-1][y].gType
		if self.groundArray[x-1][y].transition then
			forbiddenTransitions = forbiddenTransitions .. self.groundArray[x-1][y].transition .. ","
		end
	end
	if self.groundArray[x+1] and self.groundArray[x+1][y] then
		r = self.groundArray[x+1][y].gType
		if self.groundArray[x+1][y].transition then
			forbiddenTransitions = forbiddenTransitions .. self.groundArray[x+1][y].transition .. ","
		end
	end
	if self.groundArray[x][y-1] then
		t = self.groundArray[x][y-1].gType
		if self.groundArray[x][y-1].transition then
			forbiddenTransitions = forbiddenTransitions .. self.groundArray[x][y-1].transition .. ","
		end
	end
	if self.groundArray[x][y+1] then
		b = self.groundArray[x][y+1].gType
		if self.groundArray[x][y+1].transition then
			forbiddenTransitions = forbiddenTransitions .. self.groundArray[x][y+1].transition .. ","
		end
	end

	-- account for map borders:
	if x <= self.minX then
		l = ground
	end
	if x >= self.maxX-1 then
		r = ground
	end
	if y <= self.minY then
		t = ground
	end
	if y >= self.maxY-1 then
		b = ground
	end


	-- get the quad for the current tile which depends on the surrounding ground types:
	local quad, foundTransition = ground:getQuad( l, r, t, b, nil,nil,nil,nil, forbiddenTransitions )
	
	if ground.name == "spikesConcrete" or ground.name == "spikesSoil" then
		newGroundType = "spikes"
	else
		newGroundType = "noSpikes"
	end

	-- if there's already a tile there, update it:
	if newGroundType == "spikes" then
		if self.groundArray[x][y].batchID["spikes"] then
			self.spikeBatch:set( self.groundArray[x][y].batchID["spikes"],
				quad, x*self.tileSize - Camera.scale, y*self.tileSize - Camera.scale )
		else
			self.groundArray[x][y].batchID["spikes"] = self.spikeBatch:add(
				quad, x*self.tileSize - Camera.scale, y*self.tileSize - Camera.scale )
		end
	else
		if self.groundArray[x][y].batchID["noSpikes"] then
			self.groundBatch:set( self.groundArray[x][y].batchID["noSpikes"],
				quad, x*self.tileSize - Camera.scale, y*self.tileSize - Camera.scale )
		else
			self.groundArray[x][y].batchID["noSpikes"] = self.groundBatch:add(
				quad, x*self.tileSize - Camera.scale, y*self.tileSize - Camera.scale )
		end
	end

	if foundTransition and not noMoreRecursion then
		self.groundArray[x][y].transition = foundTransition
		if self.groundArray[x-1] and self.groundArray[x-1][y] and
			self.groundArray[x-1][y].gType then
			self:queueGroundTileUpdate( x-1, y, true )
		end
		if self.groundArray[x+1] and self.groundArray[x+1][y] and
			self.groundArray[x+1][y].gType then
			self:queueGroundTileUpdate( x+1, y, true )
		end
	else
		self.groundArray[x][y].transition = nil
	end

	-- update border:
	if x < self.minX or x+1 > self.maxX or y < self.minY or y+1 > self.maxY then
		self.minX = math.min(self.minX, x)
		self.maxX = math.max(self.maxX, x+1)
		self.minY = math.min(self.minY, y)
		self.maxY = math.max(self.maxY, y+1)
		self:updateBorder()
	end
end

function EditorMap:eraseGroundTile( x, y, updateSurrounding )

	if not self.groundArray[x] or not self.groundArray[x][y] then return end

	-- determine whether to remove a spike or a normal wall/ground:
	local batchID, batch
	if self.groundArray[x][y].gType then
		if self.groundArray[x][y].gType.name == "spikesConcrete" or
				self.groundArray[x][y].gType.name == "spikesSoil" then
			batchID = self.groundArray[x][y].batchID["spikes"]
			batch = self.spikeBatch
		else
			batchID = self.groundArray[x][y].batchID["noSpikes"]
			batch = self.groundBatch
		end
	end

	if batchID then
		-- sadly, there's no way to remove from a sprite batch,
		-- so instead, move to 0:
		batch:set( batchID,0,0,0,0,0 )
		self.groundArray[x][y].gType = nil

	end

	if updateSurrounding then
		--print("left:")
		self:queueGroundTileUpdate( x-1, y )
		--print("right:")
		self:queueGroundTileUpdate( x+1, y )
		--print("above:")
		self:queueGroundTileUpdate( x, y-1 )
		--print("below:")
		self:queueGroundTileUpdate( x, y+1 )
	end

end
--[[
function EditorMap:eraseGroundTileNow( x, y, updateSurrounding )

	self.tilesModifiedThisFrame = self.tilesModifiedThisFrame + 1
end]]
---------------------------------------------------
-- Background walls (non-collidable):
---------------------------------------------------

function EditorMap:queueBackgroundTileUpdate( x, y )

	if not self.backgroundArray[x] or not self.backgroundArray[x][y] then return end
	
	local data = {
		command = "updateBg",
		x = x,
		y = y,
	}
	self.tilesToModify[#self.tilesToModify + 1] = data
end

function EditorMap:setBackgroundTile( x, y, background, updateSurrounding )
	
	--print("set:", background, background.name)
	
	if not self.backgroundArray[x] then
		self.backgroundArray[x] = {}
	end
	if not self.backgroundArray[x][y] then
		self.backgroundArray[x][y] = { batchID = {} }
	end

	self:queueBackgroundTileUpdate( x, y )

	-- fill all tile layers below mine:
	local quad = background.tiles.cm

	-- if there's already a tile there, update it:
	if self.backgroundArray[x][y].batchID[background] then
		self.backgroundBatch[self.bgIDs[background]]:set(
			self.backgroundArray[x][y].batchID[background],
			quad, x*self.tileSize, y*self.tileSize )
	else
		self.backgroundArray[x][y].batchID[background] =
			self.backgroundBatch[self.bgIDs[background]]:add(
				quad, x*self.tileSize, y*self.tileSize)
	end

	if self.backgroundArray[x][y].gType then
		self:eraseBackgroundTile( x, y, false )
	end
	-- set the new ground type:
	self.backgroundArray[x][y].gType = background


	if updateSurrounding then
		--print("left:")
		self:queueBackgroundTileUpdate( x-1, y )
		--print("right:")
		self:queueBackgroundTileUpdate( x+1, y )
		--print("above:")
		self:queueBackgroundTileUpdate( x, y-1 )
		--print("below:")
		self:queueBackgroundTileUpdate( x, y+1 )
		
		--diagonal:
		self:queueBackgroundTileUpdate( x-1, y-1 )
		self:queueBackgroundTileUpdate( x+1, y-1 )
		self:queueBackgroundTileUpdate( x+1, y+1 )
		self:queueBackgroundTileUpdate( x-1, y+1 )
	end
end


function EditorMap:updateBackgroundTile( x, y, forceNoTransition )
	--if updateSurrounding then print("---------------") end
	--
	self.tilesModifiedThisFrame = self.tilesModifiedThisFrame + 1

	local background = self.backgroundArray[x][y].gType

	-- load the surrounding ground types:
	local l,r,b,t,lt,rt,lb,rb
	if self.backgroundArray[x-1] then
		if self.backgroundArray[x-1][y] then
			l = self.backgroundArray[x-1][y].gType
		end
		if self.backgroundArray[x-1][y-1] then
			lt = self.backgroundArray[x-1][y-1].gType
		end
		if self.backgroundArray[x-1][y+1] then
			lb = self.backgroundArray[x-1][y+1].gType
		end
	end
	if self.backgroundArray[x+1] then
		if self.backgroundArray[x+1][y] then
			r = self.backgroundArray[x+1][y].gType
		end
		if self.backgroundArray[x+1][y-1] then
			rt = self.backgroundArray[x+1][y-1].gType
		end
		if self.backgroundArray[x+1][y+1] then
			rb = self.backgroundArray[x+1][y+1].gType
		end
	end
	if self.backgroundArray[x][y-1] then
		t = self.backgroundArray[x][y-1].gType
	end
	if self.backgroundArray[x][y+1] then
		b = self.backgroundArray[x][y+1].gType
	end

	-- account for map borders:
	if x <= self.minX then
		l = background
		lt = background
		lb = background
	end
	if x >= self.maxX-1 then
		r = background
		rt = background
		rb = background
	end
	if y <= self.minY then
		t = background
		lt = background
		rt = background
	end
	if y >= self.maxY-1 then
		b = background
		lb = background
		rb = background
	end

	local quad
	for i, bg in ipairs(self.backgroundList) do
	-- get the quad for the current tile  which depends on the surrounding ground types:
		quad = bg:getQuad( l, r, t, b, lt, rt, lb, rb, forceNoTransition )

		if quad then

			-- if there's already a tile there, update it:
			if self.backgroundArray[x][y].batchID[bg] then
				self.backgroundBatch[i]:set( self.backgroundArray[x][y].batchID[bg],
				quad, x*self.tileSize, y*self.tileSize )
			else
				self.backgroundArray[x][y].batchID[bg] = self.backgroundBatch[i]:add(
				quad, x*self.tileSize, y*self.tileSize )
			end

		--elseif bg == background then
			--self:eraseBackgroundTile( x, y, true )
			--return
		end

		if bg == background then
			break
		end
	end

	-- update border:
	if x < self.minX or x+1 > self.maxX or y < self.minY or y+1 > self.maxY then
		self.minX = math.min(self.minX, x)
		self.maxX = math.max(self.maxX, x+1)
		self.minY = math.min(self.minY, y)
		self.maxY = math.max(self.maxY, y+1)
		self:updateBorder()
	end

end

function EditorMap:eraseBackgroundTile( x, y, updateSurrounding )

	if not self.backgroundArray[x] or not self.backgroundArray[x][y] then return end

	-- determine whether to remove a spike or a normal wall/ground:
	local background = self.backgroundArray[x][y].gType
	--print("erasing:", x, y, background and background.name or "nil")
	for i, bg in ipairs(self.backgroundList) do
		local batchID, batch
		batchID = self.backgroundArray[x][y].batchID[bg]
		batch = self.backgroundBatch[i]

		if batchID then
			-- sadly, there's no way to remove from a sprite batch,
			-- so instead, move to 0:
			batch:set( batchID,0,0,0,0,0 )
		end
	end

	self.backgroundArray[x][y].gType = nil
	if updateSurrounding then
		--print("left:")
		self:queueBackgroundTileUpdate( x-1, y )
		--print("right:")
		self:queueBackgroundTileUpdate( x+1, y )
		--print("above:")
		self:queueBackgroundTileUpdate( x, y-1 )
		--print("below:")
		self:queueBackgroundTileUpdate( x, y+1 )
		--diagonal:
		self:queueBackgroundTileUpdate( x-1, y-1 )
		self:queueBackgroundTileUpdate( x-1, y+1 )
		self:queueBackgroundTileUpdate( x+1, y-1 )
		self:queueBackgroundTileUpdate( x+1, y+1 )
	end
end

--------------------------------------------------
-- Line-drawing and area-filling:
--------------------------------------------------

local function sign( i )
	if i < 0 then
		return -1
	elseif i > 0 then
		return 1
	else
		return 0
	end
end

function EditorMap:line( tileX, tileY, startX, startY, thick, event )
	-- Bresenham's algorithm:
	local dx, dy = tileX - startX, tileY - startY
	local incx,incy = sign(dx), sign(dy)
	dx,dy = math.abs(dx), math.abs(dy)

	local pdx,pdy,ddx,ddy,es,el

	if dx > dy then		-- x is fast direction
		pdx = incx
		pdy = 0
		ddx = incx
		ddy = incy
		es = dy
		el = dx
	else	-- y is fast direction
		pdx = 0
		pdy = incy
		ddx = incx
		ddy = incy
		es = dx
		el = dy
	end

	local x, y = startX, startY
	local err = el/2

	event(x,y)	-- draw or erase tile, depending on what event is
	if thick then
		event(x-1,y)
		event(x,y-1)
		event(x-1,y-1)
	end
	for t=0, el-1 do
		err = err - es
		if err < 0 then
			err = err + el
			x = x + ddx
			y = y + ddy
		else
			x = x + pdx
			y = y + pdy
		end
		event(x,y)	-- draw or erase tile, depending on what event is
		if thick then
			event(x-1,y)
			event(x,y-1)
			event(x-1,y-1)
		end
	end
end

function EditorMap:fill( x, y, initialType, event, checked, field, depth )

	if depth > MAX_FLOOD_FILL_RECURSION then return end

	if not checked[x][y] then
		checked[x][y] = true

		local typeMatch
		if field[x] and field[x][y] then
			typeMatch = field[x][y].gType == initialType
		else
			typeMatch = initialType == nil
		end

		if typeMatch then
			event( x, y )

			if x+1 < self.maxX then
				self:fill( x+1, y, initialType, event, checked, field, depth+1)
			end
			if x-1 >= self.minX then
				self:fill( x-1, y, initialType, event, checked, field, depth+1)
			end
			if y+1 < self.maxY then
				self:fill( x, y+1, initialType, event, checked, field, depth+1)
			end
			if y-1 >= self.minY then
				self:fill( x, y-1, initialType, event, checked, field, depth+1)
			end	
		end
	end
end

function EditorMap:startFillGround( x, y, eventType, ground )
	local initialType = self.groundArray[x] and
	(self.groundArray[x][y] and self.groundArray[x][y].gType)

	if x < self.minX or x + 1 > self.maxX or y < self.minY or y + 1 > self.maxY then return end

	local event
	if eventType == "set" then
		event = function( x, y )
			self:setGroundTile( x, y, ground, true )
		end
	elseif eventType == "erase" then
		event = function( x, y )
			self:eraseGroundTile( x, y, true )
		end
	end
	local array = {}
	for x = self.minX, self.maxX do
		array[x] = {}
	end
	self:fill( x, y, initialType, event, array, self.groundArray, 1)
end

function EditorMap:startFillBackground( x, y, eventType, ground )
	local initialType = self.backgroundArray[x] and
	(self.backgroundArray[x][y] and self.backgroundArray[x][y].gType)

	if x < self.minX or x + 1 > self.maxX or y < self.minY or y + 1 > self.maxY then return end

	local event
	if eventType == "set" then
		event = function( x, y )
			self:setBackgroundTile( x, y, ground, true )
		end
	elseif eventType == "erase" then
		event = function( x, y )
			self:eraseBackgroundTile( x, y, true )
		end
	end
	local array = {}
	for x = self.minX, self.maxX do
		array[x] = {}
	end
	self:fill( x, y, initialType, event, array, self.backgroundArray, 1)
end

---------------------------------------
-- Background Objects
---------------------------------------

function EditorMap:addBgObject( tileX, tileY, object )
	if #self.bgList >= MAX_NUMBER_BG_OBJECTS then
		print("Waring: Maximum number of background objects reached.")
		return
	end
	local newBatch, newIDs
	-- In editor mode: Each new background tile gets its own quad:
	if mode == "editor" then
		--newBatch = love.graphics.newSpriteBatch( object.tileset, 100, "static" )
		--newIDs = object:addToBatch( newBatch, nil, 0,0 )
	local newObject = {
		--ids = newIDs,
		--batch = newBatch,
		x = tileX,--bBox.x + tileX,
		y = tileY,--bBox.y + tileY,
		maxX = 1 + tileX,--bBox.maxX + tileX,
		maxY = 1 + tileY,--bBox.maxY + tileY,
		drawX = tileX*self.tileSize,--(bBox.x + tileX)*self.tileSize,
		drawY = tileY*self.tileSize,--(bBox.y + tileY)*self.tileSize,
		tileWidth = object.tileWidth,
		tileHeight = object.tileHeight,
		width = object.width,
		height = object.height,
		selected = false,
		objType = object,
		isBackgroundObject = true,
	}
	table.insert( self.bgList, newObject )

	if newObject.x < self.minX or newObject.maxX > self.maxX or
		newObject.y < self.minY or newObject.maxY > self.maxY then
		self.minX = math.min(self.minX, newObject.x)
		self.maxX = math.max(self.maxX, newObject.maxX)
		self.minY = math.min(self.minY, newObject.y)
		self.maxY = math.max(self.maxY, newObject.maxY)
		self:updateBorder()
	end
	return newObject
else
	self.bgObjectSpriteBatch:add( object.quad, tileX*self.tileSize, tileY*self.tileSize )
end
end

function EditorMap:removeBgObjectAt( tileX, tileY )
	-- Go through the list backwards and delete the first object found
	-- which is hit by the click:
	local obj
	for k = #self.bgList, 1, -1 do
		obj = self.bgList[k]
		if tileX >= obj.x and tileY >= obj.y and tileX <= obj.maxX-1 and tileY <= obj.maxY-1 then
			table.remove(self.bgList, k)
			return true	-- only remove the one!
		end
	end
end

function EditorMap:removeSelectedBgObjects()
	if #self.selectedObjects > 0 then
		local toRemove = {}
		for k, obj in ipairs(self.bgList) do
			if obj.selected then
				table.insert( toRemove, k )
			end
		end
		for k = #toRemove, 1, -1 do		-- go through list backwards
			table.remove( self.bgList, toRemove[k] )
		end
	end
end

function EditorMap:findBgObjectAt( tileX, tileY )

	-- unselect previously selected objects:
	-- self:selectNoBgObject()

	-- Go through the list backwards and select first object found
	local obj
	for k = #self.bgList, 1, -1 do
		obj = self.bgList[k]
		if tileX >= obj.x and tileY >= obj.y and tileX <= obj.maxX-1 and tileY <= obj.maxY-1 then
			-- check if the object is already selected. If so, unselect it:
			--[[for i, o in pairs( self.selectedBgObjects ) do
				if obj == o then
					obj.selected = false
					table.remove( self.selectedBgObjects, i )
					return true
				end
			end]]
			--[[local wasAlreadySelected = obj.selected
			if not obj.selected then
				table.insert( self.selectedBgObjects, obj )
				obj.selected = true
				obj.oX = tileX - obj.x
				obj.oY = tileY - obj.y
			end]]
			return obj
		end
	end
end

function EditorMap:selectObject( obj )
	table.insert( self.selectedObjects, obj )
	obj.selected = true
end

function EditorMap:selectNoObject()
	if #self.selectedObjects > 0 then
		for i, selected in pairs( self.selectedObjects ) do
			selected.selected = false
		end
		self.selectedObjects = {}
	end
end
--[[
function EditorMap:dragObject( tileX, tileY )
	if #self.selectedObjects > 0 then
		for k, obj in pairs( self.selectedObjects ) do
			--local obj = self.selectedBgObject
			obj.x = tileX - obj.oX
			obj.y = tileY - obj.oY
			obj.maxX = obj.x + obj.tileWidth +1
			obj.maxY = obj.y + obj.tileHeight +1
			obj.drawX = obj.x*self.tileSize
			obj.drawY = obj.y*self.tileSize

			if obj.x < self.minX or obj.maxX > self.maxX or
				obj.y < self.minY or obj.maxY > self.maxY then
				self.minX = math.min(self.minX, obj.x)
				self.maxX = math.max(self.maxX, obj.maxX)
				self.minY = math.min(self.minY, obj.y)
				self.maxY = math.max(self.maxY, obj.maxY)
				self:updateBorder()
			end
		end
		return true
	end
end]]

function EditorMap:setDragOffset( tileX, tileY )
	for k, obj in pairs( self.selectedObjects ) do
		obj.oX = tileX - obj.x
		obj.oY = tileY - obj.y
	end
end


function EditorMap:neighbourhoodBgObjects( curObj )
	local list = {}
	for k, obj in pairs(self.bgList) do
		-- is the current object colliding with the obj in the list?
		if obj.x < curObj.maxX and obj.y < curObj.maxY and
			obj.maxX > curObj.x and obj.maxY > curObj.y then
			-- add the object to the list:
			table.insert( list, {k=k, obj=obj} )
		end
	end
	return list
end

function EditorMap:bgObjectLayerUp()
	-- find all objects partly covering the selected object:
	local neighbourhood = self:neighbourhoodBgObjects( self.selectedObjects[1] )
	for i, obj in pairs( neighbourhood ) do
		-- find the selected object in its neighbourhood:
		if obj.obj == self.selectedObjects[1] then
			-- if there's an object in the neighbourhood which is higher than the selected
			-- one, then switch them in the list ob background objects:
			if neighbourhood[i+1] then
				local higher = neighbourhood[i+1]
				self.bgList[higher.k], self.bgList[obj.k] = obj.obj, higher.obj
			end
			break
		end
	end
end

function EditorMap:bgObjectLayerDown()
	-- find all objects partly covering the selected object:
	local neighbourhood = self:neighbourhoodBgObjects( self.selectedObjects[1] )
	for i, obj in pairs( neighbourhood ) do
		-- find the selected object in its neighbourhood:
		if obj.obj == self.selectedObjects[1] then
			-- if there's an object in the neighbourhood which is lower than the selected
			-- one, then switch them in the list ob background objects:
			if neighbourhood[i-1] then
				local lower = neighbourhood[i-1]
				self.bgList[lower.k], self.bgList[obj.k] = obj.obj, lower.obj
			end
			break
		end
	end
end

function EditorMap:duplicateSelection()
	local newObjects = {}
	local new
	for k, o in pairs( self.selectedObjects ) do
		if o.isBackgroundObject then
			new = self:addBgObject( o.x + 1, o.y + 1, o.objType )
		else
			new = self:addObject( o.tileX + 1, o.tileY + 1, o.tag )
			if o.properties then
			for k, p in pairs(o.properties) do
				new:setProperty( k, o[k] ) 
			end
		end
			new:applyOptions()
		end
		newObjects[#newObjects+1] = new
	end
	self:selectNoObject()
	for k, o in pairs( newObjects ) do
		self:selectObject( o )
	end
end

-----------------------------------------
-- Objects (front layer)
-----------------------------------------

function EditorMap:addObject( tileX, tileY, objName )

	--local newBatch = love.graphics.newSpriteBatch( object.tileset, 100, "static" )
	--local newIDs, bBox = object:addToBatch( newBatch, nil, 0,0 )
	--
	local newObject = spriteFactory( objName )
	newObject:init()
	--newObject.name = objName

	-- Some objects are only allowed to be on the maps once!
	if newObject.unique then
		for k, obj in pairs( self.objectList ) do
			if obj.tag == newObject.tag then
				self:removeObject( obj )
			end
		end
	end

	-- only allow one object at the same position!
	if newObject.vis[1] then
		self:removeObjectAt( tileX, tileY )
	end
		
	-- for drawing:
	local nx = tileX + 0.5
	local ny = tileY + 1 - newObject.semiheight
	if newObject.layout == "top" then
		ny = tileY + newObject.semiheight
	elseif newObject.layout == "left" then
		nx = tileX + newObject.semiwidth
		ny = tileY + 0.5
	elseif newObject.layout == "right" then
		nx = tileX + 1 - newObject.semiwidth
		ny = tileY + 0.5
	elseif newObject.layout == "center" then
		ny = tileY + 0.5
	end
	newObject.x, newObject.y = nx, ny

	-- for selecting:
	newObject.tileX = tileX--newObject.x - newObject.width/self.tileSize*0.5
	newObject.tileY = tileY--newObject.y - newObject.height/self.tileSize*0.5
	newObject.maxX = tileX + 1
	newObject.maxY = tileY + 1
	-- for drawing borders in editor:
	newObject.editorX = newObject.x*self.tileSize - newObject.width*0.5
	newObject.editorY = newObject.y*self.tileSize - newObject.height*0.5

	if newObject.vis[1] then
		if newObject.tileX < self.minX or newObject.tileX > self.maxX or
			newObject.tileY < self.minY or newObject.tileY > self.maxY then
			self.minX = math.min(self.minX, newObject.tileX)
			self.maxX = math.max(self.maxX, newObject.maxX)
			self.minY = math.min(self.minY, newObject.tileY)
			self.maxY = math.max(self.maxY, newObject.maxY)
			self:updateBorder()
		end
	end
	
	-- Change collision array of map, if object is solid
	if newObject.solid and self.collisionSrc and self.collisionSrc[tileX] then
		self.collisionSrc[tileX][tileY] = 1
	end

	-- copy and initialize the objects' properties:
	local prop = editor.objectProperties[objName]
	if prop then	-- if there are properties for this type of object:
		-- copy (and thus initialize) the correct properties:
		-- (make sure it's a deep copy to copy all the attributes and values
		-- by value.)
		newObject.properties = utility.copy( prop, true )
	--else
	--	newObject.properties = {}
	end

	if objName == "lineHook" then
		if not self.openLineHook then
			-- This line hook has found no partner, so remember it for future line hooks:
			self.openLineHook = newObject
		else
			-- found a partner, so create new line between the two:	
			local line = spriteFactory( "line" )
			line:init()
			line.x, line.y = self.openLineHook.x, self.openLineHook.y
			line.x2, line.y2 = newObject.x, newObject.y
			table.insert( self.lines, line )
			
			-- each line hook should remember where the line ends (i.e. the other line hook):
			newObject.partner = self.openLineHook
			self.openLineHook.partner = newObject

			-- both should remember the line they're connected to:
			newObject.line = line
			self.openLineHook.line = line

			self.openLineHook = nil

		end
	end

	table.insert( self.objectList, newObject )

	return newObject

	--[[
	if newObject.x < self.minX or newObject.maxX > self.maxX or
	newObject.y < self.minY or newObject.maxY > self.maxY then
	self.minX = math.min(self.minX, newObject.x)
	self.maxX = math.max(self.maxX, newObject.maxX)
	self.minY = math.min(self.minY, newObject.y)
	self.maxY = math.max(self.maxY, newObject.maxY)
	self:updateBorder()
	end]]
end

function EditorMap:removeObjectPartner( partner )
	for k, obj in pairs(self.objectList) do
		if obj == partner then
			table.remove( self.objectList, k )
			break
		end
	end
end
function EditorMap:removeLine( line )
	for i, l in ipairs( self.lines ) do
		if l == line then
			table.remove( self.lines, i )
			break
		end
	end
end

function EditorMap:removeObject( objToRemove )
	if objToRemove.partner then
		self:removeObjectPartner( objToRemove.partner )
	end
	if objToRemove.line then
		self:removeLine( objToRemove.line )
	end
	for k, obj in pairs(self.objectList) do
		if obj == objToRemove then
			table.remove( self.objectList, k )
			break
		end
	end
end

function EditorMap:removeObjectAt( tileX, tileY )
	-- Go through the list backwards and delete the first object found
	-- which is hit by the click:
	local obj
	for k = #self.objectList, 1, -1 do
		obj = self.objectList[k]
		if tileX >= obj.tileX and tileY >= obj.tileY and
			tileX <= obj.maxX-1 and tileY <= obj.maxY-1 then
			--[[for i, ID in pairs(obj.ids) do
			self.backgroundBatch:set( ID, 0,0,0,0,0 )
			table.insert( self.bgEmptyIDs, ID )
			end]]
			--table.remove(self.objectList, k)
			self:removeObject( obj )
			return true		-- only remove the one!
		end
	end
end

function EditorMap:removeSelectedObjects()
	for k, o in pairs( self.selectedObjects ) do
		if not o.batch then
			self:removeObject( o )
			o.selected = false
		end
	end
end

function EditorMap:removeAllSelected()
	self:removeSelectedBgObjects()
	self:removeSelectedObjects()
	self.selectedObjects = {}
end

function EditorMap:findObjectAt( tileX, tileY )
	local obj
	-- Go through the list backwards and select first object found
	for k = #self.objectList, 1, -1 do
		obj = self.objectList[k]
		if obj.vis[1] then
			if tileX >= obj.tileX and tileY >= obj.tileY and
				tileX < obj.maxX and tileY < obj.maxY then
				return obj
			end
		end
	end
	
	-- If no normal object was found, check the background objects:
	-- Go through the list backwards and select first object found
	for k = #self.bgList, 1, -1 do
		obj = self.bgList[k]
		if tileX >= obj.x and tileY >= obj.y and tileX <= obj.maxX and tileY <= obj.maxY then
			return obj
		end
	end
end

--[[
function EditorMap:selectObjectAt( tileX, tileY )

	-- unselect previously selected objects:
	self:selectNoObject()

	local obj = self:findObjectAt( tileX, tileY )
	if obj then
				self.selectedObjects = obj
				obj.selected = true
				obj.oX = tileX - obj.x
				obj.oY = tileY - obj.y
			end

				return obj
end]]
--[[
function EditorMap:eelectNoObject()
	if self.selectedObject then
		self.selectedObject.selected = false
		self.selectedObject = nil
	end
end]]

function EditorMap:dragObject( tileX, tileY )
	for k, obj in pairs( self.selectedObjects ) do
		if obj.isBackgroundObject then
			obj.x = tileX - obj.oX
			obj.y = tileY - obj.oY
			obj.maxX = obj.x + obj.tileWidth
			obj.maxY = obj.y + obj.tileHeight
			obj.drawX = obj.x*self.tileSize
			obj.drawY = obj.y*self.tileSize

			if obj.x < self.minX or obj.maxX > self.maxX or
				obj.y < self.minY or obj.maxY > self.maxY then
				self.minX = math.min(self.minX, obj.x)
				self.maxX = math.max(self.maxX, obj.maxX)
				self.minY = math.min(self.minY, obj.y)
				self.maxY = math.max(self.maxY, obj.maxY)
				self:updateBorder()
			end
		else
			obj.x = tileX - obj.oX
			obj.y = tileY - obj.oY

			-- for selecting:
			obj.tileX = math.floor(obj.x - 0.5)
			obj.tileY = math.floor(obj.y - 0.5)
			obj.maxX = obj.tileX + 1
			obj.maxY = obj.tileY + 1
			-- for drawing borders in editor:
			obj.editorX = obj.x*self.tileSize - obj.width*0.5
			obj.editorY = obj.y*self.tileSize - obj.height*0.5

			if obj.tileX < self.minX or obj.tileX > self.maxX or
				obj.tileY < self.minY or obj.tileY > self.maxY then
				self.minX = math.min(self.minX, obj.tileX)
				self.maxX = math.max(self.maxX, obj.maxX)
				self.minY = math.min(self.minY, obj.tileY)
				self.maxY = math.max(self.maxY, obj.maxY)
				self:updateBorder()
			end

			if obj.tag == "LineHook" and obj.line and obj.partner then
				obj.line.x = obj.x
				obj.line.y = obj.y
				obj.line.x2 = obj.partner.x
				obj.line.y2 = obj.partner.y
			end
		end
	end
end

function EditorMap:setObjectProperty( property, value, obj )
	obj = obj or self.selectedObjects
	if obj then
		obj.properties[property] = value
	end
end

function EditorMap:getObjectProperty( property, obj )
	obj = obj or self.selectedObjects
	if obj then
		return obj.properties[property]
	end
end
----------------------------------------
-- General:
----------------------------------------

function EditorMap:createBorderLine( minX, minY, maxX, maxY )	-- xD

	local border = {}
	local padding = self.tileSize*0.25

	for ang = 0, math.pi/2, math.pi/8 do
		border[#border+1] = minX + padding - padding*math.cos(ang)		-- x
		border[#border+1] = minY + padding - padding*math.sin(ang)		-- y
	end
	for ang = math.pi/2, math.pi, math.pi/8 do
		border[#border+1] = maxX - padding - padding*math.cos(ang)		-- x
		border[#border+1] = minY + padding - padding*math.sin(ang)		-- y
	end
	for ang = math.pi, 3*math.pi/2, math.pi/8 do
		border[#border+1] = maxX - padding - padding*math.cos(ang)		-- x
		border[#border+1] = maxY - padding - padding*math.sin(ang)		-- y
	end
	for ang = 3*math.pi/2, 2*math.pi, math.pi/8 do
		border[#border+1] = minX + padding - padding*math.cos(ang)		-- x
		border[#border+1] = maxY - padding - padding*math.sin(ang)		-- y
	end

	return border
end

function EditorMap:updateBorder()

	-- correct to make minimum size true:
	if self.minX + MIN_MAP_SIZE > self.maxX then
		self.minX = self.maxX - MIN_MAP_SIZE
	end
	if self.minY + MIN_MAP_SIZE > self.maxY then
		self.minY = self.maxY - MIN_MAP_SIZE
	end

	local minX = self.minX*self.tileSize
	local minY = self.minY*self.tileSize
	local maxX = self.maxX*self.tileSize
	local maxY = self.maxY*self.tileSize
	self.border = self:createBorderLine( minX, minY, maxX, maxY )

	self.borderMarkers[1].x = (self.minX-markerOffset1.x)*self.tileSize
	self.borderMarkers[1].y = (self.minY-markerOffset1.y)*self.tileSize

	self.borderMarkers[2].x = (self.minX-markerOffset2.x)*self.tileSize
	self.borderMarkers[2].y = (self.maxY-markerOffset2.y)*self.tileSize

	self.borderMarkers[3].x = (self.maxX-markerOffset3.x)*self.tileSize
	self.borderMarkers[3].y = (self.minY-markerOffset3.y)*self.tileSize

	self.borderMarkers[4].x = (self.maxX-markerOffset4.x)*self.tileSize
	self.borderMarkers[4].y = (self.maxY-markerOffset4.y)*self.tileSize

	-- update border tiles:
	-- Brute force:
	for x = self.minX, self.maxX-1 do
		for y = self.minY, self.maxY-1 do
			if self.backgroundArray[x] and self.backgroundArray[x][y] then
				self:queueBackgroundTileUpdate( x, y, true )
			end
			if self.groundArray[x] and self.groundArray[x][y] then
				self:queueGroundTileUpdate( x, y, true )
			end
		end
	end
	--[[ old method:
	for x = self.minX, self.maxX do
		if self.backgroundArray[x] then
			if self.backgroundArray[x][self.minY] then
				self:updateBackgroundTile( x, self.minY )
			end
			if self.backgroundArray[x][self.maxY] then
				self:updateBackgroundTile( x, self.maxY )
			end
		end
		if self.groundArray[x] then
			if self.groundArray[x][self.minY] then
				self:updateGroundTile( x, self.minY )
			end
			if self.groundArray[x][self.maxY-1] then
				self:updateGroundTile( x, self.maxY-1 )
			end
		end
	end
	for y = self.minY, self.maxY do
			if self.backgroundArray[self.minX] and self.backgroundArray[self.minX][y] then
				self:updateBackgroundTile( self.minX, y )
			end
			if self.groundArray[self.minX] and self.groundArray[self.minX][y] then
				self:updateGroundTile( self.minX, y )
			end
			if self.backgroundArray[self.maxX-1] and self.backgroundArray[self.maxX-1][y] then
				self:updateBackgroundTile( self.maxX-1, y )
			end
			if self.groundArray[self.maxX-1] and self.groundArray[self.maxX-1][y] then
				self:updateGroundTile( self.maxX-1, y )
			end
	end]]
end

-- check if mouse is hovering over a border marker:
function EditorMap:collisionCheckBorderMarker( x, y )
	for i = 1, 4 do
		if x > self.borderMarkers[i].x and
			y > self.borderMarkers[i].y and
			x < self.borderMarkers[i].x + self.borderMarkers[i].img:getWidth() and
			y < self.borderMarkers[i].y + self.borderMarkers[i].img:getHeight() then
			
			return self.borderMarkers[i]
		end
	end
end

-- select the border marker which you're hovering over:
function EditorMap:selectBorderMarker( x, y )
	for i = 1, 4 do
		if x > self.borderMarkers[i].x and
			y > self.borderMarkers[i].y and
			x < self.borderMarkers[i].x + self.borderMarkers[i].img:getWidth() and
			y < self.borderMarkers[i].y + self.borderMarkers[i].img:getHeight() then
			
			--self.borderMarkers[i].dragged = true
			self.draggedBorderMarker = self.borderMarkers[i]
			self.borderMarkers[i].oX = x - self.borderMarkers[i].x
			self.borderMarkers[i].oY = y - self.borderMarkers[i].y
			return self.borderMarkers[i]
		end
	end
end

function EditorMap:dragBorderMarker( x, y )
	if self.draggedBorderMarker then
		self.draggedBorderMarker.x = x - self.draggedBorderMarker.oX
		self.draggedBorderMarker.y = y - self.draggedBorderMarker.oY

		local minX, minY, maxX, maxY = self.minX, self.minY, self.maxX, self.maxY
		if self.draggedBorderMarker == self.borderMarkers[1] then	-- top left
			minX = math.ceil( self.draggedBorderMarker.x/self.tileSize+markerOffset1.x - 0.5 )
			minY = math.ceil( self.draggedBorderMarker.y/self.tileSize+markerOffset1.y - 0.5 )
			if minX > maxX - 3 then
				minX = maxX - 3
			end
			if minY > maxY - 3 then
				minY = maxY - 3
			end
		elseif self.draggedBorderMarker == self.borderMarkers[2] then	-- bottom left
			minX = math.ceil( self.draggedBorderMarker.x/self.tileSize+markerOffset2.x - 0.5 )
			maxY = math.ceil( self.draggedBorderMarker.y/self.tileSize+markerOffset2.y - 0.5 )
			if minX > maxX - 3 then
				minX = maxX - 3
			end
			if maxY < minY + 3 then
				maxY = minY + 3
			end
		elseif self.draggedBorderMarker == self.borderMarkers[3] then
			maxX = math.ceil( self.draggedBorderMarker.x/self.tileSize+markerOffset3.x - 0.5 )
			minY = math.ceil( self.draggedBorderMarker.y/self.tileSize+markerOffset3.y - 0.5 )
			if maxX < minX + 3 then
				maxX = minX + 3
			end
			if minY > maxY - 3 then
				minY = maxY - 3
			end
		elseif self.draggedBorderMarker == self.borderMarkers[4] then
			maxX = math.ceil( self.draggedBorderMarker.x/self.tileSize+markerOffset4.x - 0.5 )
			maxY = math.ceil( self.draggedBorderMarker.y/self.tileSize+markerOffset4.y - 0.5 )
			if maxX < minX + 3 then
				maxX = minX + 3
			end
			if maxY < minY + 3 then
				maxY = minY + 3
			end
		end


		self.tempBorder = self:createBorderLine( minX*self.tileSize, minY*self.tileSize,
												maxX*self.tileSize, maxY*self.tileSize )
	end
end

function EditorMap:dropBorderMarker()
	if self.draggedBorderMarker == self.borderMarkers[1] then	-- top left
		self.minX = math.ceil(self.draggedBorderMarker.x/self.tileSize+markerOffset1.x-0.5)
		self.minY = math.ceil(self.draggedBorderMarker.y/self.tileSize+markerOffset1.x-0.5)
		if self.minX > self.maxX - 3 then
			self.minX = self.maxX - 3
		end
		if self.minY > self.maxY - 3 then
			self.minY = self.maxY - 3
		end
	elseif self.draggedBorderMarker == self.borderMarkers[2] then	-- bottom left
		self.minX = math.ceil(self.draggedBorderMarker.x/self.tileSize+markerOffset2.x-0.5)
		self.maxY = math.ceil(self.draggedBorderMarker.y/self.tileSize+markerOffset2.y-0.5)
		if self.minX > self.maxX - 3 then
			self.minX = self.maxX - 3
		end
		if self.maxY < self.minY + 3 then
			self.maxY = self.minY + 3
		end
	elseif self.draggedBorderMarker == self.borderMarkers[3] then
		self.maxX = math.ceil(self.draggedBorderMarker.x/self.tileSize+markerOffset3.x-0.5)
		self.minY = math.ceil(self.draggedBorderMarker.y/self.tileSize+markerOffset3.y-0.5)
		if self.maxX < self.minX + 3 then
			self.maxX = self.minX + 3
		end
		if self.minY > self.maxY - 3 then
			self.minY = self.maxY - 3
		end
	elseif self.draggedBorderMarker == self.borderMarkers[4] then
		self.maxX = math.ceil(self.draggedBorderMarker.x/self.tileSize+markerOffset4.x-0.5)
		self.maxY = math.ceil(self.draggedBorderMarker.y/self.tileSize+markerOffset4.y-0.5)
		if self.maxX < self.minX + 3 then
			self.maxX = self.minX + 3
		end
		if self.maxY < self.minY + 3 then
			self.maxY = self.minY + 3
		end
	end
	self:updateBorder()
	self.draggedBorderMarker = nil
end

function EditorMap:drawGrid()
	love.graphics.setColor(255,255,255,25)
	for x = 0, love.graphics.getWidth(), tileSize do
		love.graphics.line( x, 0, x, love.graphics.getHeight() )
	end
	for y = 0, love.graphics.getHeight(), tileSize do
		love.graphics.line( 0, y, love.graphics.getWidth(), y )
	end
	love.graphics.setColor(255,255,255,255)
end

function EditorMap:drawBackground()
	for i = 1, #self.backgroundBatch do
		love.graphics.draw( self.backgroundBatch[i], 0, 0 )
	end
	if mode == "editor" then
	for k, obj in ipairs( self.bgList ) do
		if obj.selected == true then
			love.graphics.setColor(255,150,150,255)
			--love.graphics.draw( obj.batch, obj.drawX, obj.drawY )
			love.graphics.draw( obj.objType.tileset, obj.objType.quad, obj.drawX, obj.drawY )
			love.graphics.setColor(255,255,255,255)
			love.graphics.rectangle( "line", obj.drawX, obj.drawY, obj.width, obj.height )
		else
			love.graphics.setColor(255,255,255,255)
			--love.graphics.draw( obj.batch, obj.drawX, obj.drawY )
			love.graphics.draw( obj.objType.tileset, obj.objType.quad, obj.drawX, obj.drawY )
		end
		if DEBUG then
		love.graphics.setColor(255,0,0,150)
			love.graphics.rectangle( "fill", obj.x*self.tileSize,
				obj.y*self.tileSize,
				obj.maxX*self.tileSize - obj.x*self.tileSize,
				obj.maxY*self.tileSize - obj.y*self.tileSize)
		love.graphics.setColor(255,255,255,255)
	end
	end
else

	love.graphics.draw( self.bgObjectSpriteBatch )
end
end

function EditorMap:drawBackgroundTypes( cam )
	local startX, startY = cam:screenToWorld(0,0)
	local endX, endY = cam:screenToWorld(love.graphics.getWidth(), love.graphics.getHeight())

	startX, startY = math.floor(startX/self.tileSize), math.floor(startY/self.tileSize)
	endX, endY = math.floor(endX/self.tileSize), math.floor(endY/self.tileSize)
	for x = startX, endX do
		if self.backgroundArray[x] then
			for y = startY, endY do
				if self.backgroundArray[x][y] and self.backgroundArray[x][y].gType then
					love.graphics.print( self.backgroundArray[x][y].gType.matchName,
						(x+0.5)*self.tileSize,
						(y+0.5)*self.tileSize)
				end
			end
		end
	end
end

function EditorMap:drawObjects()
	local x,y,height,width
	for k, obj in ipairs( self.objectList ) do
		--love.graphics.draw( obj.batch, obj.drawX, obj.drawY )

		if obj.selected == true then
			love.graphics.setColor(255,150,150,255)
			obj:draw()
			x,y = obj.editorX, obj.editorY
			width,height = math.max(30,obj.width), math.max(30,obj.height) 
			love.graphics.setColor(255,255,255,255)
			love.graphics.rectangle( "line", x, y, width, height)
		else
			love.graphics.setColor(255,255,255,255)
			obj:draw()
		end
		if DEBUG then
		love.graphics.setColor(255,0,0,150)
			love.graphics.rectangle( "fill", obj.tileX*self.tileSize,
				obj.tileY*self.tileSize,
				obj.maxX*self.tileSize - obj.tileX*self.tileSize,
				obj.maxY*self.tileSize - obj.tileY*self.tileSize)
		love.graphics.setColor(255,255,255,255)
	end
	end
	--love.graphics.setColor(255,255,255)
end

function EditorMap:drawLines()
	for k, obj in ipairs( self.lines ) do
		--love.graphics.draw( obj.batch, obj.drawX, obj.drawY )
		obj:draw()
	end
end


function EditorMap:drawGround()
	love.graphics.draw( self.groundBatch, 0, 0 )	
end

function EditorMap:drawForeground()
	love.graphics.draw( self.spikeBatch, 0, 0 )
end

function EditorMap:drawBorder()
	love.graphics.polygon( "line", self.border )
	if self.draggedBorderMarker and self.tempBorder then
		love.graphics.setColor( 150,255,150, 100 )
		love.graphics.polygon( "line", self.tempBorder )
		love.graphics.setColor( 255,255,255, 255 )
	end
	for i = 1, 4 do
		love.graphics.draw( self.borderMarkers[i].img, self.borderMarkers[i].x,
			self.borderMarkers[i].y )
	end
end

function EditorMap:update( dt, forceUpdateAll )
	self.tilesModifiedThisFrame = 0

	while #self.tilesToModify > 0 and
		(self.tilesModifiedThisFrame < MAX_TILES_PER_FRAME or forceUpdateAll) do
		local data = self.tilesToModify[1]
		if data.command == "update" then
			if self.groundArray[data.x] and self.groundArray[data.x][data.y] and
				self.groundArray[data.x][data.y].gType then
				self:updateGroundTile( data.x, data.y, data.noMoreRecursion )
			end
		elseif data.command == "updateBg" then
			if self.backgroundArray[data.x] and self.backgroundArray[data.x][data.y] and
				self.backgroundArray[data.x][data.y].gType then
				self:updateBackgroundTile( data.x, data.y )
			end
		end
		table.remove( self.tilesToModify, 1 )
	end
end

-- pass a full name including the path!
function EditorMap:loadFromFile( fullName )
	local map = nil

	local mapName = fullName:match("([^/]*).dat$")

	local str = love.filesystem.read( fullName )

	if str then

		local dimX,dimY = str:match("Dimensions: (.-),(.-)\n")
		local description = str:match("Description:\n(.-)endDescription\n")
		--local minX, maxX = -math.floor(dimX/2), math.floor(dimX/2)
		--local minY, maxY = -math.floor(dimY/2), math.floor(dimY/2)
		local minX, maxX = 0, tonumber(dimX)
		local minY, maxY = 0, tonumber(dimY)
		local bg = str:match("Background:(.-)endBackground\n")
		local ground = str:match("Ground:(.-)endGround\n")
		local bgObjects = str:match("BgObjects:(.-)endBgObjects\n")
		local objects = str:match("Objects:(.-)endObjects\n")

		local backgroundsList = {}
		for k,b in pairs(editor.backgroundList) do
			backgroundsList[b.matchName] = b
		end
		local groundsList = {}
		for k,b in pairs(editor.groundList) do
			groundsList[b.matchName] = b
		end
		local bgObjList = {}
		for k,category in pairs(editor.bgObjectList) do
			for i,b in pairs( category ) do
				bgObjList[b.name] = b
			end
		end
		local objList = {}
		for k,b in pairs(editor.objectList) do
			objList[b.tag] = b
		end

		map = EditorMap:new( editor.backgroundList )

		math.randomseed( 1 )

		map.minX, map.maxX = minX+1, maxX
		map.minY, map.maxY = minY+1, maxY
		map.width = map.maxX - map.minX
		map.height = map.maxY - map.minY
		map.name = string.lower(mapName or "" )
		map.description = string.lower(description or "" )

		local matchName
		local y = 0
		for line in bg:gmatch("(.-)\n") do
			for x = 1, #line do
				matchName = line:sub(x, x)
				if backgroundsList[matchName] then
					map:setBackgroundTile( x + minX, y + minY, backgroundsList[matchName], true )
				end
			end
			y = y + 1
		end

		map.collisionSrc = {}

		local order = {'b','c','d','g','s','w','1','2'}
		
		for tileCounter, currentTile in ipairs(order) do
		y = 0
			for line in ground:gmatch("(.-)\n") do
				for x = 1, #line do
					map.collisionSrc[x] = map.collisionSrc[x] or {}
					matchName = line:sub(x, x)
					if matchName == currentTile then
						if groundsList[matchName] then
							if matchName == "b" then	-- bridge
								map.collisionSrc[x][y] = 2
							elseif matchName == "1" or matchName == "2" then	-- spikes
								map.collisionSrc[x][y] = 3
								map:addObject( x, y, "Spikey" ) -- +1 because collision map starts at 0
							else
								map.collisionSrc[x][y] = 1		-- normal wall
							end
							map:setGroundTile( x + minX, y + minY, groundsList[matchName], true )
						else
							map.collisionSrc[x][y] = nil
						end
					end
				end
				y = y + 1
			end
		end

		--[[print("------------------------")
		print("Collision Map:")
		local str
		for y = 1, map.height do
			str = ""
			for x = 1, map.width do
				if map.collisionSrc[x] and map.collisionSrc[x][y] then
					str = str .. map.collisionSrc[x][y]
				else
					str = str .. "-"
				end
			end
			print(str)
		end]]

		local objType,x,y
		for line in bgObjects:gmatch("[^\r\n]+") do
			objType, x, y = line:match( "\t(.-) (.-) (.-)$")

			if not objType or not x or not y then	-- fallback to legacy:
				objType = obj:match( "Obj:(.-)\n")
				x = obj:match( "x:(.-)\n")
				y = obj:match( "y:(.-)\n")
			end

			x = tonumber(x)
			y = tonumber(y)
			if bgObjList[objType] then
				map:addBgObject( x + minX+1, y + minY+1, bgObjList[objType] )
			end
		end

		for obj in objects:gmatch( "(Obj:.-endObj)\n" ) do			
			objType = obj:match( "Obj:(.-)\n")
			x = obj:match( "x:(.-)\n")
			y = obj:match( "y:(.-)\n")

			x = tonumber(x)
			y = tonumber(y)
			if objList[objType] then
				local newObject = map:addObject( x + minX + 1, y + minY + 1, objType )
				if newObject then
					for property, value in obj:gmatch("p:(.-)=(.-)\n")do
						newObject:setProperty( property, value )
					end
					newObject:applyOptions()
				end
			end

			if objType == "Player" then
				map.xStart = x + 1
				map.yStart = y + 1
			end
			
		end

		-- Postprocess
		--map.factoryList = map:FactoryList(o.tileOBJ,o.height,o.width) -- see at the end of this file
		--map.lineList = map:LineList(o.tileOBJ,o.height,o.width)
		map.lineList = {}



		-- Update all map tiles to make sure the right
		-- tile type is used. Force to update all the 
		-- tiles that need updating
		map:update( nil, true )
		map:updateBorder()

		if mode == "editor" then
			menu:newLevelName( "loaded: " .. mapName, true )
		end
	else
		print( fullName .. " not found." )
	end
	return map
end

function EditorMap:convert( fullName )

	local groundMatch = {}
	local CONCRETE = 1
	local DIRT = 2
	local GRASS = 3
	local STONE = 4
	local WOOD = 5
	local BRIDGE = 6
	local SPIKES_G = 7
	local SPIKES_B = 8
	-- Base tiles:
	-- NOTE: commas at beginning an end are a quick fix to avoid matching "10," when "0,"
	-- is what we're looking for. Instead, we match ",0,". It's a little dirty, but effective.
	groundMatch[CONCRETE] = ",25,26,27,28,33,34,35,36,41,42,43,44,49,50,51,52,117,118,119,120,126,127,128,"
	groundMatch[DIRT] = ",29,30,31,32,37,38,39,40,45,46,47,48,53,54,55,56,94,96,102,104,109,111,"
	groundMatch[GRASS] = ",57,58,59,60,65,66,67,68,73,74,75,76,81,82,83,84,93,95,101,103,110,112,"
	groundMatch[STONE] = ",61,62,63,64,69,70,71,72,77,78,79,80,85,86,87,88,"
	groundMatch[WOOD] = ",89,90,91,92,97,98,99,100,105,106,107,108,113,114,115,116,"
	groundMatch[BRIDGE] = ",7,8,13,14,15,"
	groundMatch[SPIKES_G] = ",33,34,35,36,41,42,43,44,49,50,51,52,57,58,59,60,"
	groundMatch[SPIKES_B] = ",37,38,39,40,45,46,47,48,53,54,55,56,61,62,63,64,"

	local objectMatch = {}
	objectMatch["Exit"] = ",2,"
	objectMatch["Bandana"] = ",4,"
	objectMatch["Button"] = ",17,"
	objectMatch["Appearblock"] = ",19,"
	objectMatch["Walker"] = ",31,32,"
	objectMatch["Spawner"] = ",77,78,"
	objectMatch["Bonus"] = ",14,"

	local map = nil

	local mapName = fullName:match("([^/]*).dat$")

	local str = love.filesystem.read( fullName )

	if str then

		local dimX,dimY = str:match("mapSize((.-),(.-))")
		local startX, startY = str:match("start{x=(.-),y=(.-)}")
		--local startX, startY = str:match("start{(.-)}")
		local walls = str:match("loadWall{(.-})[^,]-}")
		local foreground = str:match("loadFG{(.-})[^,]-}")
		local objects = str:match("loadOBJ{(.-})[^,]-}")

		map = EditorMap:new( editor.backgroundList )
		map.name = string.lower(mapName or "" )

		print("------------------------")
		print(map.name, map.description)
		--print(walls)
		--
		map.minX = 1
		map.minY = 1
		map.maxX = tonumber(dimX) or 0
		map.maxY = tonumber(dimY) or 0

		local y = 1
		local x = 1
		for line in walls:gmatch("{(.-)}") do
			y = 1
			for tile in line:gmatch("(%d+)") do
				k = tonumber(tile)
				if k ~= 0 then
					for i = 1, 6 do
						if groundMatch[i] and groundMatch[i]:find( "," .. tile .. "," ) then
							map:setGroundTile( x, y, editor.groundList[i], false )
							break
						end
					end
				end
				y = y + 1
			end
			x = x + 1
		end

		x, y = 1, 1
		for line in foreground:gmatch("{(.-)}") do
			y = 1
			for tile in line:gmatch("(%d+)") do
				k = tonumber(tile)
				if k ~= 0 then
					for i = 7, 8 do
						if groundMatch[i] and groundMatch[i]:find( "," .. tile .. "," ) then
							map:setGroundTile( x, y, editor.groundList[i], false )
							break
						end
					end
				end
				y = y + 1
			end
			x = x + 1
		end

		x, y = 1, 1
		for line in objects:gmatch("{(.-)}") do
			y = 1
			for tile in line:gmatch("(%d+)") do
				k = tonumber(tile)
				if k ~= 0 then
					for tag, matchList in pairs(objectMatch) do
						if matchList:find( "," .. tile .. "," ) then
							map:addObject( x, y, tag )
							break
						end
					end
				end
				y = y + 1
			end
			x = x + 1
		end

		-- add player if found:
		if startX and startY then
			map:addObject( tonumber(startX), tonumber(startY), "Player" )
		end

		-- Update all map tiles to make sure the right
		-- tile type is used. Force to update all the 
		-- tiles that need updating:
		map:update( nil, true )
		map:updateBorder()
	else
		print( fullName .. " not found." )
	end
	return map
end

-----------------------------------
-- Functions related to saving:
-----------------------------------

function EditorMap:dimensionsToString()
	return "Dimensions: " .. self.maxX - self.minX+1 .. "," .. self.maxY - self.minY+1 .. "\n"
end

function EditorMap:descriptionToString()
	-- force to lowercase: This makes sure that the keywords cannot be found, because they all
	-- have uppercase letters.
	self.description = string.lower(self.description or "" )
	return self.description or "" .. "\n"
end

function EditorMap:backgroundToString()
	local str = ""
	for y = self.minY, self.maxY-1 do
		for x = self.minX, self.maxX-1 do
			if self.backgroundArray[x] and self.backgroundArray[x][y] and
				self.backgroundArray[x][y].gType and
				self.backgroundArray[x][y].gType.matchName then
				str = str .. self.backgroundArray[x][y].gType.matchName
			else
				str = str .. "-"
			end
		end
		str = str .. "\n"
	end
	return str
end

function EditorMap:groundToString()
	local str = ""
	for y = self.minY, self.maxY-1 do
		for x = self.minX, self.maxX-1 do
			if self.groundArray[x] and self.groundArray[x][y] and
				self.groundArray[x][y].gType and
				self.groundArray[x][y].gType.matchName then
				str = str .. self.groundArray[x][y].gType.matchName
			else
				str = str .. "-"
			end
		end
		str = str .. "\n"
	end
	return str
end

function EditorMap:backgroundObjectsToString()
	local str = ""
	-- Add the objects in order of appearance:
	for k, obj in ipairs(self.bgList) do
		str = str .. "\t" .. obj.objType.name ..
					" " .. obj.x - self.minX ..
					" " .. obj.y - self.minY .. "\n"
	end
	return str
end

function EditorMap:objectsToString()
	local str = ""
	-- Add the objects in order of appearance:
	for k, obj in ipairs(self.objectList) do
		if obj.tag ~= "Spikey" and obj.tag ~= "Line" then
			str = str .. "Obj:" .. obj.tag .. "\n"
			str = str .. "\tx:" .. obj.tileX - self.minX .. "\n"
			str = str .. "\ty:" .. obj.tileY - self.minY .. "\n"
			if obj.properties then
				for name, p in pairs( obj.properties ) do
					str = str .. "\tp:" .. name .. "=" ..  obj[name] .. "\n"
				end
			end
			str = str .. "endObj\n"
		end
	end
	return str
end

----------------------------------------------------
-- In Game functions:
-- The following functions are only needed in-game, not in the editor:
----------------------------------------------------
local tileSize = 48		-- fallback

function EditorMap:convertForShadows( h, w )
end

function EditorMap:updateShadows()
end

function EditorMap:queueShadowUpdate()
end

function EditorMap:initShadows()
end

function EditorMap:addLight( x, y )
end

function EditorMap:start(p)

	game.deathtimer = 0
	shaders:resetDeathEffect()
	game.restartingLevel = false

	-- reset collision table
	self.collision = utility.copy(self.collisionSrc,true)

	-- empty spriteEngine and add player
	spriteEngine:empty()
	spriteEngine:insert(p)
	if p.originalSemiwidth and p.originalSemiheight then
		p:resize(p.originalSemiwidth, p.originalSemiheight)
	end
	p.x = self.xStart+0.5
	p.y = self.yStart+1-p.semiheight
	p.newX = p.x
	p.newY = p.y
	p.vx = 0
	p.vy = 0
	p.bandana = 'white'
	p.alpha = 255
	p.status = 'stand'
	p:setAnim(1,'whiteStand')
	p:flip(false)
	p.anchor = nil
	p.hookAngle = nil
	p:update(0)
	p.dead = nil
	--mode = 'intro'
	--timer = 0
	Camera:jumpTo(p.x,p.y)

	for i, obj in ipairs(self.objectList) do
		if obj.tag == "Player" then
			table.remove( self.objectList, i )
			break
		end
	end

	for i, obj in ipairs(self.objectList) do
		--[[local constructor = self.factoryList[i].constructor
		local nx = self.factoryList[i].x +0.5
		local ny = self.factoryList[i].y +1 - constructor.semiheight
		if constructor.layout == "top" then
			ny = self.factoryList[i].y + constructor.semiheight
		elseif constructor.layout == "left" then
			nx = self.factoryList[i].x + constructor.semiwidth
			ny = self.factoryList[i].y + 0.5
		elseif constructor.layout == "right" then
			nx = self.factoryList[i].x + 1 - constructor.semiwidth
			ny = self.factoryList[i].y + 0.5
		elseif constructor.layout == "center" then
			ny = self.factoryList[i].y + 0.5
		end
		local newObject = constructor:New({x = nx, y = ny})
		]]
		if obj.tag ~= "LineHook" then
			local newObj = obj:New()
			newObj:update(0)
			spriteEngine:insert(newObj)
		end
	end
	for i, obj in ipairs(self.lines) do
			local newObj = obj:New()
			newObj:update(0)
			spriteEngine:insert(newObj)
	end
	--[[
	for i = 1,#self.lineList do
		local newObject = Line:New({
			x = self.lineList[i].x,
			y = self.lineList[i].y,
			x2 = self.lineList[i].x2,
			y2 = self.lineList[i].y2,
		})
		spriteEngine:insert(newObject)
	end]]

	if settings:getShadowsEnabled() then
		local list = {}
		spriteEngine:DoAll('collectLights',list)
		self:initShadows()

		if #list > 0 then

			for k, v in pairs(list) do
				self:addLight(v.x, v.y)
			end		

		end
	end --end if USE_SHADOWS

	levelEnd:registerStart()
end

function EditorMap:drawParallax(world)
	local world = world or Campaign.worldNumber
	love.graphics.draw(AnimationDB.background[world],AnimationDB.backgroundQuad,0,0)
end

function EditorMap:collisionTest(x,y,direction,tag)
	-- Given the (integer) coordinates of a cell, check if there is a
	-- collision entry in this cell and then check if collisionNumber causes
	-- a collision


	local collisionNumber
	-- check if entry exists at all
	if self.collision[x] and self.collision[x][y] then
		collisionNumber = self.collision[x][y]
	else
		return false
	end

	--print ('collisionTest with direction '..direction..' and tag ' .. tag .. ', CollisionNr: '..collisionNumber)	

	if tag == 'Player' then -- player does not collide with spikes
		if direction == 'down' then -- down collides with 1 and 2
			if collisionNumber == 1 or collisionNumber == 2 then
				return true
			else
				return false
			end
		else -- other direction collides with 1 only
			if collisionNumber == 1 then
				return true
			else
				return false
			end
		end
	else -- everything else collides with spikes
		if direction == 'down' then -- down collides with 1, 2 and 3
			if collisionNumber == 1 or collisionNumber == 2 or collisionNumber == 3 then
				return true
			else
				return false
			end
		else -- other directions collides with 1 and 3
			if collisionNumber == 1 or collisionNumber == 3 then
				return true
			else
				return false
			end			
		end
	end
end

function EditorMap:lineOfSight(x1,y1,x2,y2)
	-- Determines if a straight line between two points collides with the map
	local fx1,fy1,fx2,fy2 = math.floor(x1),math.floor(y1),math.floor(x2),math.floor(y2)
	local dx,dy = fx1-fx2,fy1-fy2
	if dy > 0 then sy = -1 else sy = 1 end
	if dx > 0 then sx = -1 else sx = 1 end  

	local ok
	ok = function(number)
		if not number then return false end
		if number == 1 or number == 3 then return true end
		if sy == 1 and number == 2 then return true end
	end

	if fx1 == fx2 then
		for yy = fy1,fy2,sy do
			if self.collision[fx1] and ok(self.collision[fx1][yy]) then
				local yReturn = yy + 0.5 - 0.5*sy
				local xReturn = x1 + (yReturn-y1)/(y2-y1)*(x2-x1)
				return false,xReturn,yReturn
			end
		end
		return true
	end

	if fy1 == fy2 then
		for xx = fx1,fx2,sx do
			if self.collision[xx] and self.collision[xx][fy1] then
				local xReturn = xx + 0.5 - 0.5*sx
				local yReturn = y1 + (xReturn-x1)/(x2-x1)*(y2-y1)
				return false,xReturn,yReturn
			end
		end
		return true
	end 



	if math.abs(dx) > math.abs(dy) then -- schleife über y
		local m = (x2-x1)/(y2-y1)
		local xx2 = math.floor(m*(fy1+math.max(0, sy))-m*y1+x1)
		for xx = fx1,xx2,sx do
			if self.collision[xx] and ok(self.collision[xx][fy1]) then
				local xReturn = xx + 0.5 - 0.5*sx
				local yReturn = y1 + (xReturn-x1)/m
				return false,xReturn,yReturn
			end
		end
		for yy = fy1+sy,fy2-sy,sy do
			local xx1 = math.floor(m*(yy+math.max(0,-sy))-m*y1+x1)
			local xx2 = math.floor(m*(yy+math.max(0, sy))-m*y1+x1)
			for xx = xx1,xx2,sx do
				if self.collision[xx] and ok(self.collision[xx][yy]) then
					if xx == xx1 then -- collision from above or below
						local yReturn = yy + 0.5 - 0.5*sy
						local xReturn = x1 + (yReturn-y1)*m
						return false,xReturn,yReturn						
					else -- collision from left or right
						local xReturn = xx + 0.5 - 0.5*sx
						local yReturn = y1 + (xReturn-x1)/m
						return false,xReturn,yReturn
					end
				end
			end
		end
		local xx1 = math.floor(m*(fy2+math.max(0, -sy))-m*y1+x1)
		for xx = xx1,fx2,sx do
			if self.collision[xx] and ok(self.collision[xx][fy2]) then
				if xx == xx1 then -- collision from above or below
					local yReturn = fy2 + 0.5 - 0.5*sy
					local xReturn = x1 + (yReturn-y1)*m
					return false,xReturn,yReturn						
				else -- collision from left or right
					local xReturn = xx + 0.5 - 0.5*sx
					local yReturn = y1 + (xReturn-x1)/m
					return false,xReturn,yReturn
				end
			end
		end
		return true
	else -- schleife über x
		local m = (y2-y1)/(x2-x1)
		local yy2 = math.floor(m*(fx1+math.max(0, sx))-m*x1+y1)
		if myMap.collision[fx1] then
			for yy = fy1,yy2,sy do
				if ok(self.collision[fx1][yy]) then
					local yReturn = yy + 0.5 - 0.5*sy
					local xReturn = x1 + (yReturn-y1)/m
					return false,xReturn,yReturn
				end
			end
		end
		for xx = fx1+sx,fx2-sx,sx do
			if self.collision[xx] then
				local yy1 = math.floor(m*(xx+math.max(0,-sx))-m*x1+y1)
				local yy2 = math.floor(m*(xx+math.max(0, sx))-m*x1+y1)
				for yy = yy1,yy2,sy do
					if ok(self.collision[xx][yy]) then
						if yy == yy1 then -- collision from above or below
							local xReturn = xx + 0.5 - 0.5*sx
							local yReturn = y1 + (xReturn-x1)*m
							return false,xReturn,yReturn						
						else -- collision from left or right
							local yReturn = yy + 0.5 - 0.5*sy
							local xReturn = x1 + (yReturn-y1)/m
							return false,xReturn,yReturn
						end				  
					end
				end
			end
		end
		local yy1 = math.floor(m*(fx2+math.max(0, -sx))-m*x1+y1)
		if self.collision[fx2] then
			for yy = yy1,fy2,sy do
				if ok(self.collision[fx2][yy]) then
					if yy == yy1 then -- collision from above or below
						local xReturn = fx2 + 0.5 - 0.5*sx
						local yReturn = y1 + (xReturn-x1)*m
						return false,xReturn,yReturn						
					else -- collision from left or right
						local yReturn = yy + 0.5 - 0.5*sy
						local xReturn = x1 + (yReturn-y1)/m
						return false,xReturn,yReturn
					end	
				end
			end
		end
		return true
	end
end

function EditorMap:raycast(x,y,vx,vy,dist)
	if vx == 0 and vy == 0 then
		return true,x,y
	end
	local dist = dist or 15
	local length = utility.pyth(vx,vy)
	vx,vy = vx/length,vy/length

	local xTarget = x + dist * vx
	local yTarget = y + dist * vy

	return self:lineOfSight(x,y,xTarget,yTarget)

end

function EditorMap:LineList(tile,height,width)
	local lineList = {}
	local nodeList = {}

	for i=1,width do
		for j = 1,height do
			if tile[i][j] == 8 then
				table.insert(nodeList,{x=i+0.5,y=j+0.5})
			end             
		end
	end
	-- traverse node list and add line for two nodes
	local nLines = math.floor((#nodeList)/2)
	for iLine = 1,nLines do
		table.insert(lineList,{
			x = nodeList[2*iLine-1].x,
			y = nodeList[2*iLine-1].y,
			x2 = nodeList[2*iLine].x,
			y2 = nodeList[2*iLine].y})
	end
	return lineList
end

function EditorMap:FactoryList(tile,height,width)

	local factoryList = {} 
	-- find all entities, add objects to spriteEngine and replace by zero

	local objectList ={
		[ 2] = Exit,
		[ 3] = Bandana.white,
		[ 4] = Bandana.blue,
		[ 5] = Bandana.red,
		[ 6] = Bandana.green,    
		[ 7] = Bouncer,
		[ 9] = Runner,
		[10] = Goalie, 

		[11] = Imitator,
		[12] = Launcher,
		[13] = Cannon,
		[14] = Bonus,
		[16] = Emitter,
		[17] = Button,
		[18] = Appearblock,
		[19] = Disappearblock,
		[20] = Crumbleblock,
		[21] = Glassblock,
		[22] = Keyhole,
		[23] = Door,
		[24] = Key,
		[25] = Windmill,
		[26] = BouncerLeft,
		[27] = BouncerTop,
		[28] = BouncerRight,
		[29] = Bumper,
		[30] = Clubber,
		[31] = WalkerLeft,
		[32] = Walker,

		[33] = Spikey,

		[37] = FixedCannon1r,
		[38] = FixedCannon2r,
		[39] = FixedCannon3r,
		[40] = FixedCannon4r,
		[45] = FixedCannon1d,
		[46] = FixedCannon2d,
		[47] = FixedCannon3d,
		[48] = FixedCannon4d,
		[53] = FixedCannon1l,
		[54] = FixedCannon2l,
		[55] = FixedCannon3l,
		[56] = FixedCannon4l,
		[61] = FixedCannon1u,
		[62] = FixedCannon2u,
		[63] = FixedCannon3u,
		[64] = FixedCannon4u,

		[65] = Light,
		[66] = Torch,
		[67] = Lamp,

		[68] = InputJump,
		[69] = InputAction,
		[70] = InputLeft,
		[71] = InputRight,
		[73] = WalkerDown,
		[74] = WalkerRight,
		[75] = WalkerUp,
		[76] = WalkerLeft,
		[77] = SpawnerLeft,
		[78] = Spawner,
	}

	for i=1,width do
		for j = 1,height do
			if objectList[tile[i][j]] then
				local constr = objectList[tile[i][j]]
				local newObject = {constructor = constr, x = i, y = j}
				table.insert(factoryList,newObject)
			end             
		end
	end
	return factoryList
end

return EditorMap
