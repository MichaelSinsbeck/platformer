Camera = {
  x = 0,
  y = 0,
  xTarget = 0,
  yTarget = 0,
  xWorld = 0,
  yWorld = 0,
	scale = 1,
	xScissor = 0,
	yScissor = 0,
	wScissor = 0,
	hScissor = 0,
  }

function Camera:update(dt)
  local tileSize = myMap.tileSize
  self.x = self.x + 0.1*(self.xTarget-self.x)
  self.y = self.y + 0.1*(self.yTarget-self.y)
  self.xWorld = math.floor(-Camera.x*myMap.tileSize*self.zoom+self.width/2)/self.zoom
  self.yWorld = math.floor(-Camera.y*myMap.tileSize*self.zoom+self.height/2)/self.zoom
  
  -- check if screen is larger than level
  if self.height/self.zoom <= myMap.width*tileSize then
		if self.xWorld > -1*tileSize then self.xWorld = -1*tileSize end  
		if self.xWorld < self.width/self.zoom - (myMap.width+1)*tileSize then
			self.xWorld = self.width/self.zoom - (myMap.width+1)*tileSize
		end  
  else
		self.xWorld = (self.width/self.zoom - (myMap.width+2)*tileSize)/2
  end
  
	if self.width/self.zoom <= myMap.width*tileSize then
		if self.yWorld > -1*tileSize then self.yWorld = -1*tileSize end
		if self.yWorld < self.height/self.zoom - (myMap.height+1)*tileSize then
			self.yWorld = self.height/self.zoom - (myMap.height+1)*tileSize
		end
	else
		self.yWorld = (self.height/self.zoom - (myMap.height+2)*tileSize)/2
	end
	
	self.wScissor = math.min(self.width,myMap.width*tileSize)
	self.hScissor = math.min(self.height,myMap.height*tileSize)
	self.xScissor = (self.width-self.wScissor)/2
	self.yScissor = (self.height-self.hScissor)/2
end

function Camera:init()

	settings:initWindowSize()
	self.zoom = 1

end

-- sets the new scale and reloads all images
function Camera:setScale(scale)
-- scale has to have one of the values 4,5,6,7 or 8
	self.scale = scale
	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()	
	menu:init()
	AnimationDB:loadAll()
	if myMap then -- reload Map-image, if map exists
		myMap:loadImage()
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
	love.graphics.scale(self.zoom,self.zoom)
  love.graphics.translate(self.xWorld,self.yWorld)
  love.graphics.setScissor(self.xScissor,self.yScissor,self.wScissor,self.hScissor)
end

function Camera:free()
	love.graphics.pop()
	love.graphics.setScissor()
end
