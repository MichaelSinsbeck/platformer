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
	gx = 0,	-- guide coordinates and weight
	gy = 0,
	gw = 0,
	px = 0, -- player coordinates
	py = 0,
	yHorizon = 0, -- distance (in pixel) above horizon
	dx = 0, -- distance (in pixel) of horizonal movement
  }

function Camera:update(dt)
	Camera:calculateTarget()
  local tileSize = myMap.tileSize
  local factor = math.min(1, 6*dt)
  local oldXWorld = self.xWorld
  self.x = self.x + factor*(self.xTarget-self.x)
  self.y = self.y + factor*(self.yTarget-self.y)
  self.xWorld = math.floor(-Camera.x*myMap.tileSize*self.zoom+self.width/2)/self.zoom
  self.yWorld = math.floor(-Camera.y*myMap.tileSize*self.zoom+self.height/2)/self.zoom
  
  -- check if screen is larger than level
  if self.width/self.zoom < myMap.width*tileSize then
		local upper = -1*tileSize
		local lower = self.width/self.zoom - (myMap.width+1)*tileSize
		if self.xWorld > upper then self.xWorld = upper end  
		if self.xWorld < lower then self.xWorld = lower end  
  else
		self.xWorld = (self.width/self.zoom - (myMap.width+2)*tileSize)/2
  end
  
	if self.height/self.zoom < myMap.height*tileSize then
		local upper = -1*tileSize
		local lower = self.height/self.zoom - (myMap.height+1)*tileSize
		
		if self.yWorld > upper then self.yWorld = upper end
		if self.yWorld < lower then self.yWorld = lower end
		
		self.yHorizon = (self.yWorld-lower)-0.5*(upper-lower)
	else
		self.yWorld = (self.height/self.zoom - (myMap.height+2)*tileSize)/2
		self.yHorizon = 0
	end
	
	self.wScissor = math.min(self.width,myMap.width*tileSize)
	self.hScissor = math.min(self.height,myMap.height*tileSize)
	self.xScissor = (self.width-self.wScissor)/2
	self.yScissor = (self.height-self.hScissor)/2
	
	self.dx = self.xWorld - oldXWorld
end

function Camera:init()
	settings:initWindowSize()
	self.zoom = 1
end

-- sets the new scale 
function Camera:setScale(scale)
-- scale has to have one of the values 4,5,6,7 or 8
	self.scale = scale
	self.width = love.window.getWidth()
	self.height = love.window.getHeight()	
end

-- reloads all images
function Camera:applyScale()
	AnimationDB:loadAll()
	loadFont()
	BambooBox:init()
	if editor then
		levelEnd:init()
	end	
	menu:init()		-- after AnimationDB:loadAll() !
	--if myMap then -- reload Map-image, if map exists
	--	myMap:loadImage()
	--end

end

function Camera:calculateTarget()
	self.xTarget = self.gw * self.gx + (1-self.gw)*self.px
	self.yTarget = self.gw * self.gy + (1-self.gw)*self.py
end

--function Camera:setTarget()
--  self.xTarget = p.x
--  self.yTarget = p.y
--end

function Camera:resetGuide()
	self.gw = 0
end

function Camera:sendGuide(x,y,weight)
	self.gx = x
	self.gy = y
	self.gw = weight
end

function Camera:sendPlayer(x,y)
	self.px = x
	self.py = y
end

function Camera:jumpTo(x,y)
  self.x = x
  self.y = y
end

function Camera:apply()
	love.graphics.push()
	love.graphics.scale(self.zoom,self.zoom)
  love.graphics.translate(self.xWorld,self.yWorld)
  love.graphics.setScissor(self.xScissor,self.yScissor,self.wScissor,self.hScissor)
end

function Camera:free()
	love.graphics.pop()
	love.graphics.setScissor()
end
