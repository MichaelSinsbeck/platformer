Player = object:New({
  x = 0,
  y = 0,
  vx = 0,
  vy = 0,
  --ax = 100,
  axStand = 100, -- acceleration, when button is pressed
  axFly = 100,
  fxStand = 50, -- friction, natural stopping when no button is pressed
  fxFly = 10,
  height = .5,
  width = .5,
  status = 'fly',
  walkSpeed = 15,
  jumpSpeed = -20,
  walljumpSpeedx = 20,
  walljumpSpeedy = -20,
  wallgravity = 30,
  walltime = 0,
  releasetime = .15,
  unjumpSpeed = 12,
  jumpsLeft = 0,
  maxJumps = 1, -- number of jumps, put 1 for normal and 2 for doublejump
  canGlide = true,
  glideSpeed = 3,
  glideAcc = 120, -- should be larger than gravity
  img = love.graphics.newImage('block3.png')})

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

function Player:setAcceleration(dt)
  -- read controls
	game:checkControls()

  -- Acceleration down
  if self.status == 'fly' then
		self.vy = self.vy + gravity*dt
	else
		self.vy = self.vy + self.wallgravity*dt
	end

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
	if game.isLeft then
		axControl = axControl - ax
	end
	if game.isRight then
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
	
  if self.status == 'stand' then self.status = 'fly'  end	
	
  -- Gliding
  if self.canGlide and game.isGlide then
    if self.vy > self.glideSpeed then
      self.vy = self.vy - self.glideAcc*dt
      if self.vy < self.glideSpeed then
        self.vy = self.glideSpeed
      end
    end
  end	

end



function Player:collision(dt)
  local laststatus = self.status

  -- Horizontal Movement
  -- Remember about floor and ceil:
  -- When upper bound is checked, use ceil (and maybe -1)
  -- When lower bound is checked, use floor
  if self.vx > 0 then -- Bewegung nach rechts
    -- haben die rechten Eckpunkte die Zelle gewechselt?
    if math.ceil(self.x+self.width) ~= math.ceil(self.newX+self.width) then
      -- Kollision in neuen Feldern?
      if myMap.collision[math.ceil(self.newX+self.width-1)] and
      (myMap.collision[math.floor(self.newX+self.width)][math.floor(self.y)] or
        myMap.collision[math.floor(self.newX+self.width)][math.ceil(self.y+self.height)-1]) then
        self.newX = math.floor(self.newX+self.width)-self.width
				self.status = 'rightwall'
      end
    end
  elseif self.vx < 0 then -- Bewegung nach links
    -- Eckpunkte wechseln Zelle?
    if math.floor(self.x) ~= math.floor(self.newX) then
      if myMap.collision[math.floor(self.newX)] and
      (myMap.collision[math.floor(self.newX)][math.floor(self.y)] or
       myMap.collision[math.floor(self.newX)][math.ceil(self.y+self.height)-1]) then
        self.newX = math.floor(self.newX+1*self.width)
        self.status = 'leftwall'
      end
    end
  end
  
  
  -- vertical movements
  local verticalChange = false -- Flag, if player changed tile vertically
  
  if self.vy < 0 then -- rising
    if math.floor(self.y) ~= math.floor(self.newY) then
			verticalChange = true
      if (myMap.collision[math.floor(self.newX)] and
          myMap.collision[math.floor(self.newX)][math.floor(self.newY)])
          or
         (myMap.collision[math.ceil(self.newX+self.width)-1] and
          myMap.collision[math.ceil(self.newX+self.width)-1][math.floor(self.newY)]) then
        self.newY = math.floor(self.newY+1)
        verticalChange = false
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
        self.status = 'stand'
        verticalChange = false
      end
    end
  end  

  -- if vertically the player changes the tile, then possibly
  -- he sticks on the wall.
  -- check: After vertical movement, is the wall still there?
	if verticalChange and (self.status == 'leftwall' or (self.status == 'fly' and self.newX == math.floor(self.newX) )) then
		--self.status = 'fly'
		if myMap.collision[math.floor(self.newX)-1] and
				(myMap.collision[math.floor(self.newX-1)][math.floor(self.newY)] or
				myMap.collision[math.floor(self.newX-1)][math.ceil(self.newY+self.height)-1]) then
			self.status = 'leftwall'
		else
		  self.status = 'fly'
		end
	elseif verticalChange and
			(self.status == 'rightwall' or (self.status == 'fly' and (self.newX+self.width)==math.floor(self.newX+self.width) )) then
		self.status = 'fly'
		if myMap.collision[math.floor(self.newX)+1] and
				(myMap.collision[math.floor(self.newX)+1][math.floor(self.newY)] or
				myMap.collision[math.floor(self.newX)+1][math.ceil(self.newY+1*self.height)-1]) then
			self.status = 'rightwall'
	  else
	    self.status = 'fly'
		end
	end
  
  -- Extra treatment for wall stuff
  if self.status == 'leftwall' then
    if game.isRight then
			if laststatus == 'fly' then self.status = 'fly' end
			if laststatus == 'leftwall' then self.walltime = self.walltime+dt end
	  else
	    self.walltime = 0
    end
  end
	if self.status == 'rightwall' then
    if game.isLeft then
			if laststatus == 'fly' then self.status = 'fly' end
			if laststatus == 'rightwall' then self.walltime = self.walltime+dt end
	  else
	    self.walltime = 0
    end
  end
  
  if self.walltime > self.releasetime then
    self.status = 'fly'
    self.walltime = 0
  end
  
  if self.status == 'stand' or self.status == 'leftwall' or self.status == 'rightwall' then
    self.jumpsLeft = self.maxJumps - 1
  end
end

function Player:wincheck()
  local x1 = math.floor(self.x)
  local x2 = math.ceil(self.x+self.width)-1
  local y1 = math.floor(self.y)
  local y2 = math.ceil(self.y+self.width)-1
  local x=0
  local y=0
  local winning = false
  for x =x1,x2 do
    for y = y1,y2 do
      if myMap.tile[x] and myMap.tile[x][y] and myMap.tile[x][y]==48 then
        winning = true
      end
    end
  end
  return winning
end