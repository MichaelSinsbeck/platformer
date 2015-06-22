----------------------------------------------
-- Represents all the ground types for the editor:
----------------------------------------------
--
-- Each ground type is represented by a name and a single letter:
-- g: grass
-- c: concrete
-- d: dirt
-- w: pyramid
-- s: stone
-- 1: spikes grey
-- 2: spikes brown
-- 3: spikes clouds
-- o: cloud
--
-- A dot represents any tile and a space an empty tile.
--
-- For each variation and transition, a string is created which represents the state of the neighbours; the condition of when to use the variation or transition.
--
-- Whenever a new tile is placed, a string is created which holds all the 8 neightbouring tiles, seperated by ; in the order:
-- top row from left to right, right tile, left tile, bottom row from left to right
-- For example, if the three tiles above are grass and the tiles below are empty, the tiles left and right hold stone, this would result in:
-- "g;g;g;s;s; ; ; ;"
--
-- Now. the string is compared with all the variations' and transitions' strings. As soon as there is a hit, the corresponding quad is returned.
-- Example: If the neighbourhood yields this string:
-- " ; ; ;s;s; ; ; ;"
-- and there's a transition which is represented by this string:
-- ".;.;.;s;s;.;.;.;"
-- then this transition is used, because it matches.
--
-- This allows neat things like representing "similar" tiles: Grass, stone and dirt tiles are similar: So they're added to each other's similar strings. For grass, for example, the similar string looks like this: [gsd];
-- This matches any of g or s or d, so if the following is used for the center tile of the grass:
-- "[gds];[gds];[gds];[gsd];[gsd];[gds];[gds];[gds];"
-- ... then this means that the center tile (cm) does not care whether it's surrounded by grass, stone, dirt or a mixture of them - in either way, it will be using the center piece.
--
-- At the same time, this method allows for transitions:
-- "[^gds];[^gds];[^gds];s;d;[^gds];[^gds];[^gds];"
-- or "[^gds];[^gds];[^gds];s;d;[gds];[gds];[gds];"
-- The first line will match the transition from stone to grass with a black line at the bottom the second one from without a black line at the bottom.
--
--
--


-- IMPORTANT! The similar ground types must be given to a ground BEFORE its tiles are set, otherwise its matching strings cannot be created correctly.


local Ground = {}
Ground.__index = Ground

local DONT_CARE = "."	-- match any character

-- Each ground object will hold one type of ground
-- (pyramid, Stone, Concrete, Grass etc)
function Ground:new( name, matchName )
	local o = {}
	setmetatable( o, Ground )

	o.name = name
	o.matchName = matchName

	-- The 'tiles' table will hold all the ground's tile positions on the tile map.
	-- Naming convention: c: center, l: left, r: right, m: middle, t: top, b:bottom.
	-- Putting these together yields all possible tiles:
	-- lt, ct, rt: the top tiles of the thick block of nine tiles
	-- lm, cm, rm: the middle tiles ''
	-- lb, cb, rc: the lower tiles ''
	-- l, c, r: the horizontal line
	-- t, m, b: the vertical line
	-- single: the single block
	o.tiles = {}

	-- If the ground has transition tiles then
	-- store them in the following:
	o.transitions = {}

	o.transitionNames = {}

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

	-- create the matching strings for the new tiles:
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

	-- create the matching strings for the new tiles:
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

	-- create the matching strings for the new tiles:
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

-- allowed values for the arguments:
-- any matching name ('g', 'c', 'd' etc) to match that ground type
-- "similar": match all similar ground types
-- nil: match anything BUT the similar ground types
function Ground:addTransition( lt, t, rt, l, r, lb, b, rb, coords, tName )
	local lMatch
	local rMatch
	local tMatch
	local bMatch

	-- diagonal:
	local ltMatch
	local rtMatch
	local lbMatch
	local rbMatch

	if l == "similar" then lMatch = self.similar
	else lMatch = l and l .. ";" or self.diff end
	if r == "similar" then rMatch = self.similar
	else rMatch = r and r .. ";" or self.diff end
	if t == "similar" then lMatch = self.similar
	else tMatch = t and t .. ";" or self.diff end
	if b == "similar" then bMatch = self.similar
	else bMatch = b and b .. ";" or self.diff end
	if lt == "similar" then ltMatch = self.similar
	else ltMatch = lt and lt .. ";" or self.diff end
	if rt == "similar" then rtMatch = self.similar
	else rtMatch = rt and rt .. ";" or self.diff end
	if lb == "similar" then lbMatch = self.similar
	else lbMatch = lb and lb .. ";" or self.diff end
	if rb == "similar" then rbMatch = self.similar
	else rbMatch = rb and rb .. ";" or self.diff end

	local mStr = ltMatch .. tMatch .. rtMatch	-- top line
	mStr = mStr .. lMatch .. rMatch					-- center line
	mStr = mStr .. lbMatch .. bMatch .. rbMatch	-- bottom line

	local ID = #self.tiles + 1
	self.tiles[ID] = self:coordsToQuad( coords )
	self.transitions[mStr] = ID

	self.transitionNames[ID] = tName
