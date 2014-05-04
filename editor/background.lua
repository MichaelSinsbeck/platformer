----------------------------------------------
-- Represents all the ground types for the editor:
----------------------------------------------
--
-- Each ground type is represented by a name and a single letter:
-- g: grass
-- c: concrete
-- d: dirt
-- w: wood
-- s: stonr
-- 1: spikes grey
-- 2: spikes brown
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


local Background = {}
Background.__index = Background

local DONT_CARE = ".;"	-- match any character
local DONT_CARE_SINGLE = "."	-- match any character

-- Each ground object will hold one type of ground
-- (Wood, Stone, Concrete, Grass etc)
function Background:new( name, matchName )
	local o = {}
	setmetatable( o, Background )

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

	-- This table stores all variating tiles, indexed by the same "direction" as in
	-- the tiles table above.
	o.variations = {}


	-- start of being similar only to yourself:
	o.similarList = o.matchName
	o.similar = "[" .. o.similarList .. "];"
	-- different is everything besides yourself:
	o.diff = "[^" .. o.similarList .. "];"
	o.matchStrings = {}
	o.matchStrings2 = {}
	
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
function Background:setThickTiles( lt, ct, rt, lm, cm, rm, lb, cb, rb )
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
	l = DONT_CARE .. self.diff .. DONT_CARE	-- line above
	l = l .. self.diff .. self.similar	-- left and right
	l = l .. DONT_CARE .. self.similar .. self.similar		-- line below
	self.matchStrings2.lt = l	-- match AFTER diagonals.

	l = DONT_CARE .. self.diff .. DONT_CARE	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. self.similar .. self.similar .. self.similar		-- line below
	self.matchStrings.ct = l

	l = DONT_CARE .. self.diff .. DONT_CARE	-- line above
	l = l .. self.similar .. self.diff	-- left and right
	l = l .. self.similar .. self.similar .. DONT_CARE		-- line below
	self.matchStrings2.rt = l	-- match AFTER diagonals.

	l = DONT_CARE .. self.similar .. self.similar	-- line above
	l = l .. self.diff .. self.similar	-- left and right
	l = l .. DONT_CARE .. self.similar .. self.similar		-- line below
	self.matchStrings.lm = l

	l = self.similar .. self.similar .. self.similar	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. self.similar .. self.similar .. self.similar		-- line below
	self.matchStrings.cm = l

	l = self.similar .. self.similar .. DONT_CARE	-- line above
	l = l .. self.similar .. self.diff	-- left and right
	l = l .. self.similar .. self.similar .. DONT_CARE		-- line below
	self.matchStrings.rm = l

	l = DONT_CARE .. self.similar .. self.similar	-- line above
	l = l .. self.diff .. self.similar	-- left and right
	l = l .. DONT_CARE .. self.diff .. DONT_CARE		-- line below
	self.matchStrings2.lb = l 	-- match AFTER diagonals!

	l = self.similar .. self.similar .. self.similar	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. DONT_CARE .. self.diff .. DONT_CARE		-- line below
	self.matchStrings.cb = l

	l = self.similar .. self.similar .. DONT_CARE	-- line above
	l = l .. self.similar .. self.diff	-- left and right
	l = l .. DONT_CARE .. self.diff .. DONT_CARE		-- line below
	self.matchStrings2.rb = l		-- match AFTER diagonals!

end


-- clt : corner of which the left out part faces left top...
-- crt : corner of which the left out part faces right top...
function Background:setCorners( clt, crt, clb, crb )
	self.tiles.clt = self:coordsToQuad( clt )
	self.tiles.crt = self:coordsToQuad( crt )
	self.tiles.clb = self:coordsToQuad( clb )
	self.tiles.crb = self:coordsToQuad( crb )

	-- create the matching strings for the new tiles:
	local l = ""
	l = self.diff .. self.similar .. DONT_CARE	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. DONT_CARE .. self.similar .. self.similar		-- line below
	self.matchStrings.clt = l

	l = DONT_CARE .. self.similar .. self.diff	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. self.similar .. self.similar .. DONT_CARE		-- line below
	self.matchStrings.crt = l

	l = DONT_CARE .. self.similar .. self.similar	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. self.diff .. self.similar .. DONT_CARE		-- line below
	self.matchStrings.clb = l

	l = self.similar .. self.similar .. DONT_CARE	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. DONT_CARE .. self.similar .. self.diff		-- line below
	self.matchStrings.crb = l
end


