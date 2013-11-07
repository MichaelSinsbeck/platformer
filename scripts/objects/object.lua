require 'scripts/animationdb'
require 'scripts/visualizer'

object = {
tag = 'object',
x = 0,y = 0,
vx = 0, vy = 0,
newX = 0, newY = 0,
collisionResult = false,
flipped = false,
vis = {},
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
  
  if self.vis then
		if self.vis[1] then
			local name = AnimationDB.animation[self.vis[1].animation].source
			self.semiwidth = self.semiwidth or 0.5*AnimationDB.source[name].width/myMap.tileSize*self.marginx
			self.semiheight = self.semiheight or 0.5*AnimationDB.source[name].height/myMap.tileSize*self.marginy
		end
		
		for i = 1,#self.vis do
			if self.vis[i].animation and AnimationDB.animation[self.vis[i].animation] then
				local name = AnimationDB.animation[self.vis[i].animation].source
				self.vis[i].ox = self.vis[i].ox or 0.5*AnimationDB.source[name].width/Camera.scale
				self.vis[i].oy = self.vis[i].oy or 0.5*AnimationDB.source[name].height/Camera.scale		
			end
		end
	end
	self.semiwidth = self.semiwidth or 0.5
	self.semiheight = self.semiheight or 0.5
end

function object:draw()
	if self.tag == 'inputJump' then
	print("1")
	end
	if self.vis then
		for i = 1,#self.vis do
		
	if self.tag == 'inputJump' then
	print("\t", i, self.x, self.y)
	end
			self.vis[i]:draw(			
				(self.x*myMap.tileSize*Camera.zoom)/Camera.zoom,
				(self.y*myMap.tileSize*Camera.zoom)/Camera.zoom)
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
