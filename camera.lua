Camera = {
  x = 0,
  y = 0,
  xTarget = 0,
  yTarget = 0,
  xWorld = 0,
  yWorld = 0,
  width = love.graphics.getWidth(),
	height = love.graphics.getHeight(),
	scale = 1,
	desiredWidth = 32,
  }

function Camera:update(dt)
  local tileSize = myMap.tileSize
  self.x = self.x + 0.1*(self.xTarget-self.x)
  self.y = self.y + 0.1*(self.yTarget-self.y)
  self.xWorld = math.floor(-Camera.x*myMap.tileSize*self.scale+self.width/2)/self.scale
  self.yWorld = math.floor(-Camera.y*myMap.tileSize*self.scale+self.height/2)/self.scale
  
  if self.xWorld > -1*tileSize then self.xWorld = -1*tileSize end
  if self.yWorld > -1*tileSize then self.yWorld = -1*tileSize end
  if self.xWorld < self.width/self.scale - (myMap.width+1)*tileSize then
    self.xWorld = self.width/self.scale - (myMap.width+1)*tileSize
  end  
  if self.yWorld < self.height/self.scale - (myMap.height+1)*tileSize then
    self.yWorld = self.height/self.scale - (myMap.height+1)*tileSize
  end    
end

function Camera:init()
	-- change screen resolution
	local modes = love.graphics.getModes()
	table.sort(modes, function(a, b) return a.width*a.height > b.width*b.height end)
	--love.graphics.setMode(modes[1].width, modes[1].height, true)
	--love.graphics.setMode(modes[4].width, modes[4].height, false, true, 8)
	modes = nil
	love.graphics.setMode(800,600,false)

	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()
	--self.scale = self.width/(self.desiredWidth*40)
	self.scale = 1

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
	love.graphics.scale(self.scale,self.scale)
  love.graphics.translate(self.xWorld,self.yWorld)
end
