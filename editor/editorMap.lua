local EditorMap = {}
EditorMap.__index = EditorMap


function EditorMap:new()
	local o = {}
	setmetatable( o, EditorMap )
	o.MAP_SIZE = 1000

	o.groundBatch = love.graphics.newSpriteBatch( editor.images.tilesetGround,
					o.MAP_SIZE*o.MAP_SIZE, "dynamic" )
	o.spikeBatch = love.graphics.newSpriteBatch( editor.images.tilesetGround,
					o.MAP_SIZE*o.MAP_SIZE, "dynamic" )
	o.backgroundBatch = love.graphics.newSpriteBatch( editor.images.tilesetBackground,
					100000, "dynamic" )

	o.groundArray = {}
	
	o.tileSize = Camera.scale*8

	o.minX = -15
	o.maxX = 15
	o.minY = -8
	o.maxY = 8

	o.border = {}	-- the border which to draw around the map...

	EditorMap.updateBorder(o)

	o.bgList = {}	-- list of background objects
	o.bgEmptyIDs = {}
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

function EditorMap:setGroundTile( x, y, ground, updateSurrounding )
	--if updateSurrounding then print("---------------") end
	
	if not self.groundArray[x] then
		self.groundArray[x] = {}
	end
	if not self.groundArray[x][y] then
		self.groundArray[x][y] = { batchID = {} }
	end

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

	-- load the surrounding ground types:
	local l,r,b,t = nil,nil,nil,nil
	if self.groundArray[x-1] and self.groundArray[x-1][y] then
		l = self.groundArray[x-1][y].gType
	end
	if self.groundArray[x+1] and self.groundArray[x+1][y] then
		r = self.groundArray[x+1][y].gType
	end
	if self.groundArray[x][y-1] then
		t = self.groundArray[x][y-1].gType
	end
	if self.groundArray[x][y+1] then
		b = self.groundArray[x][y+1].gType
	end

	-- get the quad for the current tile  which depends on the surrounding ground types:
	local forceNoTransition = updateSurrounding and ground.name ~= "bridge"
	local quad = ground:getQuad( l, r, t, b, nil,nil,nil,nil, forceNoTransition )
	
	-- if there's already a tile there, update it:
	if newGroundType == "spikes" then
		if self.groundArray[x][y].batchID["spikes"] then
			self.spikeBatch:set( self.groundArray[x][y].batchID["spikes"],
				quad, x*Camera.scale*8 - Camera.scale, y*Camera.scale*8 - Camera.scale )
		else
			self.groundArray[x][y].batchID["spikes"] = self.spikeBatch:add(
				quad, x*Camera.scale*8 - Camera.scale, y*Camera.scale*8 - Camera.scale )
		end
	else
		if self.groundArray[x][y].batchID["noSpikes"] then
			self.groundBatch:set( self.groundArray[x][y].batchID["noSpikes"],
				quad, x*Camera.scale*8 - Camera.scale, y*Camera.scale*8 - Camera.scale )
		else
			self.groundArray[x][y].batchID["noSpikes"] = self.groundBatch:add(
				quad, x*Camera.scale*8 - Camera.scale, y*Camera.scale*8 - Camera.scale )
		end
	end

	-- set the new ground type:
	self.groundArray[x][y].gType = ground

	if updateSurrounding then
		--print("left:")
		if self.groundArray[x-1] and self.groundArray[x-1][y] and self.groundArray[x-1][y].gType then
			self:setGroundTile( x-1, y, self.groundArray[x-1][y].gType )
		end
		--print("right:")
		if self.groundArray[x+1] and self.groundArray[x+1][y] and self.groundArray[x+1][y].gType then
			self:setGroundTile( x+1, y, self.groundArray[x+1][y].gType )
		end
		--print("above:")
		if self.groundArray[x][y-1] and self.groundArray[x][y-1].gType then
			self:setGroundTile( x, y-1, self.groundArray[x][y-1].gType )
		end
		--print("below:")
		if self.groundArray[x][y+1] and self.groundArray[x][y+1].gType then
			self:setGroundTile( x, y+1, self.groundArray[x][y+1].gType )
		end
	end


	-- update border:
	if x < self.minX or x > self.maxX or y < self.minY or y > self.maxY then
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

		if updateSurrounding then
			if self.groundArray[x-1] and self.groundArray[x-1][y] and self.groundArray[x-1][y].gType then
				self:setGroundTile( x-1, y, self.groundArray[x-1][y].gType )
			end
			if self.groundArray[x+1] and self.groundArray[x+1][y] and self.groundArray[x+1][y].gType then
				self:setGroundTile( x+1, y, self.groundArray[x+1][y].gType )
			end
			if self.groundArray[x][y-1] and self.groundArray[x][y-1].gType then
				self:setGroundTile( x, y-1, self.groundArray[x][y-1].gType )
			end
			if self.groundArray[x][y+1] and self.groundArray[x][y+1].gType then
				self:setGroundTile( x, y+1, self.groundArray[x][y+1].gType )
			end
		end

	end

end

local function sign( i )
	if i < 0 then
		return -1
	elseif i > 0 then
		return 1
	else
		return 0
	end
end

function EditorMap:line( tileX, tileY, startX, startY, event )
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
	end
end

function EditorMap:addBackgroundTile()

end

function EditorMap:addBackgroundObject( tileX, tileY, object )
	local newIDs, bBox = object:addToBatch( self.backgroundBatch, self.bgEmptyIDs, tileX, tileY )
	local newObject = {
		ids = newIDs,
		x = bBox.x + tileX,
		y = bBox.y + tileY,
		maxX = bBox.maxX + tileX,
		maxY = bBox.maxY + tileY
	}
	table.insert( self.bgList, newObject )
end

function EditorMap:removeBackgroundObject( tileX, tileY )
	-- Go through the list backwards and delete the first object found
	-- which is hit by the click:
	local obj
	for k = #self.bgList, 1, -1 do
		obj = self.bgList[k]
		if tileX >= obj.x and tileY >= obj.y and tileX <= obj.maxX-1 and tileY <= obj.maxY-1 then
			for i, ID in pairs(obj.ids) do
				self.backgroundBatch:set( ID, 0,0,0,0,0 )
				table.insert( self.bgEmptyIDs, ID )
			end
			table.remove(self.bgList, k)
			break	-- only remove the one!
		end
	end
end

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
	love.graphics.draw( self.backgroundBatch, 0, 0 )
end

function EditorMap:drawGround()
	love.graphics.draw( self.groundBatch, 0, 0 )
	love.graphics.draw( self.spikeBatch, 0, 0 )
end

function EditorMap:drawBoundings()
	love.graphics.polygon( "line", self.border )
end

return EditorMap
