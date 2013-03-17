Map = {}

function Map:LoadFromFile(mapFile)
	mapFile = mapFile or 'level1.lua'

	local o = {}
	setmetatable(o, self)
	self.__index = self	

	-- Define the meaning of the function in the level file	
	function mapSize(width,height,tileSize)	o.width, o.height, o.tileSize = width, height, tileSize	end
	function imageFilename(b) o.imageFile = b end
	function loadTiles (b) o.tile = b end
	function loadCollision (b) o.collision = b end

  -- Load File
	love.filesystem.load(mapFile)()
	
	-- Postprocess
	local img = love.graphics.newImage(o.imageFile)
  img:setFilter('nearest','nearest')
 -- o.spriteBatch = love.graphics.newSpriteBatch(img, (math.floor(camWidth/o.tileSize)+1) * (math.floor(camHeight/o.tileSize)+1))
  o.spriteBatch = love.graphics.newSpriteBatch(img, o.width*o.height)
  -- delete all "0" value
  for i = 1,o.width do
    for j = 1,o.height do
      if o.tile[i][j] == 0 then o.tile[i][j] = nil end
      if o.collision[i][j] == 0 then o.collision[i][j] = nil end
    end
  end
    
  

  -- Generate Quads for Spritebatch
  gapSize = 0
  o.quads = {}
  imageWidth = img:getWidth()
  imageHeight = img:getHeight()
  for j = 1,math.floor(imageHeight/(o.tileSize+gapSize)) do
    for i = 1,math.floor(imageWidth/(o.tileSize+gapSize)) do
      o.quads[i+(j-1)*math.floor(imageWidth/o.tileSize)] = 
        love.graphics.newQuad((i-1)*(o.tileSize+gapSize),(j-1)*(o.tileSize+gapSize), o.tileSize, o.tileSize,
        imageWidth,imageHeight)
    end
  end
	o:updateSpritebatch()
	return o	
end

function Map:New(imageFile,tileSize)
  tileSize = tileSize or 32
  local gapSize = 0
  local o ={}
	setmetatable(o, self)
	self.__index = self
  
  local img = love.graphics.newImage(imageFile)
  img:setFilter('nearest','nearest')
  o.imageFile = imageFile
  o.tileSize = tileSize
  o.spriteBatch = love.graphics.newSpriteBatch(img, (math.floor(camWidth/tileSize)+1) * (math.floor(camHeight/tileSize)+1))
  -- Quads erzeugen für SpriteBatch
  o.quads = {}
  imageWidth = img:getWidth()
  imageHeight = img:getHeight()
  for j = 1,math.floor(imageHeight/(tileSize+gapSize)) do
    for i = 1,math.floor(imageWidth/(tileSize+gapSize)) do
      o.quads[i+(j-1)*math.floor(imageWidth/tileSize)] = 
        love.graphics.newQuad((i-1)*(tileSize+gapSize),(j-1)*(tileSize+gapSize), tileSize, tileSize,
        imageWidth,imageHeight)
    end
  end
  
  o.height = 30
  o.width = 45
  o.tile = {}
  o.collision = {}
  for i = 1,o.width do
    o.tile[i]={}
    o.collision[i] = {}
  end
  for i = 1,o.width do
    o.tile[i][1] = 2
    o.tile[i][o.height] = 1
    o.collision[i][1] = 1
    o.collision[i][o.height] = 1    
  end
  for i = 1,o.height do
    o.tile[1][i] = 2
    o.tile[o.width][i] = 2
    
    o.collision[1][i] = 1
    o.collision[o.width][i] = 1
  end
  
  for i = 3,13 do
      o.collision[i][o.height-1] = 1
      o.tile[i][o.height-1] = 4
    for j = 4,i do
      o.tile[i][o.height-j] = 5
      o.collision[i][o.height-j] =1
    end
  end
  
  o.tile[15][15] = 3
  return o
end

function Map:updateSpritebatch()
  -- Update Spritebatch
  self.spriteBatch:clear()
  
  -- Erste Möglichkeit: Schleife über alle nicht-leeren self.tile-Einträge
  for x in pairs(self.tile) do
    if x+1 > Camera.x-Camera.width/2 and x < Camera.x+Camera.width/2 then
      for y in pairs(self.tile[x]) do
        if y+1 > Camera.y-Camera.height/2 and y < Camera.y+Camera.height/2 then
          if self.quads[self.tile[x][y]] then
            self.spriteBatch:addq(self.quads[self.tile[x][y] ], x*self.tileSize, y*self.tileSize)
          end
        end
      end
    end
  end
  
  -- Zweite Möglichkeit: Schleife über alle x und y, die im Sichtbereich sind.
  --[[for x=math.floor(Camera.x-Camera.width/2),math.floor(Camera.x+Camera.width/2) do
    if self.tile[x] then
      for y = math.floor(Camera.y-Camera.height/2),math.floor(Camera.y+Camera.height/2) do
        if self.tile[x][y] and self.quads[self.tile[x][y] ] then
          self.spriteBatch:addq(self.quads[self.tile[x][y] ], x*self.tileSize, y*self.tileSize)        
        end
      end
    end
  end]]
  
  
end

function Map:draw()
  love.graphics.draw(self.spriteBatch,0,0)
end

function Map:save(filename)
filename = filename or 'map.dat'
writedata = ''
writedata = writedata .. 'mapSize(' .. self.width .. ', ' .. self.height .. ', ' .. self.tileSize .. ')\r\n'
writedata = writedata .. 'imageFilename("' .. self.imageFile .. '")\r\n'
writedata = writedata .. 'loadTiles\{\r\n' .. arrayToString(self.tile,self.width,self.height) .. '\}\r\n'
writedata = writedata .. 'loadCollision\{\r\n' .. arrayToString(self.collision,self.width,self.height) .. '\}'

print(writedata)
love.filesystem.write(filename,writedata)
end

function arrayToString(array,width,height)
backstring = ''

for i = 1,width do
	local newlinesymbol = '\},\r\n'
	if i == width then newlinesymbol = '\}\r\n' end
	for j = 1,height do
	  local filler = ','
	  if j == 1 then filler = '  \{' end
		if array[i] and array[i][j] then
			backstring = backstring .. filler .. array[i][j]
		else
			backstring = backstring .. filler .. '0'
		end
	end
	backstring = backstring .. newlinesymbol
end
return backstring
end
