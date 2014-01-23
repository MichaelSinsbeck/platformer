----------------------------------------------
-- Represents all the ground types for the editor:
----------------------------------------------
-- TODO: allow for variations in ground types.

local Ground = {}
Ground.__index = Ground

local DC = " ;"	-- DON'T CARE

-- Each ground object will hold one type of ground
-- (Wood, Stone, Concrete, Grass etc)
function Ground:new( name, matchName )
	local o = {}
	setmetatable( o, Ground )

	o.name = name
	o.matchName = matchName

	-- The 'tiles' table will hold all the ground's tile positions on the tile map.
	-- "Thick" stores the block of 9 tiles, "thin" is 
	-- for the single, thinner lines (the remaining 7 tiles).
	o.tiles = {}

	-- If the ground has transition tiles then
	-- store them in the following:
	--o.transitions = {}

	-- This table stores all variating tiles, indexed by the same "direction" as in
	-- the tiles table above.
	o.variations = {}

	-- start of being similar only to yourself:
	o.similarList = o.matchName
	o.similar = "[" .. o.similarList .. "];"
	-- different is everything besides yourself:
	o.diff = "[^" .. o.similarList .. "];"
	o.matchStrings = {}
	
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

	local l = ""
	l = self.diff .. self.diff .. self.diff	-- line above
	l = l .. self.diff .. self.similar	-- left and right
	l = l .. self.diff .. self.similar .. self.diff		-- line below
	self.matchStrings.lt = l

	l = self.diff .. self.diff .. self.diff	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. self.diff .. self.similar .. self.diff		-- line below
	self.matchStrings.ct = l

	l = self.diff .. self.diff .. self.diff	-- line above
	l = l .. self.similar .. self.diff	-- left and right
	l = l .. self.diff .. self.similar .. self.diff		-- line below
	self.matchStrings.rt = l

	l = self.diff .. self.similar .. self.diff	-- line above
	l = l .. self.diff .. self.similar	-- left and right
	l = l .. self.diff .. self.similar .. self.diff		-- line below
	self.matchStrings.lm = l

	l = self.diff .. self.similar .. self.diff	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. self.diff .. self.similar .. self.diff		-- line below
	self.matchStrings.cm = l

	l = self.diff .. self.similar .. self.diff	-- line above
	l = l .. self.similar .. self.diff	-- left and right
	l = l .. self.diff .. self.similar .. self.diff		-- line below
	self.matchStrings.rm = l

	l = self.diff .. self.similar .. self.diff	-- line above
	l = l .. self.diff .. self.similar	-- left and right
	l = l .. self.diff .. self.diff .. self.diff		-- line below
	self.matchStrings.lb = l

	l = self.diff .. self.similar .. self.diff	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. self.diff .. self.diff .. self.diff		-- line below
	self.matchStrings.cb = l

	l = self.diff .. self.similar .. self.diff	-- line above
	l = l .. self.similar .. self.diff	-- left and right
	l = l .. self.diff .. self.diff .. self.diff		-- line below
	self.matchStrings.rb = l

end

-- l: left, c: center, r: right
function Ground:setHorizontalLine( l, c, r )
	self.tiles.l = self:coordsToQuad( l )
	self.tiles.c = self:coordsToQuad( c )
	self.tiles.r = self:coordsToQuad( r )

	local tmp = ""
	tmp = self.diff .. self.diff .. self.diff	-- line above
	tmp = tmp .. self.diff .. self.similar	-- left and right
	tmp = tmp .. self.diff .. self.diff .. self.diff		-- line below
	self.matchStrings.l = tmp
	
	tmp = self.diff .. self.diff .. self.diff	-- line above
	tmp = tmp .. self.similar .. self.similar	-- left and right
	tmp = tmp .. self.diff .. self.diff .. self.diff		-- line below
	self.matchStrings.c = tmp
	
	tmp = self.diff .. self.diff .. self.diff	-- line above
	tmp = tmp .. self.similar .. self.diff	-- left and right
	tmp = tmp .. self.diff .. self.diff .. self.diff		-- line below
	self.matchStrings.r = tmp
	
end

