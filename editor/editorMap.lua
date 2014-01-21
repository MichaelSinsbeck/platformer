local EditorMap = {}
EditorMap.__index = EditorMap


function EditorMap:new()
	local o = {}
	setmetatable( o, EditorMap )
	o.MAP_SIZE = 1000

	o.groundBatch = love.graphics.newSpriteBatch( editor.images.tilesetGround,
					o.MAP_SIZE*o.MAP_SIZE, "dynamic" )
	o.backgroundBatch = love.graphics.newSpriteBatch( editor.images.tilesetBackground,
					100000, "dynamic" )


	o.groundArray = {}

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
	
	if not self.groundArray[x] then
		self.groundArray[x] = {}
	end
	if not self.groundArray[x][y] then
		self.groundArray[x][y] = {}
	end
	-- set the new ground type:
	self.groundArray[x][y].gType = ground

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
	local quad = ground:getQuad( l, r, t, b, forceNoTransition )
	
	-- if there's already a tile there, update it:
	if self.groundArray[x][y].batchID then
		self.groundBatch:set( self.groundArray[x][y].batchID,
			quad, x*Camera.scale*8 - Camera.scale, y*Camera.scale*8 - Camera.scale )
	else
		self.groundArray[x][y].batchID = self.groundBatch:add(
			quad, x*Camera.scale*8 - Camera.scale, y*Camera.scale*8 - Camera.scale )
	end

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

function EditorMap:eraseGroundTile( x, y, updateSurrounding )

	if not self.groundArray[x] or not self.groundArray[x][y] then return end

	if self.groundArray[x][y].batchID then
		-- sadly, there's no way to remove from a sprite batch,
		-- so instead, move to 0:
		self.groundBatch:set( self.groundArray[x][y].batchID,0,0,0,0,0 )
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

		return true
	end
	return false
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

function EditorMap:drawGroundLine( tileX, tileY, startX, startY, ground )
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
	
	self:setGroundTile( x, y, ground, true )
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
		self:setGroundTile( x, y, ground, true )
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
		if tileX >= obj.x and tileY >= obj.y and tileX <= obj.maxX and tileY <= obj.maxY then
			for i, ID in pairs(obj.ids) do
				self.backgroundBatch:set( ID, 0,0,0,0,0 )
				table.insert( self.bgEmptyIDs, ID )
			end
			table.remove(self.bgList, k)
			break	-- only remove the one!
		end
	end
end

function EditorMap:drawGrid()
	local tileSize = Camera.scale*8
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
end

return EditorMap
