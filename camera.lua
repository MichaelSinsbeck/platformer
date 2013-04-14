Camera = {
  x = 0,
  y = 0,
  xTarget = 0,
  yTarget = 0,
  xWorld = 0,
  yWorld = 0,
  width = love.graphics.getWidth(),
	height = love.graphics.getHeight()
  }

function Camera:update(dt)
  local tileSize = myMap.tileSize
  self.x = self.x + 0.1*(self.xTarget-self.x)
  self.y = self.y + 0.1*(self.yTarget-self.y)
  self.xWorld = math.floor(-Camera.x*myMap.tileSize+self.width/2)
  self.yWorld = math.floor(-Camera.y*myMap.tileSize+self.height/2)  
  
  if self.xWorld > -tileSize then self.xWorld = -tileSize end
  if self.yWorld > -tileSize then self.yWorld = -tileSize end
  if self.xWorld < self.width - (myMap.width+1)*tileSize then
    self.xWorld = self.width - (myMap.width+1)*tileSize
  end  
  if self.yWorld < self.height - (myMap.height+1)*tileSize then
    self.yWorld = self.height - (myMap.height+1)*tileSize
  end    
end

function Camera:setTarget()
  self.xTarget = p.x+0.5*p.width
  self.yTarget = p.y+0.5*p.height
end

function Camera:jumpTo(x,y)
  self.x = x
  self.y = y
end

function Camera:apply()
  love.graphics.translate(self.xWorld,self.yWorld)
end
