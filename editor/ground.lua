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
	o.tiles.thick = {}
	o.tiles.thin = {}

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
	self.tiles.thick.lt = self:coordsToQuad( lt )
	self.tiles.thick.ct = self:coordsToQuad( ct )
	self.tiles.thick.rt = self:coordsToQuad( rt )
	self.tiles.thick.lm = self:coordsToQuad( lm )
	self.tiles.thick.cm = self:coordsToQuad( cm )
	self.tiles.thick.rm = self:coordsToQuad( rm )
	self.tiles.thick.lb = self:coordsToQuad( lb )
	self.tiles.thick.cb = self:coordsToQuad( cb )
	self.tiles.thick.rb = self:coordsToQuad( rb )
end

-- l: left, c: center, r: right
function Ground:setHorizontalLine( l, c, r )
	self.tiles.thin.l = self:coordsToQuad( l )
	self.tiles.thin.c = self:coordsToQuad( c )
	self.tiles.thin.r = self:coordsToQuad( r )
end

-- r: top, m: middle, b: bottom
function Ground:setVerticalLine( t, m, b )
	self.tiles.thin.t = self:coordsToQuad( l )
	self.tiles.thin.m = self:coordsToQuad( m )
	self.tiles.thin.b = self:coordsToQuad( b )
end

function Ground:setSingleTile( cm )
	self.tiles.thin.single = self:coordsToQuad( cm )
end

function Ground:setTransition( toType, dir, coords )
	self.transitions[dir][toType] = self:coordsToQuad( coords )
end

function Ground:coordsToQuad( coords )
	return love.graphics.newQuad(
		coords[1]*Camera.scale*8, coords[2]*Camera.scale*8,
		Camera.scale*8, Camera.scale*8,
		editor.images.tilesetGround:getWidth(),
		editor.images.tilesetGround:getHeight())
end

-- this returns the correct quad depending on the types of ground
-- above, below, to the right and left of the current tile.
function Ground:getQuad( l, r, t, b )

	-- all four are of the same kind as this ground:
	if l == self.gType and r == self.gType and t == self.gType and b == self.gType then
		return self.tiles.thick.cm
	-- three are of the same kind:
	elseif l == self.gType and t == self.gType and r == self.gType then
		return self.tiles.thick.cb
	elseif t == self.gType and r == self.gType and b == self.gType then
		return self.tiles.thick.lm
	elseif r == self.gType and b == self.gType and l == self.gType then
		return self.tiles.thick.ct
	elseif b == self.gType and l == self.gType and t == self.gType then
		return self.tiles.thick.rm
	-- two are the same (opposite of each other):
	elseif l == self.gType and r == self.gType then
		return self.tiles.thin.c
	elseif t == self.gType and b == self.gType then
		return self.tiles.thin.m
	-- two are the same (around the corner):
	elseif l == self.gType and t == self.gType then
		return self.tiles.thin.rb
	elseif t == self.gType and r == self.gType then
		return self.tiles.thin.lb
	elseif r == self.gType and b == self.gType then
		return self.tiles.thin.lt
	elseif b == self.gType and l == self.gType then
		return self.tiles.thin.rt
	-- one is the same:
	elseif l == self.gType then
		return self.tiles.thin.r
	elseif r == self.gType then
		return self.tiles.thin.l
	elseif t == self.gType then
		return self.tiles.thin.b
	elseif b == self.gType then
		return self.tiles.thin.t
	end

	-- Otherwise - none are the same. Return the single tile:
	return self.tiles.thin.single
end

function Ground:init()
	local list = {}
	local new = Ground:new("concrete")
	new:setSingleTile( {3, 0} )

	table.insert( list, new )

	return list
end

return Ground
