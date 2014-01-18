local EditorMap = {}
EditorMap.__index = EditorMap


function EditorMap:new()
	local o = {}
	setmetatable( o, EditorMap )

	o.groundBatch = love.graphics.newSpriteBatch( editor.images.tilesetGround,
					10000, "dynamic" )
	o.backgroundBatch = love.graphics.newSpriteBatch( editor.images.tilesetBackground,
					1000, "dynamic" )

	o.groundArray = {}
	for x = 0, 1000 do
		o.groundArray[x] = {}
		for y = 0, 1000 do
			o.groundArray[x][y] = {}
			-- store type to remember what's in the tile:
			o.groundArray[x][y].type = ""
			-- store id returned by the spritebatch to be able to modify image:
			o.groundArray[x][y].batchID = nil
		end
	end

	return o
end

function EditorMap:setGroundTile( x, y, ground )

	-- set the new ground type:
	self.groundArray[x][y].type = ground.groundType

	local quad = ground:getQuad()
	
	-- if there's already a tile there, update it:
	if self.groundArray[x][y].batchID then
		self.groundBatch:set( self.groundArray[x][y].batchID,
			quad, x*Camera.scale*8, y*Camera.scale*8 )
	else
		self.groundArray[x][y].batchID = self.groundBatch:add(
			quad, x*Camera.scale*8, y*Camera.scale*8 )
	end
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
