require 'scripts/animationdb'

object = {
tag = 'object',
x = 0,y = 0,
vx = 0, vy = 0,
newX = 0, newY = 0,
--ox = 0, oy = 0,
angle = 0,
z = 0, -- for drawing order
collisionResult = false,
timer = 0, -- these two are for the animation
frame = 1,
sonTimer = 0,
sonFrame = 1,
flipped = false}
-- ox and oy are the coordinates of the image center
-- semiwidth and semiheight define the hitbox of the object

function object:New(input)
  local o = input or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function object:init()
-- do whatever needs to be done to initialize the object
  -- set height and width of hitbox, if not done already
  if self.img then
    self.marginx = self.marginx or 1
    self.marginy = self.marginy or 1
    self.ox = self.ox or 0.5*self.img:getWidth()/Camera.scale
    self.oy = self.oy or 0.5*self.img:getHeight()/Camera.scale
		self.semiwidth = self.semiwidth or 0.5*self.img:getWidth()/myMap.tileSize*self.marginx
		self.semiheight = self.semiheight or 0.5*self.img:getHeight()/myMap.tileSize*self.marginy
		if self.rotating then
		  self.semiwidth = math.min(self.semiwidth,self.semiheight)
		  self.semiheight = self.semiwidth
		end
  elseif self.animation then
		self.marginx = self.marginx or 1
    self.marginy = self.marginy or 1
    local name = AnimationDB.animation[self.animation].source
    self.ox = self.ox or 0.5*AnimationDB.source[name].width/Camera.scale
    self.oy = self.oy or 0.5*AnimationDB.source[name].height/Camera.scale
        
		self.semiwidth = self.semiwidth or 0.5*AnimationDB.source[name].width/myMap.tileSize*self.marginx
		self.semiheight = self.semiheight or 0.5*AnimationDB.source[name].height/myMap.tileSize*self.marginy
		if self.rotating then
		  self.semiwidth = math.min(self.semiwidth,self.semiheight)
		  self.semiheight = self.semiwidth
		end
  end
	if self.sonAnimation then
		local name = AnimationDB.animation[self.sonAnimation].source
		self.sonox = self.sonox or 0.5*AnimationDB.source[name].width/Camera.scale
		self.sonoy = self.sonoy or 0.5*AnimationDB.source[name].height/Camera.scale
	elseif self.sonImg then
		self.sonox = self.sonox or 0.5*self.sonImg:getWidth()/Camera.scale
		self.sonoy = self.sonoy or 0.5*self.sonImg:getHeight()/Camera.scale
	end  
end

function object:setImage(filename)
-- Set Image and calculate width and height
  self.img        = love.graphics.newImage(filename)
  self.ox = 0.5*self.img:getWidth()
	self.oy = 0.5*self.img:getHeight()
	self.semiwidth = self.semiwidth or self.ox/myMap.tileSize
	self.semiheight = self.semiheight or self.oy/myMap.tileSize
end

function object:draw()
	if self.alpha then
	  love.graphics.setColor(255,255,255,self.alpha)
	end
  if self.animation then
		local sx,sy = (self.sx or 1), (self.sy or 1)
    self:drawAnimation(
			math.floor(self.x*myMap.tileSize*Camera.zoom)/Camera.zoom,
			math.floor(self.y*myMap.tileSize*Camera.zoom)/Camera.zoom,
			self.angle,sx,sy,
			math.floor(self.ox*Camera.scale),math.floor(self.oy*Camera.scale))
	elseif self.img then
		local sx,sy = (self.sx or 1), (self.sy or 1)
    love.graphics.draw(self.img,
				math.floor(self.x*myMap.tileSize),
				math.floor(self.y*myMap.tileSize),
				self.angle,sx,sy,
				math.floor(self.ox*Camera.scale),math.floor(self.oy*Camera.scale))
  end
  
  if self.sonAnimation then
		local sx,sy = self.sonSx or 1, self.sonSy or 1
		local angle = self.sonAngle or 0
		local x,y = self.sonX or 0, self.sonY or 0
		love.graphics.drawq(self.sonImg, self.sonCurrentQuad,
		  math.floor((self.x+x)*myMap.tileSize),
			math.floor((self.y+y)*myMap.tileSize),
			angle,sx,sy,
			math.floor(self.sonox*Camera.scale),math.floor(self.sonoy*Camera.scale))  
  elseif self.sonImg then
		local sx,sy = self.sonSx or 1, self.sonSy or 1
		local angle = self.sonAngle or 0
		local x,y = self.sonX or 0, self.sonY or 0
		love.graphics.draw(self.sonImg,
			math.floor((self.x+x)*myMap.tileSize),
			math.floor((self.y+y)*myMap.tileSize),
			angle,sx,sy,
			math.floor(self.sonox*Camera.scale),math.floor(self.sonoy*Camera.scale))
  end
	if self.alpha then
	  love.graphics.setColor(255,255,255)
	end
end

function object:kill()
  self.dead = true
end

function object:setAcceleration(dt)
-- apply acceleration to object, generically, this is only gravity
  self.vx = self.vx
  self.vy = self.vy + gravity * dt
end

function object:predictPosition(dt)
-- Using velocity vectors, calculate newX,newY
  self.newX = self.x + self.vx * dt
  self.newY = self.y + self.vy * dt
end

