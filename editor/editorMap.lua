local EditorMap = {}
EditorMap.__index = EditorMap

MAP_SIZE = 1000

function EditorMap:new()
	local o = {}
	setmetatable( o, EditorMap )

	o.groundBatch = love.graphics.newSpriteBatch( editor.images.tilesetGround,
					MAP_SIZE*MAP_SIZE, "dynamic" )
	o.backgroundBatch = love.graphics.newSpriteBatch( editor.images.tilesetBackground,
					1000, "dynamic" )

	o.groundArray = {}
	for x = 0, MAP_SIZE-1 do
		o.groundArray[x] = {}
		for y = 0, MAP_SIZE-1 do
			o.groundArray[x][y] = {}
			-- store type to remember what's in the tile:
			o.groundArray[x][y].gType = nil
			-- store id returned by the spritebatch to be able to modify image:
			o.groundArray[x][y].batchID = nil
		end
	end

	return o
end

function EditorMap:setGroundTile( x, y, ground, updateSurrounding )
	
	if not self.groundArray[x] or not self.groundArray[x][y] then return end
	-- set the new ground type:
	self.groundArray[x][y].gType = ground

	-- load the surrounding ground types:
	local l = x > 0 and self.groundArray[x-1][y].gType
	local r = x < MAP_SIZE-1 and self.groundArray[x+1][y].gType
	local t = y > 0 and self.groundArray[x][y-1].gType
	local b = y < MAP_SIZE-1 and self.groundArray[x][y+1].gType


	-- get the quad for the current tile  which depends on the surrounding ground types:
	local quad = ground:getQuad( l, r, t, b )
	
	-- if there's already a tile there, update it:
	if self.groundArray[x][y].batchID then
		self.groundBatch:set( self.groundArray[x][y].batchID,
			quad, x*Camera.scale*8, y*Camera.scale*8 )
	else
		self.groundArray[x][y].batchID = self.groundBatch:add(
			quad, x*Camera.scale*8, y*Camera.scale*8 )
	end

	if updateSurrounding then
		if x > 0 and self.groundArray[x-1][y].gType then
			self:setGroundTile( x-1, y, self.groundArray[x-1][y].gType )
		end
		if x < MAP_SIZE-1 and self.groundArray[x+1][y].gType then
			self:setGroundTile( x+1, y, self.groundArray[x+1][y].gType )
		end
		if y > 0 and self.groundArray[x][y-1].gType then
			self:setGroundTile( x, y-1, self.groundArray[x][y-1].gType )
		end
		if y < MAP_SIZE-1 and self.groundArray[x][y+1].gType then
			self:setGroundTile( x, y+1, self.groundArray[x][y+1].gType )
		end
	end
end

function EditorMap:eraseGroundTile( x, y, updateSurrounding )

	if not self.groundArray[x] or not self.groundArray[x][y] then return end

	if self.groundArray[x][y].batchID then
		-- sadly, there's no way to remove from a sprite batch,
		-- so instead, move to 0:
		self.groundBatch:set( self.groundArray[x][y].batchID,
			0,0,0,0,0)
		self.groundArray[x][y].gType = nil


	if updateSurrounding then
		if x > 0 and self.groundArray[x-1][y].gType then
			self:setGroundTile( x-1, y, self.groundArray[x-1][y].gType )
		end
		if x < MAP_SIZE-1 and self.groundArray[x+1][y].gType then
			self:setGroundTile( x+1, y, self.groundArray[x+1][y].gType )
		end
		if y > 0 and self.groundArray[x][y-1].gType then
			self:setGroundTile( x, y-1, self.groundArray[x][y-1].gType )
		end
		if y < MAP_SIZE-1 and self.groundArray[x][y+1].gType then
			self:setGroundTile( x, y+1, self.groundArray[x][y+1].gType )
		end
	end

		return true
	end
	return false
end

function EditorMap:addBackgroundTile()

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
