require 'scripts/animationdb'
require 'scripts/visualizer'

local object = {
tag = 'object',
x = 0,y = 0,
vx = 0, vy = 0,
newX = 0, newY = 0,
z = 0,
collisionResult = 0,
flipped = false,
vis = {},
category = "Misc",
}
-- ox and oy are the coordinates of the image center
-- semiwidth and semiheight define the hitbox of the object

function object:New(input)
	local input = input or {}
  local o = input or {}

	-- copy vis table if not a new one is provided
  if not input.vis and self.vis then
    o.vis = {}
		for i = 1,#self.vis do
			o.vis[i]= self.vis[i]:copy()
		end
	end
	
	setmetatable(o, self)
	self.__index = self
	return o
end

function object:init()
	-- do whatever needs to be done to initialize the object
  -- set height and width of hitbox, if not done already
  self.marginx = self.marginx or 1
  self.marginy = self.marginy or 1
  
  --self.width, self.height = 0,0

  if self.vis then
		if self.vis[1] then
			--self.width, self.height = self.vis[1]:getSize()

			local name = AnimationDB.animation[self.vis[1].animation].source
			self.semiwidth = self.semiwidth or 0.5*AnimationDB.source[name].width/(Camera.scale*8)*self.marginx
			self.semiheight = self.semiheight or 0.5*AnimationDB.source[name].height/(Camera.scale*8)*self.marginy
		end
		
		for i = 1,#self.vis do
			self.vis[i]:init()
		end
	end
	if self.preview then
		self.preview:init()
	end
	self.semiwidth = self.semiwidth or 0.5
	self.semiheight = self.semiheight or 0.5
	
	-- copy values from properties to self variables, then applyOptions
	-- warning: If any parent class has a variable set already, then it will
	--          not be overwritten.
	if self.properties then
		for k,prop in pairs(self.properties) do
			if self[k] == nil then
				self[k] = prop.values[prop.default]
			end
		end
	end
	self:applyOptions()
end

function object:draw()
	if self.vis then
		for i = 1,#self.vis do
			self.vis[i]:draw(
				(self.x*8*Camera.scale*Camera.zoom)/Camera.zoom,
				(self.y*8*Camera.scale*Camera.zoom)/Camera.zoom, true )
		end
	end
end

function object:drawInEditor()
	if self.vis then
		for i = 1, #self.vis do
			self.vis[i]:draw( self.x, self.y, true )
		end
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

function object:collision()
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
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.floor(self.y-self.semiheight),'left',self.tag) or
				 myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.ceil(self.y+self.semiheight)-1,'left',self.tag) then    
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
	self:sendSound()
	
	if self.vis then
		for i = 1,#self.vis do
			self.vis[i]:update(dt)
		end	
	end
end

function object:touchPlayer(dx,dy)
  local dx = dx or self.x-p.x
  local dy = dy or self.y-p.y
  return math.abs(dx) < p.semiwidth+self.semiwidth and
     math.abs(dy) < p.semiheight+self.semiheight
end

function object:setAnim(name,continue,vis) -- Go to specified animation and reset, if not already there
	local vis = vis or 1

	if self.vis and self.vis[vis].animation ~= name then
	  self.vis[vis].animation = name
	  if not continue then
	    self:resetAnimation(vis)
	  end
	  self.vis[vis]:update(0)
	end
end

function object:getAnim( )
	if self.vis and self.vis[1] then
		return self.vis[1].animation
	end
end

function object:resetAnimation(vis)
	if vis then
		self.vis[vis]:reset()
		return
	end
	for i = 1,#self.vis do
		self.vis[i]:reset()
	end
end

function object:flip(flipped)
	self.flipped = flipped
end

