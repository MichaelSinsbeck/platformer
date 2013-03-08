Player = {
  x = 0,
  y = 0,
  vx = 0,
  vy = 0,
  --ax = 100,
  axStand = 100, -- acceleration, when button is pressed
  axFly = 100,
  fxStand = 20, -- friction, natural stopping when no button is pressed
  fxFly = 10,
  height = .5,
  width = .5,
  status = 'fly',
  walkSpeed = 15,
  jumpSpeed = -20,
  walljumpSpeedx = 20,
  walljumpSpeedy = -20,
  wallgravity = 30,
  unjumpSpeed = 12,
  jumpsLeft = 0,
  maxJumps = 1, -- number of jumps, put 1 for normal and 2 for doublejump
  canGlide = true,
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
	-- Obtain Input (independent of actual setup)
	local isLeft,isRight,isJump,isGlide = game.checkControls()

	local ax,fx = 0,0
	-- Determine acceleration and friction
	if self.status == 'stand' then
	  ax = self.axStand
	  fx = self.fxStand
	elseif self.status == 'fly' or self.status == 'leftwall' or self.status == 'rightwall' then
		ax = self.axFly
		fx = self.fxFly
	end

	-- Determine desired acceleration
	local axControl = 0
	if isLeft then
		axControl = axControl - ax
	end
	if isRight then
		axControl = axControl + ax
	end
	
	-- Accelerate if player is not faster than maximum speed anyway
	if self.status == 'stand' or self.status == 'fly' then
		if axControl > 0 and self.vx < self.walkSpeed then -- Acceleration to the right
			self.vx = math.min(self.vx+axControl*dt,self.walkSpeed)
		elseif axControl < 0 and self.vx > -self.walkSpeed then -- Acceleration to the left
			self.vx = math.max(self.vx+axControl*dt,-self.walkSpeed)
		elseif axControl == 0 then -- No direction button pressed -- slow down according to friction
			if self.vx > 0 then -- movement to the right
				self.vx = math.max(0,self.vx-fx*dt)
			elseif self.vx < 0 then -- movement to the left
				self.vx = math.min(0,self.vx+fx*dt)
			end
		end
	elseif self.status == 'leftwall'  and axControl < 0 then
			-- Movement to the left is possible
			self.vx = math.max(axControl*dt,-self.walkSpeed)
			self.status = 'fly'
	elseif self.status == 'rightwall' and axControl > 0 then
			-- Movement to the right is possible
			self.vx = math.min(self.vx+axControl*dt,self.walkSpeed)
			self.status = 'fly'
	end
	
  -- Horizontale Bewegung und Kollisionskontrolle
  local newX = self.x + self.vx*dt
  
  if self.vx > 0 then -- Bewegung nach rechts
    -- haben die rechten Eckpunkte die Zelle gewechselt?
    if math.floor(self.x+self.width*0.99) ~= math.floor(newX+self.width*1) then
      -- Kollision in neuen Feldern?
      if myMap.collision[math.floor(newX+self.width*1)] and
      (myMap.collision[math.floor(newX+self.width*1)][math.floor(self.y)] or
        myMap.collision[math.floor(newX+self.width*1)][math.floor(self.y+0.99*self.height)]) then
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
       myMap.collision[math.floor(newX)][math.floor(self.y+0.99*self.height)]) then
        newX = math.floor(newX+1*self.width)
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
  if self.canGlide and isGlide then
    if self.vy > self.glideSpeed then
      self.vy = self.vy - self.glideAcc*dt
      if self.vy < self.glideSpeed then
        self.vy = self.glideSpeed
      end
    end
  end
  
  if self.status == 'stand' then self.status = 'fly'  end
  
  -- Flag checks if in vertical direction the player moves into a
  -- new tile
  local verticalChange = false
  
  local newY = self.y + self.vy*dt
  if self.vy < 0 then -- rising
    if math.floor(self.y) ~= math.floor(newY) then
			verticalChange = true
      if (myMap.collision[math.floor(self.x)] and
          myMap.collision[math.floor(self.x)][math.floor(newY)])
          or
         (myMap.collision[math.floor(self.x+self.width*0.99)] and
          myMap.collision[math.floor(self.x+self.width*0.99)][math.floor(newY)]) then
        newY = math.floor(newY+1)
        self.vy = math.max(self.vy,0)
        verticalChange = false
      end
    end
    
  elseif self.vy > 0 then -- falling
    if math.floor(self.y+self.height*0.99) ~= math.floor(newY+self.height*1) then
			verticalChange = true
      if ( myMap.collision[math.floor(self.x)] and 
        myMap.collision[math.floor(self.x)][math.floor(newY+self.height*1)])  or
        (myMap.collision[math.floor(self.x+self.width*0.99)] and 
        myMap.collision[math.floor(self.x+self.width*0.99)][math.floor(newY+self.height*1)]) then
        newY = math.floor(newY+self.height*1)-self.height        
        self.vy = math.min(self.vy,0)
        self.status = 'stand'
        verticalChange = false
      end
    end
  end
  self.y = newY

  -- if vertically the player changes the tile, then possibly
  -- he sticks on the wall.
  -- check: After vertical movement, is the wall still there?
	if verticalChange and (self.status == 'leftwall' or (self.status == 'fly' and math.abs(self.x-math.floor(self.x))<0.01 )) then
		self.status = 'fly'
		if myMap.collision[math.floor(self.x)-1] and
				(myMap.collision[math.floor(self.x-1)][math.floor(self.y)] or
				myMap.collision[math.floor(newX)][math.floor(self.y+0.99*self.height)]) then
			self.status = 'leftwall'
		end
	elseif verticalChange and
			(self.status == 'rightwall' or (self.status == 'fly' and math.abs((self.x+self.width)-math.floor(self.x+self.width))<0.01 )) then
		self.status = 'fly'
		if myMap.collision[math.floor(self.x)+1] and
				(myMap.collision[math.floor(self.x)+1][math.floor(self.y)] or
				myMap.collision[math.floor(self.x)+1][math.floor(self.y+0.99*self.height)]) then
			self.status = 'rightwall'

		end
	end
  
  if self.status == 'stand' or self.status == 'leftwall' or self.status == 'rightwall' then
    self.jumpsLeft = self.maxJumps - 1
  end
end

return Player