-- the lt, rb, rt and lb give the directions in which there is NO
-- similar tile!
function Background:setDiagonal( ltrb, rtlb )
	self.tiles.ltrb = self:coordsToQuad( ltrb )
	self.tiles.rtlb = self:coordsToQuad( rtlb )

	local l = ""
	l = self.diff .. self.similar .. self.similar	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. self.similar .. self.similar .. self.diff		-- line below
	self.matchStrings.ltrb = l

	l = self.similar .. self.similar .. self.diff	-- line above
	l = l .. self.similar .. self.similar	-- left and right
	l = l .. self.diff .. self.similar .. self.similar		-- line below
	self.matchStrings.rtlb = l
end

-- l: left, c: center, r: right
function Background:setHorizontalLine( l, c, r )
	self.tiles.l = self:coordsToQuad( l )
	self.tiles.c = self:coordsToQuad( c )
	self.tiles.r = self:coordsToQuad( r )

	-- create the matching strings for the new tiles:
	local tmp = ""
	tmp = DONT_CARE .. self.diff .. DONT_CARE	-- line above
	tmp = tmp .. self.diff .. self.similar	-- left and right
	tmp = tmp .. DONT_CARE .. self.diff .. DONT_CARE		-- line below
	self.matchStrings.l = tmp
	
	tmp = DONT_CARE .. self.diff .. DONT_CARE	-- line above
	tmp = tmp .. self.similar .. self.similar	-- left and right
	tmp = tmp .. DONT_CARE .. self.diff .. DONT_CARE		-- line below
	self.matchStrings.c = tmp
	
	tmp = DONT_CARE .. self.diff .. DONT_CARE	-- line above
	tmp = tmp .. self.similar .. self.diff	-- left and right
	tmp = tmp .. DONT_CARE .. self.diff .. DONT_CARE		-- line below
	self.matchStrings.r = tmp
	
end

-- r: top, m: middle, b: bottom
function Background:setVerticalLine( t, m, b )
	self.tiles.t = self:coordsToQuad( t )
	self.tiles.m = self:coordsToQuad( m )
	self.tiles.b = self:coordsToQuad( b )

	-- create the matching strings for the new tiles:
	local tmp = ""
	tmp = DONT_CARE .. self.diff .. DONT_CARE	-- line above
	tmp = tmp .. self.diff .. self.diff	-- left and right
	tmp = tmp .. DONT_CARE .. self.similar .. DONT_CARE		-- line below
	self.matchStrings.t = tmp
	
	tmp = DONT_CARE .. self.similar .. DONT_CARE	-- line above
	tmp = tmp .. self.diff .. self.diff	-- left and right
	tmp = tmp .. DONT_CARE .. self.similar .. DONT_CARE		-- line below
	self.matchStrings.m = tmp
	
	tmp = DONT_CARE .. self.similar .. DONT_CARE	-- line above
	tmp = tmp .. self.diff .. self.diff	-- left and right
	tmp = tmp .. DONT_CARE .. self.diff .. DONT_CARE		-- line below
	self.matchStrings.b = tmp
	
end

function Background:setSingleTile( cm )
	self.tiles.single = self:coordsToQuad( cm )

	local tmp = ""
	tmp = DONT_CARE .. self.diff .. DONT_CARE ..
		self.diff .. self.diff ..
		DONT_CARE .. self.diff .. DONT_CARE
	self.matchStrings.single = tmp
end

function Background:setManual( coordinates, lt, t, rt, l, r, lb, b, rb, coords )
	local name = coordinates[1] .. "x" .. coordinates[2]
	self.tiles[name] = self:coordsToQuad( coordinates )

	local tmp = ""
	tmp = lt .. t .. rt .. l .. r .. lb .. b .. rb

	self.matchStrings[name] = tmp
end

-- allowed values for the arguments:
-- any matching name ('g', 'c', 'd' etc) to match that ground type
-- "similar": match all similar ground types
-- nil: match anything BUT the similar ground types
function Background:addTransition( lt, t, rt, l, r, lb, b, rb, coords )
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
end

function Background:addVariation( dir, coords )
	self.variations[dir] = self:coordsToQuad( coords )
end

function Background:addSimilar( match )

	-- add match to list:
	self.similarList = self.similarList .. match

	-- match these as "similar:"
	-- example: "[gsd];"
	self.similar = "[" .. self.similarList .. "];"

	-- match as "different" every letter that's NOT similar:
	-- example: "[^gds];
	self.diff = "[^" .. self.similarList .. "];"
end

