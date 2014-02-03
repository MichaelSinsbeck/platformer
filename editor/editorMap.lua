local EditorMap = {}
EditorMap.__index = EditorMap

local MAX_TILES_PER_FRAME = 500
local MAX_FLOOD_FILL_RECURSION = 1500

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

	o.minX = -15
	o.maxX = 15
	o.minY = -8
	o.maxY = 8

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
	newObject.x = tileX + newObject.width*0.5/self.tileSize
	newObject.y = tileY + newObject.height*0.5/self.tileSize
	newObject.name = objName
	for i = 1, #newObject.vis do
		newObject.vis[i]:init()
	end
	--[[local newObject = {
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
		--batch = newBatch,
		objType = object,
	}]]--

	-- only allow one object at the same position!
	local toRemove = {}
	for k, obj in pairs( self.objectList ) do
		if obj.x < newObject.x + newObject.width/self.tileSize and
			obj.y < newObject.y + newObject.height/self.tileSize and
			obj.x + obj.width/self.tileSize > newObject.x and
			obj.y + obj.height/self.tileSize > newObject.y then
			table.insert( toRemove, k )
		end
	end
	for i, k in pairs( toRemove ) do
		table.remove( self.objectList, k )
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
		if tileX >= obj.minX and tileY >= obj.minY and tileX <= obj.maxX-1 and tileY <= obj.maxY-1 then
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
		if tileX >= obj.x and tileY >= obj.y and tileX <= obj.maxX-1 and tileY <= obj.maxY-1 then
			self.selectedObject = obj
			obj.selected = true
			obj.oX = tileX - obj.x
			obj.oY = tileY - obj.y
			return obj
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

----------------------------------------
-- General:
----------------------------------------

function EditorMap:updateBorder()

	self.border = {}
	local padding = self.tileSize*0.25
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
			love.graphics.rectangle( "line", obj.drawX, obj.drawY, obj.width, obj.height )
		end
	end
end

function EditorMap:drawGround()
	love.graphics.draw( self.groundBatch, 0, 0 )	
	love.graphics.draw( self.spikeBatch, 0, 0 )
end

function EditorMap:drawBoundings()
	love.graphics.polygon( "line", self.border )
	for i = 1, 4 do
		love.graphics.draw( self.borderMarkers[i].img, self.borderMarkers[i].x,
			self.borderMarkers[i].y )
	end
end

function EditorMap:update( dt )
	self.tilesModifiedThisFrame = 0

	while #self.tilesToModify > 0 and self.tilesModifiedThisFrame < MAX_TILES_PER_FRAME do
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

-----------------------------------
-- Functions related to saving:
-----------------------------------

function EditorMap:dimensionsToString()
	return "Dimensions: " .. self.maxX - self.minX .. "," .. self.maxY - self.minY .. "\n"
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
		str = str .. "Obj:" .. obj.name .. "\n"
		str = str .. "x:" .. obj.x - self.minX - obj.width*0.5/self.tileSize .. "\n"
		str = str .. "y:" .. obj.y - self.minY - obj.height*0.5/self.tileSize .. "\n"
		str = str .. "endObj\n"
		-- TODO: add possible properties here...
	end
	return str
end

return EditorMap
