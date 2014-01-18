----------------------------------------------
-- Represents all the ground types for the editor:
----------------------------------------------

local Ground = {}
Ground.__index = Ground

-- Each ground object will hold one type of ground
-- (Wood, Stone, Concrete, Grass etc)
function Ground:new( name )
	local o = {}
	setmetatable( o, Ground )

	o.gType = name

	-- The 'tiles' table will hold all the ground's tile positions on the tile map.
	-- "Thick" stores the block of 9 tiles, "thin" is 
	-- for the single, thinner lines (the remaining 7 tiles).
	o.tiles = {}

	-- If the ground has transition tiles then
	-- store them in the following:
	o.transitions = {}
	o.transitions.left = {}
	o.transitions.right = {}
	--o.transitions.up = {}
	--o.transitions.down = {}
	return o
end

----------------------------------------------
-- Set the ground tiles for the ground. Each argument gives the coordinates
-- of the corresponding image in the grounds tile sheet
----------------------------------------------
-- l: left, c: center, r: right, t: top, m: middle, b: bottom
-- Example:
-- lt: left top, ct: center top, rt: right top
-- and so on
function Ground:setThickTiles( lt, ct, rt, lm, cm, rm, lb, cb, rb )
	self.tiles.lt = self:coordsToQuad( lt )
	self.tiles.ct = self:coordsToQuad( ct )
	self.tiles.rt = self:coordsToQuad( rt )
	self.tiles.lm = self:coordsToQuad( lm )
	self.tiles.cm = self:coordsToQuad( cm )
	self.tiles.rm = self:coordsToQuad( rm )
	self.tiles.lb = self:coordsToQuad( lb )
	self.tiles.cb = self:coordsToQuad( cb )
	self.tiles.rb = self:coordsToQuad( rb )
end

-- l: left, c: center, r: right
function Ground:setHorizontalLine( l, c, r )
	self.tiles.l = self:coordsToQuad( l )
	self.tiles.c = self:coordsToQuad( c )
	self.tiles.r = self:coordsToQuad( r )
end

-- r: top, m: middle, b: bottom
function Ground:setVerticalLine( t, m, b )
	self.tiles.t = self:coordsToQuad( t )
	self.tiles.m = self:coordsToQuad( m )
	self.tiles.b = self:coordsToQuad( b )
end

function Ground:setSingleTile( cm )
	self.tiles.single = self:coordsToQuad( cm )
end

function Ground:setTransition( toType, dir, coords )
	self.transitions[dir][toType] = self:coordsToQuad( coords )
end

function Ground:coordsToQuad( coords )
	return love.graphics.newQuad(
		coords[1]*Camera.scale*10, coords[2]*Camera.scale*10,
		Camera.scale*10, Camera.scale*10,
		editor.images.tilesetGround:getWidth(),
		editor.images.tilesetGround:getHeight())
end

-- this returns the correct quad depending on the types of ground
-- above, below, to the right and left of the current tile.
function Ground:getQuad( l, r, t, b )
	local quad = nil
	-- all four are of the same kind as this ground:
	if l == self and r == self and t == self and b == self then
		quad = self.tiles.cm
	-- three are of the same kind:
	elseif l == self and t == self and r == self then
		quad = self.tiles.cb
	elseif t == self and r == self and b == self then
		quad = self.tiles.lm
	elseif r == self and b == self and l == self then
		quad = self.tiles.ct
	elseif b == self and l == self and t == self then
		quad = self.tiles.rm
	-- two are the same (opposite of each other):
	elseif l == self and r == self then
		quad = self.tiles.c
	elseif t == self and b == self then
		quad = self.tiles.m
	-- two are the same (around the corner):
	elseif l == self and t == self then
		quad = self.tiles.rb
	elseif t == self and r == self then
		quad = self.tiles.lb
	elseif r == self and b == self then
		quad = self.tiles.lt
	elseif b == self and l == self then
		quad = self.tiles.rt
	-- one is the same:
	elseif l == self then
		quad = self.tiles.r
	elseif r == self then
		quad = self.tiles.l
	elseif t == self then
		quad = self.tiles.b
	elseif b == self then
		quad = self.tiles.t
	end

	-- Otherwise - none are the same. Return the single tile:
	return quad or self.tiles.single
end

function Ground:init()
	local list = {}
	local new = Ground:new("concrete")
	new:setSingleTile( {3, 0} )
	new:setThickTiles( {0,1}, {1,1}, {2,1},
						{0,2}, {1,2}, {2,2},
						{0,3}, {1,3}, {2,3})
	new:setHorizontalLine( {0,0}, {1,0}, {2,0} )
	new:setVerticalLine( {3,1}, {3,2}, {3,3} )

	table.insert( list, new )

	return list
end

return Ground
