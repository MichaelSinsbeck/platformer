local EditorMap = {}
EditorMap.__index = EditorMap

local MAX_TILES_PER_FRAME = 500
local MAX_FLOOD_FILL_RECURSION = 1500

local MIN_MAP_SIZE = 3

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
	o.objectList = {}	-- list of objects
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

	return o
end

-------------------------------------------------------
-- Ground Manupulations (Walls the player collides with)
-------------------------------------------------------

function EditorMap:updateGroundTile( x, y, noMoreRecursion )
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

	self:updateGroundTile( x, y )
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
		self:updateGroundTile( x-1, y )
		--print("right:")
		self:updateGroundTile( x+1, y )
		--print("above:")
		self:updateGroundTile( x, y-1 )
		--print("below:")
		self:updateGroundTile( x, y+1 )
	end
end


function EditorMap:updateGroundTileNow( x, y, noMoreRecursion )
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
		print("transition:", foundTransition)
		self.groundArray[x][y].transition = foundTransition
		if self.groundArray[x-1] and self.groundArray[x-1][y] and
			self.groundArray[x-1][y].gType then
			self:updateGroundTile( x-1, y, true )
		end
		if self.groundArray[x+1] and self.groundArray[x+1][y] and
			self.groundArray[x+1][y].gType then
			self:updateGroundTile( x+1, y, true )
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
		self:updateGroundTile( x-1, y )
		--print("right:")
		self:updateGroundTile( x+1, y )
		--print("above:")
		self:updateGroundTile( x, y-1 )
		--print("below:")
		self:updateGroundTile( x, y+1 )
	end

end
--[[
function EditorMap:eraseGroundTileNow( x, y, updateSurrounding )

	self.tilesModifiedThisFrame = self.tilesModifiedThisFrame + 1
end]]
---------------------------------------------------
-- Background walls (non-collidable):
---------------------------------------------------

function EditorMap:updateBackgroundTile( x, y )
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

	--self:updateBackgroundTile( x-1, y )

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
		self:updateBackgroundTile( x-1, y )
		--print("right:")
		self:updateBackgroundTile( x+1, y )
		--print("above:")
		self:updateBackgroundTile( x, y-1 )
		--print("below:")
		self:updateBackgroundTile( x, y+1 )
		
		--diagonal:
		self:updateBackgroundTile( x-1, y-1 )
		self:updateBackgroundTile( x+1, y-1 )
		self:updateBackgroundTile( x+1, y+1 )
		self:updateBackgroundTile( x-1, y+1 )
	end
end


