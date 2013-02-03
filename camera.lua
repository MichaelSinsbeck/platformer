Camera = {
  x = 0,
  y = 0,
  xTarget = 0,
  yTarget = 0,
  width = love.graphics.getWidth(),
	height = love.graphics.getHeight()
  }

function Camera:update(dt)
  self.x = self.x + 0.1*(self.xTarget-self.x)
  self.y = self.y + 0.1*(self.yTarget-self.y)
end

function Camera:setTarget()
  self.xTarget = p.x+0.5
  self.yTarget = p.y+0.5
end

function Camera:apply()
  love.graphics.translate(math.floor(-Camera.x*myMap.tileSize+self.width/2),math.floor(-Camera.y*myMap.tileSize+self.height/2))
end