function Background:coordsToQuad( coords )
	return love.graphics.newQuad(
		coords[1]*Camera.scale*8, coords[2]*Camera.scale*8,
		Camera.scale*8, Camera.scale*8,
		AnimationDB.source.tilesetBackground.image:getWidth(),
		AnimationDB.source.tilesetBackground.image:getHeight())
end

-- this returns the correct quad depending on the types of ground
-- above, below, to the right and left of the current tile.
function Background:getQuad( l, r, t, b, lt, rt, lb, rb, forceNoTransition )

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

	--print("Matching against:", mStr)

	--[[
	-- First, check for transitions for this neighbourhood:
	if not forceNoTransition then
		for str, ID in pairs( self.transitions ) do
			if mStr:match(str) then
				foundDir = ID
				break
			end
		end
	end]]
	-- If there was no transition, check for any other matches (this should always return something!)
	if not foundDir then
		for dir, str in pairs( self.matchStrings ) do
			--print("\t...", str, dir )
			if mStr:match(str) then
				--print("\tmatch")
				foundDir = dir
				break
			end
		end
		if not foundDir then
			for dir, str in pairs( self.matchStrings2 ) do
				--print("\t...", str, dir )
				if mStr:match(str) then
					--print("\tmatch")
					foundDir = dir
					break
				end
			end
		end
	end

	-- if a tile was found, check if there are variations for it:
	if foundDir then
		if self.variations[foundDir] then
			if math.random(20) == 1 then
				-- make center tile less likeley to have variation:
				if foundDir ~= "cm" or math.random(2) == 1 then
					return self.variations[foundDir]
				end
			end
		end
		-- return the quad found:
		return self.tiles[foundDir]
	else
		--print("NONE FOUND")
		return false
	end
end