-- change size of an object, avoiding collision problems
-- only works correctly if new size-parameters are <=0.5
function object:resize(newSemiwidth, newSemiheight)
-- width first
	if math.floor(self.x-newSemiwidth) < math.floor(self.x-self.semiwidth) then
		-- left edge changes tile
		if myMap:collisionTest(math.floor(self.x-newSemiwidth),math.floor(self.y-self.semiheight),'left',self.tag) or
			 myMap:collisionTest(math.floor(self.x-newSemiwidth),math.ceil(self.y+self.semiheight)-1,'left',self.tag) then
			-- would cause collision on the left
			self.x = math.floor(self.x-newSemiwidth) + 1 + newSemiwidth
		end
	elseif math.ceil(self.x+newSemiwidth) > math.ceil(self.x+self.semiwidth) then
		-- right edge changes tile
		if myMap:collisionTest(math.ceil(self.x+newSemiwidth-1),math.floor(self.y-self.semiheight),'right',self.tag) or
			 myMap:collisionTest(math.ceil(self.x+newSemiwidth-1),math.ceil(self.y+self.semiheight)-1,'right',self.tag) then
			-- would cause collision on the right
			self.x = math.ceil(self.x+newSemiwidth) - 1 - newSemiwidth
		end
	end
	self.semiwidth = newSemiwidth
-- height second
	if math.floor(self.y-newSemiheight) < math.floor(self.y-self.semiheight) then
		-- top edge changes tile
		if myMap:collisionTest(math.floor(self.x-self.semiwidth),math.floor(self.y-newSemiheight),'up',self.tag) or
			 myMap:collisionTest(math.ceil(self.x+self.semiwidth)-1,math.floor(self.y-newSemiheight),'up',self.tag) then
			-- would cause collision on the top
			self.y = math.floor(self.y-newSemiheight) +1 + newSemiheight
		end
	elseif math.ceil(self.y+newSemiheight) > math.ceil(self.y+self.semiheight) then
		-- bottom edge changes tile
		if myMap:collisionTest(math.floor(self.x-self.semiwidth),math.ceil(self.y+newSemiheight)-1,'down',self.tag) or
			 myMap:collisionTest(math.ceil(self.x+self.semiwidth)-1,math.ceil(self.y+newSemiheight)-1,'down',self.tag) then
			-- would cause collision on the bottom
			self.y = math.ceil(self.y+newSemiheight) - 1 - newSemiheight
		end
	end
	self.semiheight = newSemiheight
end

function object:applyOptions()
end

------------------------------------
-- Editor related functions:
------------------------------------
--[[
function object:startDragging( x, y )
	self.dragX = self.x - x
	self.dragY = self.y - y
end

function object:drag( x, y )
	self.x = self.dragX + x
	self.y = self.dragY + y
end

function object:checkCollision( x, y )
	return x >= self.x and y >= self.y and
		x <= self.x + self.width and
		y <= self.y + self.height
end]]

--[[function object:addProperty( name, initialValue, onChangeEvent )
	self.properties[name] = {
		val = initialValua,
		event = onChangeEvent,
	}
end]]

function object:setProperty( name, value )
	-- convert value to number, if it is one
	if tonumber(value) then value = tonumber(value) end
	
	if self[name] ~= nil then
		self[name] = value
	end
end

function object:getImageSize()
	if self.vis then
		return self.vis[1]:getSize()
	else
		return self.semiwidth*2*(Camera.scale*8), self.semiheight*2*(Camera.scale*8)
	end
end

function object:getPreviewSize()
	if self.preview then
		return self.preview:getSize()
	else
		local sizeX,sizeY = self:getImageSize()
		return self.marginx * sizeX, self.marginy * sizeY
	end
end

function object:playSound(event)
	Sound:playSpatial(event,self.x,self.y)
end

-- set the current long sound of the object
function object:haveSound(sound)
	self.newSound = sound
end
-- send the long sound of the object to the sound module
-- is done automatically in the update
function object:sendSound()
	if self.newSound then
		Sound:playLongSound(self.newSound,self)
		self.newSound = nil
		self.hasSound = true
	else
		if self.hasSound then
			Sound:stopLongSound(self)
			self.hasSound = false
		end
	end

end



return object
