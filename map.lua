Map = {}

function Map:New(imageFile,tileSize)
  tileSize = tileSize or 32
  local gapSize = 0
  local o ={}
	setmetatable(o, self)
	self.__index = self
  
  local img = love.graphics.newImage(imageFile)
  img:setFilter('nearest','nearest')
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
  
  o.height = 100
  o.width = 150
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
      o.tile[i][o.height-1] = 3
    for j = 4,i do
      o.tile[i][o.height-j] = 4
      o.collision[i][o.height-j] =1
    end
  end
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
          if self.quads[self.tile[x][y] ] then
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