function Background:init()
	local list = {}
	local new = Background:new("concreteBg", 'c' )
	new:addSimilar('s')
	new:addSimilar('d')
	new:setThickTiles( {0,1}, {1,1}, {2,1},
						{0,2}, {1,2}, {2,2},
						{0,3}, {1,3}, {2,3})
	--new:setCorners( {3,0}, {4,0},
					--{3,1}, {4,1})
	--new:setDiagonal( {3,2}, {4,2} )
	new:setSingleTile( {3,0} )
	new:setHorizontalLine( {0,0}, {1,0}, {2,0} )
	new:setVerticalLine( {3,1}, {3,2}, {3,3} )
	new:setManual( {4,0},
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {5,0},
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {6,0},
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {7,0},
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {4,1},
				DONT_CARE, new.similar, new.diff,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.similar )
	new:setManual( {5,1},
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.similar )
	new:setManual( {6,1},
				new.diff, new.similar, DONT_CARE,
				new.similar, new.diff,
				new.similar, new.similar, DONT_CARE )
	new:setManual( {7,1},		-- cross
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {4,2},
				DONT_CARE, new.similar, new.similar,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.diff )
	new:setManual( {5,2},
				new.similar, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {6,2},
				new.similar, new.similar, DONT_CARE,
				new.similar, new.diff,
				new.diff, new.similar, DONT_CARE )
	new:setManual( {7,2}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {7,3}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {0,4}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {1,4}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {2,4}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {3,4}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {4,4}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {5,4}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {6,4}, 
				DONT_CARE, new.similar, new.diff,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.diff )
	new:setManual( {7,4}, 
				new.diff, new.similar, DONT_CARE,
				new.similar, new.diff,
				new.diff, new.similar, DONT_CARE )
	new:setManual( {0,5}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.diff )
	new:setManual( {1,5}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {2,5}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.diff,
				new.diff, new.similar, DONT_CARE )
	new:setManual( {4,3}, 
				DONT_CARE, new.similar, new.diff,
				new.diff, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {5,3}, 
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {6,3}, 
				new.diff, new.similar, DONT_CARE,
				new.similar, new.diff,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {3,5}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.similar, new.similar, new.similar )
	new:setManual( {4,5}, 
				new.similar, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {5,5}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.similar )
	new:setManual( {6,5}, 
				new.similar, new.similar, new.similar,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )


	table.insert( list, new )


	new = Background:new("soilBg", 's' )
	new:addSimilar('d')
	new:setThickTiles( {0,7}, {1,7}, {2,7},
						{0,8}, {1,8}, {2,8},
						{0,9}, {1,9}, {2,9})
	new:setSingleTile( {3,6} )
	new:setHorizontalLine( {0,6}, {1,6}, {2,6} )
	new:setVerticalLine( {3,7}, {3,8}, {3,9} )
	new:setManual( {4,6},
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {5,6},
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {6,6},
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {7,6},
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {4,7},
				DONT_CARE, new.similar, new.diff,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.similar )
	new:setManual( {5,7},
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.similar )
	new:setManual( {6,7},
				new.diff, new.similar, DONT_CARE,
				new.similar, new.diff,
				new.similar, new.similar, DONT_CARE )
	new:setManual( {7,7},		-- cross
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {4,8},
				DONT_CARE, new.similar, new.similar,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.diff )
	new:setManual( {5,8},
				new.similar, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {6,8},
				new.similar, new.similar, DONT_CARE,
				new.similar, new.diff,
				new.diff, new.similar, DONT_CARE )
	new:setManual( {7,8}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {7,9}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {0,10}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {1,10}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {2,10}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {3,10}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {4,10}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {5,10}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {6,10}, 
				DONT_CARE, new.similar, new.diff,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.diff )
	new:setManual( {7,10}, 
				new.diff, new.similar, DONT_CARE,
				new.similar, new.diff,
				new.diff, new.similar, DONT_CARE )
	new:setManual( {0,11}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.diff )
	new:setManual( {1,11}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {2,11}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.diff,
				new.diff, new.similar, DONT_CARE )
	new:setManual( {4,9}, 
				DONT_CARE, new.similar, new.diff,
				new.diff, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {5,9}, 
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {6,9}, 
				new.diff, new.similar, DONT_CARE,
				new.similar, new.diff,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {3,11}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.similar, new.similar, new.similar )
	new:setManual( {4,11}, 
				new.similar, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {5,11}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.similar )
	new:setManual( {6,11}, 
				new.similar, new.similar, new.similar,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )


	table.insert( list, new )

	new = Background:new("soilDarkBg", 'd' )
	new:setThickTiles( {0,13}, {1,13}, {2,13},
						{0,14}, {1,14}, {2,14},
						{0,15}, {1,15}, {2,15})
	new:setSingleTile( {3,12} )
	new:setHorizontalLine( {0,12}, {1,12}, {2,12} )
	new:setVerticalLine( {3,13}, {3,14}, {3,15} )
	new:setManual( {4,12},
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {5,12},
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {6,12},
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {7,12},
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {4,13},
				DONT_CARE, new.similar, new.diff,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.similar )
	new:setManual( {5,13},
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.similar )
	new:setManual( {6,13},
				new.diff, new.similar, DONT_CARE,
				new.similar, new.diff,
				new.similar, new.similar, DONT_CARE )
	new:setManual( {7,13},		-- cross
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {4,14},
				DONT_CARE, new.similar, new.similar,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.diff )
	new:setManual( {5,14},
				new.similar, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {6,14},
				new.similar, new.similar, DONT_CARE,
				new.similar, new.diff,
				new.diff, new.similar, DONT_CARE )
	new:setManual( {7,14}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {7,15}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {0,16}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {1,16}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {2,16}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {3,16}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )
	new:setManual( {4,16}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {5,16}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {6,16}, 
				DONT_CARE, new.similar, new.diff,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.diff )
	new:setManual( {7,16}, 
				new.diff, new.similar, DONT_CARE,
				new.similar, new.diff,
				new.diff, new.similar, DONT_CARE )
	new:setManual( {0,17}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.diff, new.similar,
				DONT_CARE, new.similar, new.diff )
	new:setManual( {1,17}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.similar,
				new.diff, new.similar, new.diff )
	new:setManual( {2,17}, 
				DONT_CARE, new.diff, DONT_CARE,
				new.similar, new.diff,
				new.diff, new.similar, DONT_CARE )
	new:setManual( {4,15}, 
				DONT_CARE, new.similar, new.diff,
				new.diff, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {5,15}, 
				new.diff, new.similar, new.diff,
				new.similar, new.similar,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {6,15}, 
				new.diff, new.similar, DONT_CARE,
				new.similar, new.diff,
				DONT_CARE, new.diff, DONT_CARE )
	new:setManual( {3,17}, 
				new.diff, new.similar, new.similar,
				new.similar, new.similar,
				new.similar, new.similar, new.similar )
	new:setManual( {4,17}, 
				new.similar, new.similar, new.similar,
				new.similar, new.similar,
				new.diff, new.similar, new.similar )
	new:setManual( {5,17}, 
				new.similar, new.similar, new.diff,
				new.similar, new.similar,
				new.similar, new.similar, new.similar )
	new:setManual( {6,17}, 
				new.similar, new.similar, new.similar,
				new.similar, new.similar,
				new.similar, new.similar, new.diff )

	table.insert( list, new )

	return list
end

return Background
