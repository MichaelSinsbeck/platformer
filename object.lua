object = {
x = 0,y = 0,
vx = 0, vy = 0,
newX = 0, newY = 0,
--ox = 0, oy = 0,
angle = 0,
z = 0,
collisionResult = false}
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
    self.ox = self.ox or 0.5*self.img:getWidth()
    self.oy = self.oy or 0.5*self.img:getHeight()
		self.semiwidth = self.semiwidth or 0.5*self.img:getWidth()/myMap.tileSize*self.marginx
		self.semiheight = self.semiheight or 0.5*self.img:getHeight()/myMap.tileSize*self.marginy
		if self.rotating then
		  self.semiwidth = math.min(self.semiwidth,self.semiheight)
		  self.semiheight = self.semiwidth
		end
  elseif self.animation then
		self.marginx = self.marginx or 1
    self.marginy = self.marginy or 1
    self.ox = self.ox or 0.5*self.animation.width
    self.oy = self.oy or 0.5*self.animation.height
		self.semiwidth = self.semiwidth or 0.5*self.animation.width/myMap.tileSize*self.marginx
		self.semiheight = self.semiheight or 0.5*self.animation.height/myMap.tileSize*self.marginy
		if self.rotating then
		  self.semiwidth = math.min(self.semiwidth,self.semiheight)
		  self.semiheight = self.semiwidth
		end
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
  if self.animation then
    self.animation:draw(
			math.floor(self.x*myMap.tileSize),
			math.floor(self.y*myMap.tileSize),
			self.angle,
			math.floor(self.ox),math.floor(self.oy))
	elseif self.img then
    --love.graphics.draw(self.img,math.floor(self.x*myMap.tileSize),math.floor(self.y*myMap.tileSize))
    love.graphics.draw(self.img,
				math.floor(self.x*myMap.tileSize),
				math.floor(self.y*myMap.tileSize),
				self.angle,1,1,
				math.floor(self.ox),math.floor(self.oy))
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

  self.collisionResult = false

  if self.vx > 0 then -- Bewegung nach rechts
    -- haben die rechten Eckpunkte die Zelle gewechselt?
    if math.ceil(self.x+self.semiwidth) ~= math.ceil(self.newX+self.semiwidth) then
      -- Kollision in neuen Feldern?
      if myMap.collision[math.ceil(self.newX+self.semiwidth-1)] and
      (myMap.collision[math.ceil(self.newX+self.semiwidth)-1][math.floor(self.y-self.semiheight)] or
        myMap.collision[math.ceil(self.newX+self.semiwidth)-1][math.ceil(self.y+self.semiheight)-1]) then
        self.newX = math.floor(self.newX+self.semiwidth)-self.semiwidth
        self.collisionResult = true
      end
    end
  elseif self.vx < 0 then -- Bewegung nach links
    -- Eckpunkte wechseln Zelle?
    if math.floor(self.x-self.semiwidth) ~= math.floor(self.newX-self.semiwidth) then
      if myMap.collision[math.floor(self.newX-self.semiwidth)] and
      (myMap.collision[math.floor(self.newX-self.semiwidth)][math.floor(self.y-self.semiheight)] or
       myMap.collision[math.floor(self.newX-self.semiwidth)][math.ceil(self.y+self.semiheight)-1]) then
        --self.newX = math.floor(self.newX+1*self.width)
        self.newX = math.ceil(self.newX-self.semiwidth)+self.semiwidth
        self.collisionResult = true
      end
    end
  end
  
  -- Vertical Movement
  if self.vy < 0 then -- rising
    if math.floor(self.y-self.semiheight) ~= math.floor(self.newY-self.semiheight) then
			verticalChange = true
      if (myMap.collision[math.floor(self.newX-self.semiwidth)] and
          myMap.collision[math.floor(self.newX-self.semiwidth)][math.floor(self.newY-self.semiheight)])
          or
         (myMap.collision[math.ceil(self.newX+self.semiwidth)-1] and
          myMap.collision[math.ceil(self.newX+self.semiwidth)-1][math.floor(self.newY-self.semiheight)]) then
        --self.newY = math.floor(self.newY+1)
        self.newY = math.ceil(self.newY-self.semiheight)+self.semiheight
        self.collisionResult = true
      end
    end
    
  elseif self.vy > 0 then -- falling
    if math.ceil(self.y+self.semiheight) ~= math.ceil(self.newY+self.semiheight) then
			verticalChange = true
      if ( myMap.collision[math.floor(self.newX-self.semiwidth)] and 
        myMap.collision[math.floor(self.newX-self.semiwidth)][math.ceil(self.newY+self.semiheight)-1])  or
        (myMap.collision[math.ceil(self.newX+self.semiwidth)-1] and 
        myMap.collision[math.ceil(self.newX+self.semiwidth)-1][math.ceil(self.newY+self.semiheight)-1]) then
        self.newY = math.floor(self.newY+self.semiheight)-self.semiheight        
        self.collisionResult = true
      end
    end
  end    

return collided
end

function object:step(dt)
-- After newX and newY are correct, apply step and set velocity accordingly.
  self.vx = (self.newX - self.x)/dt
  self.vy = (self.newY - self.y)/dt
  self.x = self.newX
  self.y = self.newY
end

function object:postStep(dt)
end

function object:update(dt)
-- Perform all update steps
  if self.animation then
		self.animation:update(dt)
	end
  self:setAcceleration(dt)
	local subdivide = math.max(math.ceil(math.abs(self.vx*dt)),math.ceil(math.abs(self.vy*dt)))
	local dtMicro = dt/subdivide
  for iMicroIterations = 1,subdivide do
		self:predictPosition(dtMicro)
		self:collision(dtMicro)
		self:step(dtMicro)
		self:postStep(dt)
  end
end

function object:touchPlayer(dx,dy)
  local dx = dx or self.x-p.x
  local dy = dy or self.y-p.y
  return math.abs(dx) < p.semiwidth+self.semiwidth and
     math.abs(dy) < p.semiheight+self.semiheight
end