-- r: top, m: middle, b: bottom
function Ground:setVerticalLine( t, m, b )
	self.tiles.t = self:coordsToQuad( t )
	self.tiles.m = self:coordsToQuad( m )
	self.tiles.b = self:coordsToQuad( b )

	local tmp = ""
	tmp = self.diff .. self.diff .. self.diff	-- line above
	tmp = tmp .. self.diff .. self.diff	-- left and right
	tmp = tmp .. self.diff .. self.similar .. self.diff		-- line below
	self.matchStrings.t = tmp
	
	tmp = self.diff .. self.similar .. self.diff	-- line above
	tmp = tmp .. self.diff .. self.diff	-- left and right
	tmp = tmp .. self.diff .. self.similar .. self.diff		-- line below
	self.matchStrings.m = tmp
	
	tmp = self.diff .. self.similar .. self.diff	-- line above
	tmp = tmp .. self.diff .. self.diff	-- left and right
	tmp = tmp .. self.diff .. self.diff .. self.diff		-- line below
	self.matchStrings.b = tmp
	
end

function Ground:setSingleTile( cm )
	self.tiles.single = self:coordsToQuad( cm )

	local tmp = ""
	tmp = self.diff .. self.diff .. self.diff ..
		self.diff .. self.diff ..
		self.diff .. self.diff .. self.diff
	self.matchStrings.single = tmp
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

function Ground:addSimilar( match )

	-- add match to list:
	self.similarList = self.similarList .. match

	-- match these as "similar:"
	-- example: "gsd;"
	self.similar = "[" .. self.similarList .. "];"

	-- match as "different" every letter that's NOT similar:
	-- example: "[^gds];
	self.diff = "[^" .. self.similarList .. "];"
	print("new similar:", self.similar, self.diff, "(" .. self.name .. ")" )
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
	local lMatch = l and l.matchName .. ";" or " ;"
	local rMatch = r and r.matchName .. ";" or " ;"
	local tMatch = t and t.matchName .. ";" or " ;"
	local bMatch = b and b.matchName .. ";" or " ;"

	-- diagonal:
	local ltMatch = lt and lt.matchName .. ";" or " ;"
	local rtMatch = rt and rt.matchName .. ";" or " ;"
	local lbMatch = lb and lb.matchName .. ";" or " ;"
	local rbMatch = rb and rb.matchName .. ";" or " ;"

	local mStr = ltMatch .. tMatch .. rtMatch	-- top line
	mStr = mStr .. lMatch .. rMatch					-- center line
	mStr = mStr .. lbMatch .. bMatch .. rbMatch	-- bottom line
	for dir, str in pairs( self.matchStrings ) do
		if mStr:match(str) then
			foundDir = dir
		end
	end

	if foundDir then
		if self.variations[foundDir] then
			if math.random(20) == 1 then
				-- make center tile less likeley to have variation:
				if foundDir ~= "cm" or math.random(2) == 1 then
					return self.variations[foundDir]
				end
			end
		end
		return self.tiles[foundDir]
	else
		print("NONE FOUND!")
		return self.tiles.single
	end
end

