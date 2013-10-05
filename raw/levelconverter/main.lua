loader = require("AdvTiledLoader/Loader")

function love.load(args)
	loader.path = "maps/"

	if #args > 1 then
		for i = 2,#args do
			convert(args[i])
		end
	else
		local files = love.filesystem.enumerate(loader.path)
		for k, file in ipairs(files) do
			if string.sub(file,-4,-1) == '.tmx' then
				local trunc = string.sub(file,1,-5)
				convert(trunc)
			end
		end
	end

  print('Done')
  love.event.push("quit")
end


function convert(filetrunc)
	print('Converting '..filetrunc..'.tmx')
	map = loader.load(filetrunc .. '.tmx')
	-- initialize arrays for data
	bg  = {}
	wall = {}
	fg  = {}
	obj = {}
	col = {}
	for y = 1,map.height do
		bg[y] = {}
		wall[y] = {}
		fg[y] = {}
		obj[y] = {}
		col[y] = {}
			for x = 1,map.width do
		  bg[y][x] = 0
			wall[y][x] = 0
		  fg[y][x] = 0
		 	obj[y][x] = 0
			col[y][x] = 0
		end
	end

	-- fill arrays
	for x, y, tile in map("bg"):iterate() do
		if tile.id ~= 0 then
			bg[y+1][x+1] = tile.id - 144
		end
	end

	for x, y, tile in map("walls"):iterate() do
		wall[y+1][x+1] = tile.id
	end

	for x, y, tile in map("fg"):iterate() do
	  fg[y+1][x+1] = tile.id
	end

	for x, y, tile in map("objects"):iterate() do
		if tile.id == 65 then
		  if xStart then
		    print('Warning, multiple starting points')
		  end
		  xStart = x+1
		  yStart = y+1
		else
			if tile.id ~= 0 then
			  obj[y+1][x+1] = tile.id-64
			end
		end
	end

	-- Fallback for start position
	if not xStart then
		xStart = 1
		yStart = 1
	end

	height = map.height
	width = map.width


-- fill collision array
	bgToCollision = {
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,0,1,0,0,0,
		1,0,0,0,0,0,0,0,
		1,1,1,1,0,0,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
	}
	bgToCollision[0] = 0

	wallToCollision = {
		1,1,1,1,0,2,2,2,
		1,1,1,1,0,2,2,0,
		1,1,1,1,0,0,0,0,
		1,1,1,1,0,0,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
	}
	wallToCollision[0] = 0

	objToCollision = {
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,4,4,
		0,0,1,1,1,1,1,0,
		0,0,0,0,0,0,0,0,
		3,3,3,3,1,1,1,1,
		3,3,3,3,1,1,1,1,
		3,3,3,3,1,1,1,1,
		3,3,3,3,1,1,1,1,
		0,0,0,0,0,0,0,0,
	}
	objToCollision[0] = 0

	fgToCollision = {
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,
		3,3,3,3,0,0,0,0,
		3,3,3,3,0,0,0,0,
		3,3,3,3,0,0,0,0,
		3,3,3,3,0,0,0,0,

	}
	fgToCollision[0] = 0

	for y = 1,map.height do
			for x = 1,map.width do
			local entry = math.max(
				wallToCollision[wall[y][x]],
				wallToCollision[fg[y][x]],
				objToCollision[obj[y][x]],
				bgToCollision[bg[y][x]])
			col[y][x] = entry
			if fgToCollision[obj[y][x]] == 3 then -- if there is a spikey
				fg[y][x] = obj[y][x]
				obj[y][x] = 33
			end
		end
	end

	backstring1 = ''
	backstring2 = ''
	backstring3 = ''
	backstring4 = ''
	backstring5 = ''

	for j = 1,width do
		local newlinesymbol = '\},\r\n'
		if j == width then newlinesymbol = '\}\r\n' end
		for i = 1,height do
			local filler = ','
			if i == 1 then filler = '  \{' end
			if bg[i] and bg[i][j] then
				backstring1 = backstring1 .. filler .. bg[i][j]
			else
				backstring1 = backstring1 .. filler .. '0'
			end
			if fg[i] and fg[i][j] then
				backstring2 = backstring2 .. filler .. fg[i][j]
			else
				backstring2 = backstring2 .. filler .. '0'
			end
			if obj[i] and obj[i][j] then
				backstring3 = backstring3 .. filler .. obj[i][j]
			else
				backstring3 = backstring3 .. filler .. '0'
			end
			if wall[i] and wall[i][j] then
				backstring4 = backstring4 .. filler .. wall[i][j]
			else
				backstring4 = backstring4 .. filler .. '0'
			end
			if col[i] and col[i][j] then
				backstring5 = backstring5 .. filler .. col[i][j]
			else
				backstring5 = backstring5 .. filler .. '0'
			end
		end
		backstring1 = backstring1 .. newlinesymbol
		backstring2 = backstring2 .. newlinesymbol
		backstring3 = backstring3 .. newlinesymbol
		backstring4 = backstring4 .. newlinesymbol
		backstring5 = backstring5 .. newlinesymbol
	end

	-- collision-backstring4-füllen

	writedata = ''
	writedata = writedata .. 'mapSize(' .. width .. ', ' .. height .. ')\r\n'
	writedata = writedata .. 'start\{x='..xStart..',y='..yStart..'\}\r\n'
	writedata = writedata .. 'loadBG\{\r\n' .. backstring1 .. '\}\r\n'
	writedata = writedata .. 'loadFG\{\r\n' .. backstring2 .. '\}\r\n'
	writedata = writedata .. 'loadOBJ\{\r\n' .. backstring3 .. '\}\r\n'
	writedata = writedata .. 'loadWall\{\r\n' .. backstring4 .. '\}\r\n'
	writedata = writedata .. 'loadCollision\{\r\n' .. backstring5 .. '\}\r\n'

	xStart = nil
	yStart = nil
	-- print(writedata)

--	for i, obj in pairs( map("objects").objects ) do
--		  print( "Hi, my name is " .. obj.name .. ', Number = '..i )
--	end

--  for x, y, tile in map("objects"):iterate() do
--    print( string.format("Entity at (%d,%d) has an id of %d", x, y, tile.id) )
--	end

	love.filesystem.write(filetrunc..'.dat',writedata)
end

function love.keypressed(key)
   if key == "escape" then
      love.event.push("quit")
   end
end
