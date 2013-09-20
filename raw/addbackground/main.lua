--[[Opens all maps, add the layer "background" and saves --]]

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
	walls = {}
	bg = {}
	for y = 1,map.height do
		fg[y] = {}
		objects[y] = {}
		bg[y] = {}
		walls[y] = {}
			for x = 1,map.width do
		  fg[y][x] = 0
		  objects[y][x] = 0
		  bg[y][x] = 0
			walls[y][x] = 0
		end
	end

	for x, y, tile in map("bg"):iterate() do
		walls[y+1][x+1] = tile.id
	end

	for x, y, tile in map("objects"):iterate() do
		objects[y+1][x+1] = tile.id
	end

	for x, y, tile in map("fg"):iterate() do
		fg[y+1][x+1] = tile.id
	end

	height = #bg
	width = #bg[1]

-- constructing arrays

	backstring1 = ''
	backstring2 = ''
	backstring3 = ''
	backstring4 = ''
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
				backstring2 = backstring2 .. filler .. walls[i][j]
				backstring3 = backstring3 .. filler .. objects[i][j]
				backstring4 = backstring4 .. filler .. fg[i][j]
			else
				backstring1 = backstring1 .. filler .. '0'
				backstring2 = backstring2 .. filler .. '0'
				backstring3 = backstring3 .. filler .. '0'
				backstring4 = backstring4 .. filler .. '0'
			end
		end
		backstring1 = backstring1 .. newlinesymbol
		backstring2 = backstring2 .. newlinesymbol
		backstring3 = backstring3 .. newlinesymbol
		backstring4 = backstring4 .. newlinesymbol
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
	writedata = writedata .. ' <tileset firstgid="145" name="background" tilewidth="50" tileheight="50">\n'
	writedata = writedata .. '  <image source="background1.png" width="400" height="400"/>\n'
	writedata = writedata .. ' </tileset>\n'

	writedata = writedata .. ' <layer name="bg" width="'..width..'" height="'..height..'">\n'
	writedata = writedata .. '  <data encoding="csv">'

	writedata = writedata .. backstring1

	writedata = writedata .. '</data>\n'
	writedata = writedata .. ' </layer>\n'
	writedata = writedata .. ' <layer name="walls" width="'..width..'" height="'..height..'">\n'
	writedata = writedata .. '  <data encoding="csv">\n'

	writedata = writedata .. backstring2

	writedata = writedata .. '</data>\n'
	writedata = writedata .. ' </layer>\n'
	writedata = writedata .. ' <layer name="objects" width="'..width..'" height="'..height..'">\n'
	writedata = writedata .. '  <data encoding="csv">\n'

	writedata = writedata .. backstring3

	writedata = writedata .. '</data>\n'
	writedata = writedata .. ' </layer>\n'
	writedata = writedata .. ' <layer name="fg" width="'..width..'" height="'..height..'">\n'
	writedata = writedata .. '  <data encoding="csv">\n'

	writedata = writedata .. backstring4
	
	writedata = writedata .. '</data>\n'
	writedata = writedata .. ' </layer>\n'
	writedata = writedata .. '</map>\n'


--print('Backstring4:')
--print(backstring4)
--print(writedata)


	love.filesystem.write(filetrunc..'.tmx',writedata)
end

function love.keypressed(key)
   if key == "escape" then
      love.event.push("quit")
   end
end
