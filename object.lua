object = {
x = 0,y = 0,
vx = 0, vy = 0,
newX = 0, newY = 0,
collisionResult = false}

function object:New(input)
  local o = input or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function object:init()
-- do whatever needs to be done to initialize the object
  if self.img then
		self.width = self.img:getWidth()/myMap.tileSize
		self.height = self.img:getHeight()/myMap.tileSize
  end
end

function object:setImage(filename)
-- Set Image and calculate width and height
  self.img = love.graphics.newImage(filename)
  self.width = self.img:getWidth()/myMap.tileSize
  self.height = self.img:getHeight()/myMap.tileSize
end

function object:draw()
  if self.img then
    love.graphics.draw(self.img,math.floor(self.x*myMap.tileSize),math.floor(self.y*myMap.tileSize))
  end
end

function object:kill()
  self.dead = true
end

function object:setAcceleration(dt)
-- apply acceleration to object, generically, this is none
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
    if math.ceil(self.x+self.width) ~= math.ceil(self.newX+self.width) then
      -- Kollision in neuen Feldern?
      if myMap.collision[math.ceil(self.newX+self.width-1)] and
      (myMap.collision[math.floor(self.newX+self.width)][math.floor(self.y)] or
        myMap.collision[math.floor(self.newX+self.width)][math.ceil(self.y+self.height)-1]) then
        self.newX = math.floor(self.newX+self.width)-self.width
        self.collisionResult = true
      end
    end
  elseif self.vx < 0 then -- Bewegung nach links
    -- Eckpunkte wechseln Zelle?
    if math.floor(self.x) ~= math.floor(self.newX) then
      if myMap.collision[math.floor(self.newX)] and
      (myMap.collision[math.floor(self.newX)][math.floor(self.y)] or
       myMap.collision[math.floor(self.newX)][math.ceil(self.y+self.height)-1]) then
        self.newX = math.floor(self.newX+1*self.width)
        self.collisionResult = true
      end
    end
  end
  
  -- Vertical Movement
  if self.vy < 0 then -- rising
    if math.floor(self.y) ~= math.floor(self.newY) then
			verticalChange = true
      if (myMap.collision[math.floor(self.newX)] and
          myMap.collision[math.floor(self.newX)][math.floor(self.newY)])
          or
         (myMap.collision[math.ceil(self.newX+self.width)-1] and
          myMap.collision[math.ceil(self.newX+self.width)-1][math.floor(self.newY)]) then
        self.newY = math.floor(self.newY+1)
        self.collisionResult = true
      end
    end
    
  elseif self.vy > 0 then -- falling
    if math.ceil(self.y+self.height) ~= math.ceil(self.newY+self.height) then
			verticalChange = true
      if ( myMap.collision[math.floor(self.newX)] and 
        myMap.collision[math.floor(self.newX)][math.floor(self.newY+self.height)])  or
        (myMap.collision[math.ceil(self.newX+self.width)-1] and 
        myMap.collision[math.ceil(self.newX+self.width)-1][math.floor(self.newY+self.height)]) then
        self.newY = math.floor(self.newY+self.height)-self.height        
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
