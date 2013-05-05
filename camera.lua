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
  
  if self.xWorld > -2*tileSize then self.xWorld = -2*tileSize end
  if self.yWorld > -2*tileSize then self.yWorld = -2*tileSize end
  if self.xWorld < self.width - (myMap.width)*tileSize then
    self.xWorld = self.width - (myMap.width)*tileSize
  end  
  if self.yWorld < self.height - (myMap.height)*tileSize then
    self.yWorld = self.height - (myMap.height)*tileSize
  end    
end

function Camera:setTarget()
  self.xTarget = p.x
  self.yTarget = p.y
end

function Camera:jumpTo(x,y)
  self.x = x
  self.y = y
end

function Camera:apply()
  love.graphics.translate(self.xWorld,self.yWorld)
end