function EditorMap:updateBackgroundTileNow( x, y, forceNoTransition )
	--if updateSurrounding then print("---------------") end
	--
	self.tilesModifiedThisFrame = self.tilesModifiedThisFrame + 1

	local background = self.backgroundArray[x][y].gType

	-- load the surrounding ground types:
	local l,r,b,t,lt,rt,lb,rb = nil,nil,nil,nil
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

		elseif bg == background then
			self:eraseBackgroundTile( x, y, true )
			return
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
		self:updateBackgroundTile( x-1, y )
		--print("right:")
		self:updateBackgroundTile( x+1, y )
		--print("above:")
		self:updateBackgroundTile( x, y-1 )
		--print("below:")
		self:updateBackgroundTile( x, y+1 )
		--diagonal:
		self:updateBackgroundTile( x-1, y-1 )
		self:updateBackgroundTile( x-1, y+1 )
		self:updateBackgroundTile( x+1, y-1 )
		self:updateBackgroundTile( x+1, y+1 )
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
	local newBatch = love.graphics.newSpriteBatch( object.tileset, 100, "static" )
	local newIDs, bBox = object:addToBatch( newBatch, nil, 0,0 )
	local newObject = {
		ids = newIDs,
		x = bBox.x + tileX,
		y = bBox.y + tileY,
		maxX = bBox.maxX + tileX,
		maxY = bBox.maxY + tileY,
		drawX = (bBox.x + tileX)*self.tileSize,
		drawY = (bBox.y + tileY)*self.tileSize,
		tileWidth = object.tileWidth,
		tileHeight = object.tileHeight,
		width = object.width,
		height = object.height,
		selected = false,
		batch = newBatch,
		objType = object,
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
end

function EditorMap:removeBgObjectAt( tileX, tileY )
	-- Go through the list backwards and delete the first object found
	-- which is hit by the click:
	local obj
	for k = #self.bgList, 1, -1 do
		obj = self.bgList[k]
		if tileX >= obj.x and tileY >= obj.y and tileX <= obj.maxX-1 and tileY <= obj.maxY-1 then
			table.remove(self.bgList, k)
			break	-- only remove the one!
		end
	end
end

function EditorMap:removeSelectedBgObject()
	if self.selectedBgObject then
		for k, obj in pairs(self.bgList) do
			if obj == self.selectedBgObject then
				table.remove( self.bgList, k )
				break
			end
		end
		self.selectedBgObject.selected = false
		self.selectedBgObject = nil
	end
end

function EditorMap:selectBgObjectAt( tileX, tileY )

	-- unselect previously selected objects:
	self:selectNoBgObject()

	-- Go through the list backwards and select first object found
	local obj
	for k = #self.bgList, 1, -1 do
		obj = self.bgList[k]
		if tileX >= obj.x and tileY >= obj.y and tileX <= obj.maxX-1 and tileY <= obj.maxY-1 then
			self.selectedBgObject = obj
			obj.selected = true
			obj.oX = tileX - obj.x
			obj.oY = tileY - obj.y
			return obj
		end
	end
end

function EditorMap:selectNoBgObject()
	if self.selectedBgObject then
		self.selectedBgObject.selected = false
		self.selectedBgObject = nil
	end
end

function EditorMap:dragBgObject( tileX, tileY )
	if self.selectedBgObject then
		local obj = self.selectedBgObject
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
	local neighbourhood = self:neighbourhoodBgObjects( self.selectedBgObject )
	for i, obj in pairs( neighbourhood ) do
		-- find the selected object in its neighbourhood:
		if obj.obj == self.selectedBgObject then
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
	local neighbourhood = self:neighbourhoodBgObjects( self.selectedBgObject )
	for i, obj in pairs( neighbourhood ) do
		-- find the selected object in its neighbourhood:
		if obj.obj == self.selectedBgObject then
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

-----------------------------------------
-- Objects (front layer)
-----------------------------------------

function EditorMap:addObject( tileX, tileY, objName )
	--local newBatch = love.graphics.newSpriteBatch( object.tileset, 100, "static" )
	--local newIDs, bBox = object:addToBatch( newBatch, nil, 0,0 )
	local newObject = spriteFactory( objName )
	newObject:init()
	newObject.name = objName

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
	newObject.tileX = tileX
	newObject.tileY = tileY
	newObject.maxX = tileX + newObject.width/self.tileSize
	newObject.maxY = tileY + newObject.height/self.tileSize
	-- for drawing borders in editor:
	newObject.editorX = newObject.x*self.tileSize - newObject.width*0.5
	newObject.editorY = newObject.y*self.tileSize - newObject.height*0.5
	
	for i = 1, #newObject.vis do
		newObject.vis[i]:init()
	end

	if newObject.vis[1] then
		-- only allow one object at the same position!
		local toRemove = {}
		for k, obj in pairs( self.objectList ) do
			if obj.tileX == newObject.tileX and obj.tileY == newObject.tileY then
				table.insert( toRemove, k )
			end
		end
		for i, k in pairs( toRemove ) do
			table.remove( self.objectList, k )
		end

		if newObject.tileX < self.minX or newObject.tileX > self.maxX or
			newObject.tileY < self.minY or newObject.tileY > self.maxY then
			self.minX = math.min(self.minX, newObject.tileX)
			self.maxX = math.max(self.maxX, newObject.maxX)
			self.minY = math.min(self.minY, newObject.tileY)
			self.maxY = math.max(self.maxY, newObject.maxY)
			self:updateBorder()
		end
	end
	table.insert( self.objectList, newObject )

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
			table.remove(self.objectList, k)
			break	-- only remove the one!
		end
	end
end

function EditorMap:removeSelectedObject()
	if self.selectedObject then
		for k, obj in pairs(self.objectList) do
			if obj == self.selectedObject then
				table.remove( self.objectList, k )
				break
			end
		end
		self.selectedObject.selected = false
		self.selectedObject = nil
	end
end

function EditorMap:selectObjectAt( tileX, tileY )

	-- unselect previously selected objects:
	self:selectNoObject()

	-- Go through the list backwards and select first object found
	local obj
	for k = #self.objectList, 1, -1 do
		obj = self.objectList[k]
		if obj.vis[1] then
			if tileX >= obj.tileX and tileY >= obj.tileY and
				tileX <= obj.maxX-1 and tileY <= obj.maxY-1 then
				self.selectedObject = obj
				obj.selected = true
				obj.oX = tileX - obj.x
				obj.oY = tileY - obj.y

				return obj
			end
		end
	end
end

function EditorMap:selectNoObject()
	if self.selectedObject then
		self.selectedObject.selected = false
		self.selectedObject = nil
	end
end

function EditorMap:dragObject( tileX, tileY )
	if self.selectedObject then
		local obj = self.selectedObject

		obj.x = tileX - obj.oX
		obj.y = tileY - obj.oY
		-- for selecting:
		obj.tileX = tileX
		obj.tileY = tileY
		obj.maxX = tileX + obj.width/self.tileSize
		obj.maxY = tileY + obj.height/self.tileSize
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
	end
end

----------------------------------------
-- General:
----------------------------------------

function EditorMap:updateBorder()

	self.border = {}
	local padding = self.tileSize*0.25

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
	for ang = 0, math.pi/2, math.pi/8 do
		self.border[#self.border+1] = minX + padding - padding*math.cos(ang)		-- x
		self.border[#self.border+1] = minY + padding - padding*math.sin(ang)		-- y
	end
	for ang = math.pi/2, math.pi, math.pi/8 do
		self.border[#self.border+1] = maxX - padding - padding*math.cos(ang)		-- x
		self.border[#self.border+1] = minY + padding - padding*math.sin(ang)		-- y
	end
	for ang = math.pi, 3*math.pi/2, math.pi/8 do
		self.border[#self.border+1] = maxX - padding - padding*math.cos(ang)		-- x
		self.border[#self.border+1] = maxY - padding - padding*math.sin(ang)		-- y
	end
	for ang = 3*math.pi/2, 2*math.pi, math.pi/8 do
		self.border[#self.border+1] = minX + padding - padding*math.cos(ang)		-- x
		self.border[#self.border+1] = maxY - padding - padding*math.sin(ang)		-- y
	end

	self.borderMarkers[1].x = (self.minX-0.5)*self.tileSize
	self.borderMarkers[1].y = (self.minY-0.9)*self.tileSize

	self.borderMarkers[2].x = (self.minX-0.5)*self.tileSize
	self.borderMarkers[2].y = (self.maxY-1.1)*self.tileSize

	self.borderMarkers[3].x = (self.maxX-0.7)*self.tileSize
	self.borderMarkers[3].y = (self.minY-0.9)*self.tileSize

	self.borderMarkers[4].x = (self.maxX-0.7)*self.tileSize
	self.borderMarkers[4].y = (self.maxY-1.1)*self.tileSize
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
	end
end

function EditorMap:dropBorderMarker()
	if self.draggedBorderMarker == self.borderMarkers[1] then	-- top left
		self.minX = math.ceil(self.draggedBorderMarker.x/self.tileSize+0.5)
		self.minY = math.ceil(self.draggedBorderMarker.y/self.tileSize+0.5)
	elseif self.draggedBorderMarker == self.borderMarkers[2] then	-- bottom left
		self.minX = math.ceil(self.draggedBorderMarker.x/self.tileSize+0.5)
		self.maxY = math.ceil(self.draggedBorderMarker.y/self.tileSize+0.5)
	elseif self.draggedBorderMarker == self.borderMarkers[3] then	-- bottom left
		self.maxX = math.ceil(self.draggedBorderMarker.x/self.tileSize+0.5)
		self.minY = math.ceil(self.draggedBorderMarker.y/self.tileSize+0.5)
	elseif self.draggedBorderMarker == self.borderMarkers[4] then	-- bottom left
		self.maxX = math.ceil(self.draggedBorderMarker.x/self.tileSize+0.5)
		self.maxY = math.ceil(self.draggedBorderMarker.y/self.tileSize+0.5)
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
	for k, obj in ipairs( self.bgList ) do
		love.graphics.draw( obj.batch, obj.drawX, obj.drawY )
		if obj.selected == true then
			love.graphics.rectangle( "line", obj.drawX, obj.drawY, obj.width, obj.height )
		end
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
	for k, obj in ipairs( self.objectList ) do
		--love.graphics.draw( obj.batch, obj.drawX, obj.drawY )
		obj:draw()

		if obj.selected == true then
			love.graphics.rectangle( "line", obj.editorX,
									obj.editorY, math.max(30,obj.width), math.max(30,obj.height) )
		end
	end
end

function EditorMap:drawGround()
	love.graphics.draw( self.groundBatch, 0, 0 )	
end

function EditorMap:drawForeground()
	love.graphics.draw( self.spikeBatch, 0, 0 )
end

function EditorMap:drawBoundings()
	love.graphics.polygon( "line", self.border )
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
				self:updateGroundTileNow( data.x, data.y, data.noMoreRecursion )
			end
		elseif data.command == "updateBg" then
			if self.backgroundArray[data.x] and self.backgroundArray[data.x][data.y] and
				self.backgroundArray[data.x][data.y].gType then
				self:updateBackgroundTileNow( data.x, data.y )
			end
		end
		table.remove( self.tilesToModify, 1 )
	end
end

-- pass a full name including the path!
function EditorMap:loadFromFile( fullName )
	local map = nil
	local str = love.filesystem.read( fullName )
	if str then

		local dimX,dimY = str:match("Dimensions: (.-),(.-)\n")
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
		for k,b in pairs(editor.bgObjectList) do
			bgObjList[b.name] = b
		end local objList = {}
		for k,b in pairs(editor.objectList) do
			objList[b.name] = b
		end

		map = EditorMap:new( editor.backgroundList )
		map.minX, map.maxX = minX+1, maxX
		map.minY, map.maxY = minY+1, maxY
		map.width = map.maxX - map.minX
		map.height = map.maxY - map.minY

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
		y = 0
		for line in ground:gmatch("(.-)\n") do
			for x = 1, #line do
				map.collisionSrc[x] = map.collisionSrc[x] or {}
				matchName = line:sub(x, x)
				if groundsList[matchName] then
					if matchName == "b" then	-- bridge
						map.collisionSrc[x][y] = 2
					elseif matchName == "1" or matchName == "2" then	-- spikes
						map.collisionSrc[x][y] = 3
						map:addObject( x, y, "spikey" ) -- +1 because collision map starts at 0
					else
						map.collisionSrc[x][y] = 1		-- normal wall
					end
					map:setGroundTile( x + minX, y + minY, groundsList[matchName], true )
				else
					map.collisionSrc[x][y] = nil
				end
			end
			y = y + 1
		end

		print("------------------------")
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
		end

		local objType,x,y
		for obj in bgObjects:gmatch( "(Obj:.-endObj)\n" ) do
			objType = obj:match( "Obj:(.-)\n")
			x = obj:match( "x:(.-)\n")
			y = obj:match( "y:(.-)\n")

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
				map:addObject( x + minX + 1, y + minY + 1, objType )
			end

			if objType == "player" then
				map.xStart = x + 1
				map.yStart = y + 1
			end
		end

		-- Postprocess
		--map.factoryList = map:FactoryList(o.tileOBJ,o.height,o.width) -- see at the end of this file
		--map.lineList = map:LineList(o.tileOBJ,o.height,o.width)
		map.lineList = {}


		-- Update all map tiles to make sure the rught
		-- tile type is used. Force to update all the 
		-- tiles that need updating
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
		str = str .. "Obj:" .. obj.objType.name .. "\n"
		str = str .. "x:" .. obj.x - self.minX .. "\n"
		str = str .. "y:" .. obj.y - self.minY .. "\n"
		str = str .. "endObj\n"
		-- TODO: add possible properties here...
	end
	return str
end

function EditorMap:objectsToString()
	local str = ""
	-- Add the objects in order of appearance:
	for k, obj in ipairs(self.objectList) do
		if obj.name ~= "spikey" then
			str = str .. "Obj:" .. obj.name .. "\n"
			str = str .. "x:" .. obj.tileX - self.minX .. "\n"
			str = str .. "y:" .. obj.tileY - self.minY .. "\n"
			str = str .. "endObj\n"
			-- TODO: add possible properties here...
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
	timer = 0
	Camera:jumpTo(p.x,p.y)

	for i, obj in ipairs(self.objectList) do
		if obj.name == "player" then
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
		obj:update(0)
		spriteEngine:insert(obj)
	end
	for i = 1,#self.lineList do
		local newObject = Line:New({
			x = self.lineList[i].x,
			y = self.lineList[i].y,
			x2 = self.lineList[i].x2,
			y2 = self.lineList[i].y2,
		})
		spriteEngine:insert(newObject)
	end

	if USE_SHADOWS then
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

	if tag == 'player' then -- player does not collide with spikes
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

function lineOfSight(x1,y1,x2,y2)
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
			if myMap.collision[fx1] and ok(myMap.collision[fx1][yy]) then
				local yReturn = yy + 0.5 - 0.5*sy
				local xReturn = x1 + (yReturn-y1)/(y2-y1)*(x2-x1)
				return false,xReturn,yReturn
			end
		end
		return true
	end

	if fy1 == fy2 then
		for xx = fx1,fx2,sx do
			if myMap.collision[xx] and myMap.collision[xx][fy1] then
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
			if myMap.collision[xx] and ok(myMap.collision[xx][fy1]) then
				local xReturn = xx + 0.5 - 0.5*sx
				local yReturn = y1 + (xReturn-x1)/m
				return false,xReturn,yReturn
			end
		end
		for yy = fy1+sy,fy2-sy,sy do
			local xx1 = math.floor(m*(yy+math.max(0,-sy))-m*y1+x1)
			local xx2 = math.floor(m*(yy+math.max(0, sy))-m*y1+x1)
			for xx = xx1,xx2,sx do
				if myMap.collision[xx] and ok(myMap.collision[xx][yy]) then
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
			if myMap.collision[xx] and ok(myMap.collision[xx][fy2]) then
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
				if ok(myMap.collision[fx1][yy]) then
					local yReturn = yy + 0.5 - 0.5*sy
					local xReturn = x1 + (yReturn-y1)/m
					return false,xReturn,yReturn
				end
			end
		end
		for xx = fx1+sx,fx2-sx,sx do
			if myMap.collision[xx] then
				local yy1 = math.floor(m*(xx+math.max(0,-sx))-m*x1+y1)
				local yy2 = math.floor(m*(xx+math.max(0, sx))-m*x1+y1)
				for yy = yy1,yy2,sy do
					if ok(myMap.collision[xx][yy]) then
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
		if myMap.collision[fx2] then
			for yy = yy1,fy2,sy do
				if ok(myMap.collision[fx2][yy]) then
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

	return lineOfSight(x,y,xTarget,yTarget)

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
