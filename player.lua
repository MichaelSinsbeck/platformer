Player = {
  x = 0,
  y = 0,
  vx = 0,
  vy = 0,
  ax = 100,
  height = 1,
  width = 1,
  status = 'fly',
  walkSpeed = 15,
  jumpSpeed = -20,
  walljumpSpeedx = 20,
  walljumpSpeedy = -20,
  wallgravity = 30,
  unjumpSpeed = 12,
  jumpsLeft = 0,
  maxJumps = 1, -- number of jumps, put 1 for normal and 2 for doublejump
  canGlide = false,
  glideSpeed = 3,
  glideAcc = 120 -- should be larger than gravity
  }

function Player:New(input)
  local o = input or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Player:setImage(filename)
  self.img = love.graphics.newImage(filename)
  self.width = self.img:getWidth()/myMap.tileSize
  self.height = self.img:getHeight()/myMap.tileSize
end

function Player:draw()
  if self.img then
  love.graphics.draw(self.img,math.floor(self.x*myMap.tileSize),math.floor(self.y*myMap.tileSize))
  end
end

function Player:jump()
  if self.status == 'stand' then
    self.status = 'fly'
    self.vy = self.jumpSpeed
  elseif self.status == 'fly' and self.jumpsLeft > 0 then
    self.vy = self.jumpSpeed
    self.jumpsLeft = self.jumpsLeft - 1
  elseif self.status == 'leftwall' then
    self.vy = self.walljumpSpeedy
    self.vx = self.walljumpSpeedx
    self.status = 'fly'
  elseif self.status == 'rightwall' then
    self.vy = self.walljumpSpeedy
    self.vx = -self.walljumpSpeedx  
    self.status = 'fly'
  end
end

function Player:unjump()
	if self.status == 'fly' and self.vy < 0 then
		if self.vy < -self.unjumpSpeed then
			self.vy = self.vy + self.unjumpSpeed
		else
			self.vy = 0
		end
	end
	if (self.status == 'leftwall' or self.status == 'rightwall') and self.vy < 0 then
		if self.vy < -self.unjumpSpeed then
			self.vy = self.vy + self.unjumpSpeed
		else
			self.vy = 0
		end
	end
end

function Player:update(dt)
  self.tvx = 0 -- tvx is target velocity
  if love.keyboard.isDown('left') then
    self.tvx = self.tvx - self.walkSpeed
  end
  if love.keyboard.isDown('right') then
    self.tvx = self.tvx + self.walkSpeed
  end
  
  -- Acceleration in x direction
  -- approach target velocity with acceleration self.ax
  if self.status == 'stand' or self.status == 'fly' then
		local vxDiscrepancy = self.tvx-self.vx
		if vxDiscrepancy > self.ax*dt then
			self.vx = self.vx + self.ax*dt
		elseif vxDiscrepancy < -self.ax*dt then
			self.vx = self.vx - self.ax*dt
		else
			self.vx = self.tvx
		end
	elseif self.status == 'leftwall' then
		local vxDiscrepancy = self.tvx-self.vx	
	  if vxDiscrepancy < -self.ax*dt then
	    self.vx = self.vx - self.ax*dt
	    self.status = 'fly'
	  elseif vxDiscrepancy < 0 then
	    self.vx = self.tvx
			self.status = 'fly'
		end
	elseif self.status == 'rightwall' then
		local vxDiscrepancy = self.tvx-self.vx	
		if vxDiscrepancy > self.ax*dt then
	    self.vx = self.vx + self.ax*dt
	    self.status = 'fly'
	  elseif vxDiscrepancy > 0 then
	    self.vx = self.tvx
	    self.status = 'fly'	    
		end
	end
	


  -- Horizontale Bewegung und Kollisionskontrolle
  local newX = self.x + self.vx*dt
  
  if self.vx > 0 then -- Bewegung nach rechts
    -- haben die rechten Eckpunkte die Zelle gewechselt?
    if math.floor(self.x+self.width*0.99) ~= math.floor(newX+self.width*0.99) then
      -- Kollision in neuen Feldern?
      if myMap.collision[math.floor(newX+self.width)] and
      (myMap.collision[math.floor(newX+self.width*0.99)][math.floor(self.y)] or
        myMap.collision[math.floor(newX+self.width*0.99)][math.floor(self.y+0.99)]) then
        newX = math.floor(newX+self.width)-self.width
        self.vx = math.min(self.vx,0)
        self.status = 'rightwall'
      end
    end
  elseif self.vx < 0 then -- Bewegung nach links
    -- Eckpunkte wechseln Zelle?
    if math.floor(self.x) ~= math.floor(newX) then
      if myMap.collision[math.floor(newX)] and
      (myMap.collision[math.floor(newX)][math.floor(self.y)] or
       myMap.collision[math.floor(newX)][math.floor(self.y+0.99)]) then
        newX = math.floor(newX+1)
        self.vx = math.max(self.vx,0)
        self.status = 'leftwall'
      end
    end
  end  
  self.x = newX

	
	
  -- Acceleration down
  if self.status == 'stand' or self.status == 'fly' then
		self.vy = self.vy + gravity*dt
	else
		self.vy = self.vy + self.wallgravity*dt
	end
  
  -- Gliding
  if self.canGlide and love.keyboard.isDown('s') then
    if self.vy > self.glideSpeed then
      self.vy = self.vy - self.glideAcc*dt
      if self.vy < self.glideSpeed then
        self.vy = self.glideSpeed
      end
    end
  end
  
  if self.status == 'stand' then self.status = 'fly'  end
  
  local newY = self.y + self.vy*dt
  if self.vy < 0 then -- rising
    if math.floor(self.y) ~= math.floor(newY) then
      if (myMap.collision[math.floor(self.x)] and
          myMap.collision[math.floor(self.x)][math.floor(newY)])
          or
         (myMap.collision[math.floor(self.x+self.width*0.99)] and
          myMap.collision[math.floor(self.x+self.width*0.99)][math.floor(newY)]) then
        newY = math.floor(newY+1)
        self.vy = math.max(self.vy,0)
      end
    end
    
  elseif self.vy > 0 then -- falling
    if math.floor(self.y+self.height*0.99) ~= math.floor(newY+self.height*0.99) then
      if ( myMap.collision[math.floor(self.x)] and 
        myMap.collision[math.floor(self.x)][math.floor(newY+self.height*0.99)])  or
        (myMap.collision[math.floor(self.x+self.width*0.99)] and 
        myMap.collision[math.floor(self.x+self.width*0.99)][math.floor(newY+self.height*0.99)]) then
        newY = math.floor(newY+self.height*0.99)-1---self.height*0.99-1
        
        self.vy = math.min(self.vy,0)
        self.status = 'stand'
      end
    end
  end
  self.y = newY
  
  if self.status == 'stand' or self.status == 'leftwall' or self.status == 'rightwall' then
    self.jumpsLeft = self.maxJumps - 1
  end
end

return Player
