----------------------------------------------
-- Represents all the ground types for the editor:
----------------------------------------------
-- TODO: allow for variations in ground types.

local Ground = {}
Ground.__index = Ground

-- Each ground object will hold one type of ground
-- (Wood, Stone, Concrete, Grass etc)
function Ground:new( name )
	local o = {}
	setmetatable( o, Ground )

	o.name = name

	-- The 'tiles' table will hold all the ground's tile positions on the tile map.
	-- "Thick" stores the block of 9 tiles, "thin" is 
	-- for the single, thinner lines (the remaining 7 tiles).
	o.tiles = {}

	-- If the ground has transition tiles then
	-- store them in the following:
	o.transitions = {}

	-- This table stores all variating tiles, indexed by the same "direction" as in
	-- the tiles table above.
	o.variations = {}

	o.similar = {}
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

function Ground:addTransition( dir, toType, coords )
	if not self.transitions[dir] then
		self.transitions[dir] = {}
	end
	self.transitions[dir][toType] = self:coordsToQuad( coords )
end

function Ground:addVariation( dir, coords )
	self.variations[dir] = self:coordsToQuad( coords )
end

function Ground:addSimilar( name )
	self.similar[name] = true
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
function Ground:getQuad( l, r, t, b, forceNoTransition )
	
	-- if forceNoTransition is set, then for every surrounding tile
	-- type which I have a transition to, make me believe that this
	-- ground tile's type is my own (i.e. don't add transition to that)
	print( l and l.name or "nil", r and r.name or "nil", t and t.name or "nil", b and b.name or "nil")
	if forceNoTransition then
		if l then
			if self.transitions.l and self.transitions.l[l.name] or
				self.transitions.lt and self.transitions.lt[l.name] or
				self.transitions.lb and self.transitions.lb[l.name] then
				l = self
			end
		end
		if r then
			if self.transitions.r and self.transitions.r[r.name] or
				self.transitions.rt and self.transitions.rt[r.name] or
				self.transitions.rb and self.transitions.rb[r.name] then
				r = self
			end
		end
	-- If I don't have a transition tile into a direction, but the neighbour
	-- in that direction is similar, make me think it has the same type as me:
		if l and self.similar[l.name] then--and t and (self.similar[t.name] or t == self) then
				l = self
		end
		if r and self.similar[r.name] then--and t and (self.similar[t.name] or t == self) then
				r = self
		end
	else
		if l and self.similar[l.name] and t and (self.similar[t.name] or t == self) then
				l = self
		end
		if r and self.similar[r.name] and t and (self.similar[t.name] or t == self) then
				r = self
		end
	end
		if t and self.similar[t.name] then
			t = self
		end
		if b and self.similar[b.name] then
			b = self
		end
	print( "\t",l and l.name or "nil", r and r.name or "nil", t and t.name or "nil", b and b.name or "nil")

	local dir = "single"
	-- all four are of the same kind as this ground:
	if l == self and r == self and t == self and b == self then
		dir = "cm"
	-- three are of the same kind:
	elseif l == self and t == self and r == self then
		dir = "cb"
	elseif t == self and r == self and b == self then
		dir = "lm"
	elseif r == self and b == self and l == self then
		dir = "ct"
	elseif b == self and l == self and t == self then
		dir = "rm"
	-- two are the same (opposite of each other):
	elseif l == self and r == self then
		dir = "c"
	elseif t == self and b == self then
		dir = "m"
	-- two are the same (around the corner):
	elseif l == self and t == self then
		dir = "rb"
	elseif t == self and r == self then
		dir = "lb"
	elseif r == self and b == self then
		dir = "lt"
	elseif b == self and l == self then
		dir = "rt"
	-- one is the same:
	elseif l == self then
		dir = "r"
	elseif r == self then
		dir = "l"
	elseif t == self then
		dir = "b"
	elseif b == self then
		dir = "t"
	end
	print("\t",dir)

	local quad = self.tiles[dir]

	local tNeighbour

	if dir:sub(1,1) == "l" then tNeighbour = l and l.name end
	if dir:sub(1,1) == "r" then tNeighbour = r and r.name end

	if tNeighbour and self.transitions[dir] and self.transitions[dir][tNeighbour] then
		quad = self.transitions[dir][tNeighbour]
	end
	if self.variations[dir] then
		-- with a chance of 1/20th, place the variation instead of normal tile.
		if math.random(20) == 1 then
			-- if it's the center tile, make the variation less likely:
			if dir ~= "cm" or math.random(2) == 1 then
				quad = self.variations[dir]
			end
		end
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

	new:addVariation( "lm", {0,11})
	new:addVariation( "c", {1,11})
	new:addVariation( "rm", {2,11})
	new:addVariation( "m", {3,11})
	new:addVariation( "ct", {2,9})
	new:addVariation( "cb", {3,9})
	new:addVariation( "cm", {3,10})
	table.insert( list, new )
	
	new = Ground:new("dirt")
	new:setSingleTile( {7, 4} )
	new:setThickTiles( {4,5}, {5,5}, {6,5},
						{4,2}, {5,2}, {6,2},
						{4,3}, {5,3}, {6,3})
	new:setHorizontalLine( {4,4}, {5,4}, {6,4} )
	new:setVerticalLine( {7,5}, {7,2}, {7,3} )

	new:addSimilar("grass")
	new:addSimilar("stone")

	new:addTransition( "lt", "grass", {1,7} )
	new:addTransition( "l", "grass", {3,7} )
	new:addTransition( "rt", "grass", {1,8} )
	new:addTransition( "r", "grass", {3,8} )
	new:addTransition( "lt", "stone", {1,6} )
	new:addTransition( "l", "stone", {4,6} )
	new:addTransition( "rt", "stone", {0,8} )
	new:addTransition( "r", "stone", {2,8} )

	table.insert( list, new )	
	
	new = Ground:new("grass")
	new:setSingleTile( {3, 4} )
	new:setThickTiles( {0,5}, {1,5}, {2,5},
						{4,2}, {5,2}, {6,2},
						{4,3}, {5,3}, {6,3})
	new:setHorizontalLine( {0,4}, {1,4}, {2,4} )
	new:setVerticalLine( {3,5}, {7,2}, {7,3} )

	new:addSimilar("dirt")
	new:addSimilar("stone")

	new:addTransition( "lt", "dirt", {1,8} )
	new:addTransition( "l", "dirt", {3,8} )
	new:addTransition( "rt", "dirt", {1,7} )
	new:addTransition( "r", "dirt", {3,7} )
	new:addTransition( "lt", "stone", {0,6} )
	new:addTransition( "l", "stone", {2,6} )
	new:addTransition( "rt", "stone", {0,7} )
	new:addTransition( "r", "stone", {2,7} )
	table.insert( list, new )

	new = Ground:new("stone")
	new:setSingleTile( {7, 6} )
	new:setThickTiles( {4,7}, {5,7}, {6,7},
						{4,2}, {5,2}, {6,2},
						{4,3}, {5,3}, {6,3})
	new:setHorizontalLine( {4,6}, {5,6}, {6,6} )
	new:setVerticalLine( {7,7}, {7,2}, {7,3} )

	new:addSimilar("dirt")
	new:addSimilar("grass")

	new:addTransition( "lt", "dirt", {0,8} )
	new:addTransition( "l", "dirt", {2,8} )
	new:addTransition( "rt", "dirt", {1,6} )
	new:addTransition( "r", "dirt", {3,6} )
	new:addTransition( "lt", "grass", {0,7} )
	new:addTransition( "l", "grass", {2,7} )
	new:addTransition( "rt", "grass", {0,6} )
	new:addTransition( "r", "grass", {2,6} )
	table.insert( list, new )
	
	new = Ground:new("wood")
	new:setSingleTile( {7, 8} )
	new:setThickTiles( {4,9}, {5,9}, {6,9},
						{4,10}, {5,10}, {6,10},
						{4,11}, {5,11}, {6,11})
	new:setHorizontalLine( {4,8}, {5,8}, {6,8} )
	new:setVerticalLine( {7,9}, {7,10}, {7,11} )
	table.insert( list, new )

	new = Ground:new("bridge")
	new:setSingleTile( {1,10} )
	new:setThickTiles( {0,9}, {1,10}, {1,9},
						{0,9}, {1,10}, {1,9},
						{0,9}, {1,10}, {1,9})
	new:setHorizontalLine( {0,9}, {1,10}, {1,9} )
	new:setVerticalLine( {1,10}, {1,10}, {1,10} )

	new:addTransition( "l", "concrete", {0, 10} )
	new:addTransition( "l", "dirt", {0, 10} )
	new:addTransition( "l", "grass", {0, 10} )
	new:addTransition( "l", "stone", {0, 10} )
	new:addTransition( "l", "wood", {0, 10} )
	new:addTransition( "lt", "concrete", {0, 10} )
	new:addTransition( "lt", "dirt", {0, 10} )
	new:addTransition( "lt", "grass", {0, 10} )
	new:addTransition( "lt", "stone", {0, 10} )
	new:addTransition( "lt", "wood", {0, 10} )
	new:addTransition( "lb", "concrete", {0, 10} )
	new:addTransition( "lb", "dirt", {0, 10} )
	new:addTransition( "lb", "grass", {0, 10} )
	new:addTransition( "lb", "stone", {0, 10} )
	new:addTransition( "lb", "wood", {0, 10} )
	new:addTransition( "r", "concrete", {2, 10} )
	new:addTransition( "r", "dirt", {2, 10} )
	new:addTransition( "r", "grass", {2, 10} )
	new:addTransition( "r", "stone", {2, 10} )
	new:addTransition( "r", "wood", {2, 10} )
	new:addTransition( "rt", "concrete", {2, 10} )
	new:addTransition( "rt", "dirt", {2, 10} )
	new:addTransition( "rt", "grass", {2, 10} )
	new:addTransition( "rt", "stone", {2, 10} )
	new:addTransition( "rt", "wood", {2, 10} )
	new:addTransition( "rb", "concrete", {2, 10} )
	new:addTransition( "rb", "dirt", {2, 10} )
	new:addTransition( "rb", "grass", {2, 10} )
	new:addTransition( "rb", "stone", {2, 10} )
	new:addTransition( "rb", "wood", {2, 10} )
	table.insert( list, new )

	return list
end

return Ground
