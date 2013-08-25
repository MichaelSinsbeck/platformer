loader = require("AdvTiledLoader/Loader")

function love.load()

	loader.path = "maps/"
	local files = love.filesystem.enumerate(loader.path)
	for k, file in ipairs(files) do
		if string.sub(file,-4,-1) == '.tmx' then
		  local trunc = string.sub(file,1,-5)
		  convert(trunc)
		end
	end--]]
--	convert('targetformat')

  print('Done')
  love.event.push("quit")
end


function convert(filetrunc)
	print('Converting '..filetrunc..'.tmx')
	map = loader.load(filetrunc .. '.tmx')

	fg = {}
	objects = {}
	bg = {}
	for y = 1,map.height do
		fg[y] = {}
		objects[y] = {}
		bg[y] = {}
			for x = 1,map.width do
		  fg[y][x] = 0
		  objects[y][x] = 0
		  bg[y][x] = 0
		end
	end

	tobg  = {
		1,2,3,4,14,15,
		9,10,11,12,6,8,
		17,18,19,20,7,64,
		25,26,27,28,42,63,
		0,0,0,0,57,49,
		0,0,0,0,41,0,
		0,0,0,0,33,34,
		0,0,0,0,0,0,
		61,0,0,0,0,0,
		0,0,0,0,0,62,
		0,0,0,0,0,0,
		0,0,0,0,0,0}

	toobj  = {
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		33,34,35,36,0,0,		
		41,42,43,44,0,25,
		49,50,51,52,0,0,
		57,58,59,60,1,2,
		0,9,10,0,7,12,
		13,3,4,5,6,0,
		17,18,19,11,15,16,
		20,21,37,38,0,0}

	tofg = {
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,0}

	tofg[0]=0
	tobg[0]=0
	toobj[0]=0

	for x, y, tile in map("bg"):iterate() do
	  bg[y+1][x+1] = tobg[tile.id]
	  fg[y+1][x+1] = tofg[tile.id]
		if toobj[tile.id] ~= 0 then
		  objects[y+1][x+1] = toobj[tile.id]+64
		end
	end

	height = #bg
	width = #bg[1]

-- constructing arrays

	backstring1 = ''
	backstring2 = ''
	backstring3 = ''
--	for j = 1,width do
	for i = 1,height do
		local newlinesymbol = ',\r\n'
--		if j == width then newlinesymbol = '\r\n' end
		if i == height then newlinesymbol = '\r\n' end
--		for i = 1,height do
		for j = 1,width do
			local filler = ','
			if j == 1 then filler = '  ' end
			if bg[i] and bg[i][j] then
				backstring1 = backstring1 .. filler .. bg[i][j]
				backstring2 = backstring2 .. filler .. objects[i][j]
				backstring3 = backstring3 .. filler .. fg[i][j]
			else
				backstring1 = backstring1 .. filler .. '0'
				backstring2 = backstring2 .. filler .. '0'
				backstring3 = backstring3 .. filler .. '0'
			end
		end
		backstring1 = backstring1 .. newlinesymbol
		backstring2 = backstring2 .. newlinesymbol
		backstring3 = backstring3 .. newlinesymbol
	end

-- start writing

	writedata = '<?xml version="1.0" encoding="UTF-8"?>\n'
	writedata = writedata .. '<map version="1.0" orientation="orthogonal" width="'.. width ..'" height="'.. height ..'" tilewidth="40" tileheight="40">\n'
	writedata = writedata .. ' <tileset firstgid="1" name="world1" tilewidth="50" tileheight="50">\n'
	writedata = writedata .. '  <image source="world1.png" width="400" height="400"/>\n'
	writedata = writedata .. ' </tileset>\n'
	writedata = writedata .. ' <tileset firstgid="65" name="objectpalette" tilewidth="50" tileheight="50">\n'
	writedata = writedata .. '  <image source="objectpalette.png" width="400" height="400"/>\n'
	writedata = writedata .. ' </tileset>\n'
	writedata = writedata .. ' <layer name="bg" width="'..width..'" height="'..height..'">\n'
	writedata = writedata .. '  <data encoding="csv">'

	writedata = writedata .. backstring1

	writedata = writedata .. '</data>\n'
	writedata = writedata .. ' </layer>\n'
	writedata = writedata .. ' <layer name="objects" width="'..width..'" height="'..height..'">\n'
	writedata = writedata .. '  <data encoding="csv">\n'

	writedata = writedata .. backstring2

	writedata = writedata .. '</data>\n'
	writedata = writedata .. ' </layer>\n'
	writedata = writedata .. ' <layer name="fg" width="'..width..'" height="'..height..'">\n'
	writedata = writedata .. '  <data encoding="csv">\n'

	writedata = writedata .. backstring3

	writedata = writedata .. '</data>\n'
	writedata = writedata .. ' </layer>\n'
	writedata = writedata .. '</map>\n'




--print(writedata)


	love.filesystem.write(filetrunc..'.tmx',writedata)
end

function love.keypressed(key)
   if key == "escape" then
      love.event.push("quit")
   end
end