function Ground:init()
	local list = {}
	local new = Ground:new("concrete", 'c' )
	new:addSimilar( '1' )	--I'm similar to the spikesConcrete
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
	
	new = Ground:new("dirt", 'd')
	new:addSimilar( 'g' )	-- similar to grass
	new:addSimilar( 's' )	-- similar to stone
	new:addSimilar( '2' ) 	-- similar to spikesSoil
	new:setSingleTile( {7, 4} )
	new:setThickTiles( {4,5}, {5,5}, {6,5},
						{4,2}, {5,2}, {6,2},
						{4,3}, {5,3}, {6,3})
	new:setHorizontalLine( {4,4}, {5,4}, {6,4} )
	new:setVerticalLine( {7,5}, {7,2}, {7,3} )


	--[[new:addTransition( "lt", "grass", {1,7} )
	new:addTransition( "l", "grass", {3,7} )
	new:addTransition( "rt", "grass", {1,8} )
	new:addTransition( "r", "grass", {3,8} )
	new:addTransition( "lt", "stone", {1,6} )
	new:addTransition( "l", "stone", {4,6} )
	new:addTransition( "rt", "stone", {0,8} )
	new:addTransition( "r", "stone", {2,8} )
	]]

	table.insert( list, new )	
	
	new = Ground:new("grass", 'g')
	new:addSimilar( 'd' )	-- similar to dirt
	new:addSimilar( 's' )	-- similar to stone
	new:addSimilar( '2' )	-- similar to spikesSoil
	new:setSingleTile( {3, 4} )
	new:setThickTiles( {0,5}, {1,5}, {2,5},
						{4,2}, {5,2}, {6,2},
						{4,3}, {5,3}, {6,3})
	new:setHorizontalLine( {0,4}, {1,4}, {2,4} )
	new:setVerticalLine( {3,5}, {7,2}, {7,3} )


	--[[new:addTransition( "lt", "dirt", {1,8} )
	new:addTransition( "l", "dirt", {3,8} )
	new:addTransition( "rt", "dirt", {1,7} )
	new:addTransition( "r", "dirt", {3,7} )
	new:addTransition( "lt", "stone", {0,6} )
	new:addTransition( "l", "stone", {2,6} )
	new:addTransition( "rt", "stone", {0,7} )
	new:addTransition( "r", "stone", {2,7} )]]
	table.insert( list, new )

	new = Ground:new("stone", 's' )
	new:addSimilar( 'd' )	-- similar to dirt
	new:addSimilar( 'g' )	-- similar to grass
	new:addSimilar( '2' )	-- similar to spikesSoil
	new:setSingleTile( {7, 6} )
	new:setThickTiles( {4,7}, {5,7}, {6,7},
						{4,2}, {5,2}, {6,2},
						{4,3}, {5,3}, {6,3})
	new:setHorizontalLine( {4,6}, {5,6}, {6,6} )
	new:setVerticalLine( {7,7}, {7,2}, {7,3} )


	--[[new:addTransition( "lt", "dirt", {0,8} )
	new:addTransition( "l", "dirt", {2,8} )
	new:addTransition( "rt", "dirt", {1,6} )
	new:addTransition( "r", "dirt", {3,6} )
	new:addTransition( "lt", "grass", {0,7} )
	new:addTransition( "l", "grass", {2,7} )
	new:addTransition( "rt", "grass", {0,6} )
	new:addTransition( "r", "grass", {2,6} )]]
	table.insert( list, new )
	
	new = Ground:new("wood", 'w')
	new:setSingleTile( {7, 8} )
	new:setThickTiles( {4,9}, {5,9}, {6,9},
						{4,10}, {5,10}, {6,10},
						{4,11}, {5,11}, {6,11})
	new:setHorizontalLine( {4,8}, {5,8}, {6,8} )
	new:setVerticalLine( {7,9}, {7,10}, {7,11} )
	table.insert( list, new )

	new = Ground:new("bridge", 'b' )
	new:setSingleTile( {1,10} )
	new:setThickTiles( {0,9}, {1,10}, {1,9},
						{0,9}, {1,10}, {1,9},
						{0,9}, {1,10}, {1,9})
	new:setHorizontalLine( {0,9}, {1,10}, {1,9} )
	new:setVerticalLine( {1,10}, {1,10}, {1,10} )

	--[[new:addTransition( "l", "concrete", {0, 10} )
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
	new:addTransition( "rb", "wood", {2, 10} )]]
	table.insert( list, new )

	new = Ground:new("spikesConcrete", '1')
	new:addSimilar( 'c' )	-- similar to concrete
	new:setSingleTile( {3,12} )
	new:setThickTiles( {0,13}, {1,13}, {2,13},
						{0,14}, {1,14}, {2,14},
						{0,15}, {1,15}, {2,15})
	new:setHorizontalLine( {0,12}, {1,12}, {2,12} )
	new:setVerticalLine( {3,13}, {3,14}, {3,15} )
	table.insert( list, new )

	new = Ground:new("spikesSoil", '2')
	new:addSimilar( 'd' )	-- similar to dirt
	new:addSimilar( 'g' )	-- similar to grass
	new:addSimilar( 's' )	-- similar to stone
	new:setSingleTile( {7,12} )
	new:setThickTiles( {4,13}, {5,13}, {6,13},
						{4,14}, {5,14}, {6,14},
						{4,15}, {5,15}, {6,15})
	new:setHorizontalLine( {4,12}, {5,12}, {6,12} )
	new:setVerticalLine( {7,13}, {7,14}, {7,15} )
	table.insert( list, new )

	return list
end

return Ground