end

function Ground:addVariation( dir, coords )
	if not self.variations[dir] then
		self.variations[dir] = {}
	end
	table.insert( self.variations[dir], self:coordsToQuad( coords ) )
end

function Ground:addSimilar( match )

	-- add match to list:
	self.similarList = self.similarList .. match

	-- match these as "similar:"
	-- example: "[gsd];"
	self.similar = "[" .. self.similarList .. "];"

	-- match as "different" every letter that's NOT similar:
	-- example: "[^gds];
	self.diff = "[^" .. self.similarList .. "];"
end

function Ground:coordsToQuad( coords )
	return love.graphics.newQuad(
		coords[1]*Camera.scale*10, coords[2]*Camera.scale*10,
		Camera.scale*10, Camera.scale*10,
		AnimationDB.image.tilesetGround:getWidth(),
		AnimationDB.image.tilesetGround:getHeight())
end

-- this returns the correct quad depending on the types of ground
-- above, below, to the right and left of the current tile.
function Ground:getQuad( l, r, t, b, lt, rt, lb, rb, forceNoTransition )

	-- 4-Neighbourhood:
	local lMatch = l and l.matchName .. ";" or " ;"
	local rMatch = r and r.matchName .. ";" or " ;"
	local tMatch = t and t.matchName .. ";" or " ;"
	local bMatch = b and b.matchName .. ";" or " ;"

	-- diagonal:
	local ltMatch = lt and lt.matchName .. ";" or " ;"
	local rtMatch = rt and rt.matchName .. ";" or " ;"
	local lbMatch = lb and lb.matchName .. ";" or " ;"
	local rbMatch = rb and rb.matchName .. ";" or " ;"

	-- Create a match string from the given neighbourhood:
	local mStr = ltMatch .. tMatch .. rtMatch	-- top line
	mStr = mStr .. lMatch .. rMatch					-- center line
	mStr = mStr .. lbMatch .. bMatch .. rbMatch	-- bottom line

	local foundDir
	local foundTransition

	-- First, check for transitions for this neighbourhood:
	for str, ID in pairs( self.transitions ) do
		if not ( forceNoTransition and self.transitionNames[ID] and
				forceNoTransition:find(self.transitionNames[ID]) ) then
			if mStr:match(str) then
				foundDir = ID
				foundTransition = self.transitionNames[ID]
				break
			end
		end
	end
	-- If there was no transition, check for any other matches (this should always return something!)
	if not foundDir then
		for dir, str in pairs( self.matchStrings ) do
			if mStr:match(str) then
				foundDir = dir
				break
			end
		end
	end

	-- if a tile was found, check if there are variations for it:
	if foundDir then
		if self.variations[foundDir] then
			if math.random(20) == 1 then
				-- make center tile less likeley to have variation:
				if foundDir ~= "cm" or math.random(2) == 1 then
					local numVariations = #self.variations[foundDir]
					return self.variations[foundDir][math.random(1,numVariations)]
				end
			end
		end
		-- return the quad found:
		return self.tiles[foundDir], foundTransition
	else
		print("NONE FOUND!")
		return self.tiles.single, foundTransition
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

	-- dirt to grass transitions:
	new:addTransition( nil, nil, nil,
			'g', 'd',
			nil, "similar", nil,
			{1,7}, "gd" )
	new:addTransition( nil, nil, nil,
			'g', 'd',
			nil, nil, nil,
			{3,7}, "gd")
	new:addTransition( nil, nil, nil,
			'd', 'g',
			nil, "similar", nil,
			{1,8}, "dg" )
	new:addTransition( nil, nil, nil,
			'd', 'g',
			nil, nil, nil,
			{3,8}, "dg" )
	-- dirt to stone transitions:
	new:addTransition( nil, nil, nil,
			's', 'd',
			nil, "similar", nil,
			{1,6}, "sd" )
	new:addTransition( nil, nil, nil,
			's', 'd',
			nil, nil, nil,
			{4,6}, "sd" )
	new:addTransition( nil, nil, nil,
			'd', 's',
			nil, "similar", nil,
			{0,8}, "ds" )
	new:addTransition( nil, nil, nil,
			'd', 's',
			nil, nil, nil,
			{2,8}, "ds" )

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

	-- grass to dirt transitions:
	new:addTransition( nil, nil, nil,
			'd', 'g',
			nil, "similar", nil,
			{1,8}, "dg" )
	new:addTransition( nil, nil, nil,
			'd', 'g',
			nil, nil, nil,
			{3,8}, "dg" )
	new:addTransition( nil, nil, nil,
			'g', 'd',
			nil, "similar", nil,
			{1,7}, "gd" )
	new:addTransition( nil, nil, nil,
			'g', 'd',
			nil, nil, nil,
			{3,7}, "gd" )
	-- grass to dirt:
	new:addTransition( nil, nil, nil,
			's', 'g',
			nil, "similar", nil,
			{0,6}, "sg" )
	new:addTransition( nil, nil, nil,
			's', 'g',
			nil, nil, nil,
			{2,6}, "sg" )
	new:addTransition( nil, nil, nil,
			'g', 's',
			nil, "similar", nil,
			{0,7}, "gs" )
	new:addTransition( nil, nil, nil,
			'g', 's',
			nil, nil, nil,
			{2,7}, "gs" )
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

	-- stone to dirt:
	new:addTransition( nil, nil, nil,
			'd', 's',
			nil, "similar", nil,
			{0,8}, "ds" )
	new:addTransition( nil, nil, nil,
			'd', 's',
			nil, nil, nil,
			{2,8}, "ds" )
	new:addTransition( nil, nil, nil,
			's', 'd',
			nil, "similar", nil,
			{1,6}, "sd" )
	new:addTransition( nil, nil, nil,
			's', 'd',
			nil, nil, nil,
			{3,6}, "sd" )
	-- stone to grass:
	new:addTransition( nil, nil, nil,
			'g', 's',
			nil, "similar", nil,
			{0,7}, "gs" )
	new:addTransition( nil, nil, nil,
			'g', 's',
			nil, nil, nil,
			{2,7}, "gs" )
	new:addTransition( nil, nil, nil,
			's', 'g',
			nil, "similar", nil,
			{0,6}, "sg" )
	new:addTransition( nil, nil, nil,
			's', 'g',
			nil, nil, nil,
			{2,6}, "sg" )
	table.insert( list, new )
	
	new = Ground:new("pyramid", 'w')
	new:setSingleTile( {7, 8} )
	new:setThickTiles( {4,9}, {5,9}, {6,9},
						{4,10}, {5,10}, {6,10},
						{4,11}, {5,11}, {6,11})
	new:setHorizontalLine( {4,8}, {5,8}, {6,8} )
	new:setVerticalLine( {7,9}, {7,10}, {7,11} )
	new:addVariation( "cm", {4,16})
	table.insert( list, new )

	new = Ground:new("bridge", 'b' )
	new:addSimilar( 'c' )	-- similar to concrete
	new:addSimilar( 's' )	-- similar to stone
	new:addSimilar( 'g' )
	new:addSimilar( 'd' )
	new:addSimilar( 'w' )
	new:addSimilar( 'o' )
	new:setSingleTile( {2,16} )
	new:setThickTiles( {0,9}, {1,10}, {1,9},
						{0,9}, {1,10}, {1,9},
						{0,9}, {1,10}, {1,9})
	new:setHorizontalLine( {0,9}, {1,10}, {1,9} )
	new:setVerticalLine( {1,10}, {1,10}, {1,10} )

	new:addTransition( DONT_CARE, DONT_CARE, DONT_CARE,
			'[cdgswo]', '[cdgswo]',
			DONT_CARE, DONT_CARE, DONT_CARE,
			{3,16} )
	new:addTransition( DONT_CARE, DONT_CARE, DONT_CARE,
			'[cdgswo]', 'similar',
			DONT_CARE, DONT_CARE, DONT_CARE,
			{0,10} )

	new:addTransition( DONT_CARE, DONT_CARE, DONT_CARE,
			'similar','[cdgswo]',
			DONT_CARE, DONT_CARE, DONT_CARE,
			{2,10} )

	new:addTransition( DONT_CARE, DONT_CARE, DONT_CARE,
			nil, '[cdgswo]',
			DONT_CARE, DONT_CARE, DONT_CARE,
			{0,16} )

	new:addTransition( DONT_CARE, DONT_CARE, DONT_CARE,
			'[cdgswo]', nil,
			DONT_CARE, DONT_CARE, DONT_CARE,
			{1,16} )

	new:addTransition( DONT_CARE, DONT_CARE, DONT_CARE,
			nil, nil,
			DONT_CARE, DONT_CARE, DONT_CARE,
			{2,16} )

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

	local new = Ground:new("cloud", 'o' )
	new:addSimilar( '3' )	-- similar to cloud
	new:setSingleTile( {11, 0} )
	new:setThickTiles( {8,1}, {9,1}, {10,1},
						{8,2}, {9,2}, {10,2},
						{8,3}, {9,3}, {10,3})
	new:setHorizontalLine( {8,0}, {9,0}, {10,0} )
	new:setVerticalLine( {11,1}, {11,2}, {11,3} )

	new:addVariation( "single", {11,4})

	table.insert( list, new )
	
	new = Ground:new("spikesCloud", '3')
	new:addSimilar( 'o' )	-- similar to cloud
	new:setSingleTile( {11,12} )
	new:setThickTiles( {8,13}, {9,13}, {10,13},
						{8,14}, {9,14}, {10,14},
						{8,15}, {9,15}, {10,15})
	new:setHorizontalLine( {8,12}, {9,12}, {10,12} )
	new:setVerticalLine( {11,13}, {11,14}, {11,15} )
	table.insert( list, new )

	return list
end

return Ground
