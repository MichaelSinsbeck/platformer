
Player = object:New({
	tag = 'player',
  x = 0,
  y = 0,
  vx = 0,
  vy = 0,
  axStand = 35, -- acceleration, when button is pressed
  axFly = 35,
  axLine = 10,
  fxStand = 25, -- friction, natural stopping when no button is pressed
  fxFly = 12,
  fxLine = .1,
  status = 'fly',
  walkSpeed = 13,
  jumpSpeed = -13,
  walljumpSpeedx1 = 9,
  walljumpSpeedx2 = 13,
  walljumpSpeedy = -13,
  wallgravity = 20,
  walltime = 0,
  releasetime = .15,
  unjumpSpeed = 6,
  jumpsLeft = 0,
  maxJumps = 1, -- number of jumps, put 1 for normal and 2 for doublejump
  canGlide = true,
  glideSpeed = 1.5,
  glideAcc = 60, -- should be larger than gravity
  animation = 'whiteStand',
  marginx = 0.3,
  marginy = 0.6,
  linePointx = 0,
  linePointy = -0.55,
  bandana = 'white',
  poffTimer = 0,
  })

function Player:jump()
	game:checkControls()
  if self.status == 'stand' then
    self.status = 'fly'
    self.vy = self.jumpSpeed
  elseif self.status == 'fly' and self.jumpsLeft > 0 then
    self.vy = self.jumpSpeed
    self.jumpsLeft = self.jumpsLeft - 1
  elseif self.status == 'leftwall' then
    self.vy = self.walljumpSpeedy
			if game.isLeft then
				self.vx = self.walljumpSpeedx1
				self:flip(true)
			else
				self.vx = self.walljumpSpeedx2
				self:flip(false)
			end
    self.status = 'fly'
  elseif self.status == 'rightwall' then
    self.vy = self.walljumpSpeedy
			if game.isRight then
				self.vx = -self.walljumpSpeedx1
				self:flip(false)
			else
				self.vx = -self.walljumpSpeedx2
				self:flip(true)
			end
    self.status = 'fly'
  elseif self.status == 'online' then
    if game.isDown then --fall
			self.status = 'fly'
			self.line = nil
    else --jump up
			self.status = 'fly'
			self.vy = self.jumpSpeed
			self.line = nil
		end
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
	--[[self.poffTimer = self.poffTimer + dt
	if self.poffTimer > 0.18 then
		local newPoff = Poff:New({x=self.x,y=self.y+self.semiheight})
		spriteEngine:insert(newPoff)
		self.poffTimer = self.poffTimer - 0.18
	end--]]
	
  -- read controls
	game:checkControls()

  -- Acceleration down
  if self.status == 'fly' or self.status == 'online' then
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
	elseif self.status == 'online' then
		ax = self.axLine
		fx = self.fxLine
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
	if self.status == 'stand' or self.status == 'fly' or self.status == 'online' then
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
	--[[elseif self.status == 'online' then
		if axControl > 0 and self.vx < self.walkSpeed then -- Acceleration to the right
			self.vx = math.min(self.vx+axControl*dt,self.walkSpeed)
		elseif axControl < 0 and self.vx > -self.walkSpeed then -- Acceleration to the left
			self.vx = math.max(self.vx+axControl*dt,-self.walkSpeed)
		end--]]
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
  if self.bandana == 'blue' and game.isAction then
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

	if self.status == 'online' then
		local dx,dy = self.newX+p.linePointx-self.line.x, self.newY+p.linePointy-self.line.y
		local position = dx*self.line.ex+dy*self.line.ey -- scalarproduct
		
		if position > 0 and position < self.line.length then
			self.newX = self.line.x+self.line.ex*position-self.linePointx
			self.newY = self.line.y+self.line.ey*position-self.linePointy
		else
			self.status = 'fly'
			self.line = nil
		end
	end


  -- Horizontal Movement
  -- Remember about floor and ceil:
  -- When upper bound is checked, use ceil (and maybe -1)
  -- When lower bound is checked, use floor
  if self.vx > 0 then -- Bewegung nach rechts
    -- haben die rechten Eckpunkte die Zelle gewechselt?
    if math.ceil(self.x+self.semiwidth) ~= math.ceil(self.newX+self.semiwidth) then
      -- Kollision in neuen Feldern?
			if myMap:collisionTest(math.ceil(self.newX+self.semiwidth-1),math.floor(self.y-self.semiheight),'right',self.tag) or
				 myMap:collisionTest(math.ceil(self.newX+self.semiwidth-1),math.ceil(self.y+self.semiheight)-1,'right',self.tag) then
        self.newX = math.floor(self.newX+self.semiwidth)-self.semiwidth
				self.status = 'rightwall'
      end
    end
  elseif self.vx < 0 then -- Bewegung nach links
    -- Eckpunkte wechseln Zelle?
    if math.floor(self.x-self.semiwidth) ~= math.floor(self.newX-self.semiwidth) then
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.floor(self.y-self.semiheight),'right',self.tag) or
				 myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.ceil(self.y+self.semiheight)-1,'right',self.tag) then
        self.newX = math.ceil(self.newX-self.semiwidth)+self.semiwidth
        self.status = 'leftwall'
      end
    end
  end
  
  
  -- vertical movements
  local verticalChange = false -- Flag, if player changed tile vertically
  
  if self.vy < 0 then -- rising
    if math.floor(self.y-self.semiheight) ~= math.floor(self.newY-self.semiheight) then
			verticalChange = true
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.floor(self.newY-self.semiheight),'up',self.tag) or
				 myMap:collisionTest(math.ceil(self.newX+self.semiwidth)-1,math.floor(self.newY-self.semiheight),'up',self.tag) then
        self.newY = math.ceil(self.newY-self.semiheight)+self.semiheight
        verticalChange = false
      end
    end
    
  elseif self.vy > 0 then -- falling
    if math.ceil(self.y+self.semiheight) ~= math.ceil(self.newY+self.semiheight) then
			verticalChange = true
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.ceil(self.newY+self.semiheight)-1,'down',self.tag) or
				 myMap:collisionTest(math.ceil(self.newX+self.semiwidth)-1,math.ceil(self.newY+self.semiheight)-1,'down',self.tag) then
        self.newY = math.floor(self.newY+self.semiheight)-self.semiheight        
        self.status = 'stand'
        verticalChange = false
      end
    end
  end  

  -- if vertically the player changes the tile, then possibly
  -- he sticks on the wall.
  -- check: After vertical movement, is the wall still there?
	if verticalChange and (self.status == 'leftwall' or (self.status == 'fly' and self.newX-self.semiwidth == math.floor(self.newX-self.semiwidth) )) then
		--self.status = 'fly'
		if myMap:collisionTest(math.floor(self.newX-self.semiwidth)-1,math.floor(self.newY-self.semiheight),'left',self.tag) or
			 myMap:collisionTest(math.floor(self.newX-self.semiwidth)-1,math.ceil(self.newY+self.semiheight)-1,'left',self.tag) then
			self.status = 'leftwall'
		else
		  self.status = 'fly'
		end
	elseif verticalChange and
			(self.status == 'rightwall' or (self.status == 'fly' and (self.newX+self.semiwidth)==math.floor(self.newX+self.semiwidth) )) then
		self.status = 'fly'
		if myMap:collisionTest(math.floor(self.newX+self.semiwidth),math.floor(self.newY-self.semiheight),'right',self.tag) or
			 myMap:collisionTest(math.floor(self.newX+self.semiwidth),math.ceil(self.newY+self.semiheight)-1,'right',self.tag) then
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
  
  -- Set animation
  -- Flip character left/right, if left or right is pressed
	local control = 0
	if game.isLeft then control = control -1 end
	if game.isRight then control = control +1 end  	
	if control > 0 then self:flip(false) end
	if control < 0 then self:flip(true) end
  
  if self.bandana == 'green' and game.isAction then
    self:setAnim('greenInvisible')
  else  
		if self.status == 'fly' then
			if self.vy < 0 then
				self:setAnim(self.bandana..'Jump')
			elseif game.isAction and self.bandana == 'blue' then
				self:setAnim(self.bandana..'Gliding')
			else 
				self:setAnim(self.bandana..'Fall')
			end
		elseif self.status == 'stand' then
			if control == 0 and self.vx == 0 then
				self:setAnim(self.bandana..'Stand')
			elseif control*self.vx < 0 then
				self:setAnim(self.bandana..'Sliding')
			else
				self:setAnim(self.bandana..'Run')
			end
		elseif self.status == 'rightwall' then
			self:setAnim(self.bandana..'Wall')
			self:flip(false)
		elseif self.status == 'leftwall' then
			self:setAnim(self.bandana..'Wall')
			self:flip(true)
		elseif self.status == 'online' then
			self:setAnim(self.bandana..'Line')
		end
  end
end

function Player:wincheck()
  local x1 = math.floor(self.x-self.semiwidth)
  local x2 = math.ceil(self.x+self.semiwidth)-1
  local y1 = math.floor(self.y-self.semiheight)
  local y2 = math.ceil(self.y+self.semiheight)-1
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
