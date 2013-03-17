object = {
x = 0,y = 0,
vx = 0, vy = 0,
newX = 0, newY = 0,
collisionResult = ''}

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
-- Check for collision in newX,newY and correct, if necessary
end

function object:step(dt)
-- After newX and newY are correct, apply step and set velocity accordingly.
  self.vx = (self.newX - self.x)/dt
  self.vy = (self.newY - self.y)/dt
  self.x = self.newX
  self.y = self.newY
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
  end
end