function object:collision(dt)
-- Todo: When this is generically done, remove dt here: unnecessary

  self.collisionResult = 0

  if self.vx > 0 then -- Bewegung nach rechts
    -- haben die rechten Eckpunkte die Zelle gewechselt?
    if math.ceil(self.x+self.semiwidth) ~= math.ceil(self.newX+self.semiwidth) then
      -- Kollision in neuen Feldern?
			if myMap:collisionTest(math.ceil(self.newX+self.semiwidth-1),math.floor(self.y-self.semiheight),'right',self.tag) or
				 myMap:collisionTest(math.ceil(self.newX+self.semiwidth-1),math.ceil(self.y+self.semiheight)-1,'right',self.tag) then
        self.newX = math.floor(self.newX+self.semiwidth)-self.semiwidth
        self.collisionResult = self.collisionResult+1
      end
    end
  elseif self.vx < 0 then -- Bewegung nach links
    -- Eckpunkte wechseln Zelle?
    if math.floor(self.x-self.semiwidth) ~= math.floor(self.newX-self.semiwidth) then
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.floor(self.y-self.semiheight),'right',self.tag) or
				 myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.ceil(self.y+self.semiheight)-1,'right',self.tag) then    
        self.newX = math.ceil(self.newX-self.semiwidth)+self.semiwidth
        self.collisionResult = self.collisionResult+2
      end
    end
  end
  
  -- Vertical Movement
  if self.vy < 0 then -- rising
    if math.floor(self.y-self.semiheight) ~= math.floor(self.newY-self.semiheight) then
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.floor(self.newY-self.semiheight),'up',self.tag) or
				 myMap:collisionTest(math.ceil(self.newX+self.semiwidth)-1,math.floor(self.newY-self.semiheight),'up',self.tag) then
        --self.newY = math.floor(self.newY+1)
        self.newY = math.ceil(self.newY-self.semiheight)+self.semiheight
				self.collisionResult = self.collisionResult+4
      end
    end
    
  elseif self.vy > 0 then -- falling
    if math.ceil(self.y+self.semiheight) ~= math.ceil(self.newY+self.semiheight) then
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.ceil(self.newY+self.semiheight)-1,'down',self.tag) or
				 myMap:collisionTest(math.ceil(self.newX+self.semiwidth)-1,math.ceil(self.newY+self.semiheight)-1,'down',self.tag) then
        self.newY = math.floor(self.newY+self.semiheight)-self.semiheight        
        self.collisionResult = self.collisionResult+8
      end
    end
  end
end

function object:step(dt)
-- After newX and newY are correct, apply step and set velocity accordingly.
  self.vx = (self.newX - self.x)/dt
  self.vy = (self.newY - self.y)/dt
  self.x = self.newX
  self.y = self.newY
  --self.oldx, self.x = self.x, self.newX
  --self.oldy, self.y = self.y, self.newY
end

function object:postStep(dt)
end

function object:update(dt)
-- Perform all update steps
	self.oldx,self.oldy = self.x,self.y
  self:setAcceleration(dt)
	local subdivide = math.max(math.ceil(math.abs(self.vx*dt)),math.ceil(math.abs(self.vy*dt)))
	local dtMicro = dt/subdivide
  for iMicroIterations = 1,subdivide do
		self:predictPosition(dtMicro)
		self:collision(dtMicro)
		self:step(dtMicro)
  end
  if subdivide == 0 then
    self:collision(dt)
  end
	self:postStep(dt)  
  if self.animation then
		self:updateAnimation(dt)
	end  
end

function object:touchPlayer(dx,dy)
  local dx = dx or self.x-p.x
  local dy = dy or self.y-p.y
  return math.abs(dx) < p.semiwidth+self.semiwidth and
     math.abs(dy) < p.semiheight+self.semiheight
end

function object:updateAnimation(dt)
	
  self.timer = self.timer + dt
  -- switch to next frame
  if self.animation then
		local animationData = AnimationDB.animation[self.animation]
		local source = AnimationDB.source[animationData.source]
		while self.timer > animationData.duration[self.frame] do
			self.timer = self.timer - animationData.duration[self.frame]
			self.frame = self.frame + 1
			if self.frame > #animationData.frames then
				self.frame = 1
			end
		end
		self.currentQuad = source.quads[animationData.frames[self.frame]]
		self.img = source.image
  end
  
  if self.sonAnimation then
		self.sonTimer = self.sonTimer + dt
		local animationData = AnimationDB.animation[self.sonAnimation]
		local source = AnimationDB.source[animationData.source]
		while self.sonTimer > animationData.duration[self.sonFrame] do
			self.sonTimer = self.sonTimer - animationData.duration[self.sonFrame]
			self.sonFrame = self.sonFrame + 1
			if self.sonFrame > #animationData.frames then
				self.sonFrame = 1
			end
		end
		self.sonCurrentQuad = source.quads[animationData.frames[self.sonFrame] ]
		self.sonImg = source.image
  end
	
end

function object:setAnim(name,continue) -- Go to specified animation and reset, if not already there
	if self.animation ~= name then
	  self.animation = name
	  if not continue then
	    self:resetAnimation()
	  end
	end
end

function object:resetAnimation()
	self.frame = 1
	self.timer = 0
end

function object:drawAnimation(x,y,angle,sx,sy,ox,oy)
  if self.flipped then
    sx = -sx
	end
	if self.img and self.currentQuad then
		love.graphics.drawq(self.img, self.currentQuad,x,y,angle,sx,sy,ox,oy)
	end
end

function object:flip(flipped)
	self.flipped = flipped
end
