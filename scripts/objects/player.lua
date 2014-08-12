local Player = object:New({
	tag = 'Player',
  isInEditor = true,
  unique = true,		-- only allow one per map
  x = 0,
  y = 0,
  vx = 0,
  vy = 0,
  z = 2, -- is displayed in front
  axStand = 35, -- acceleration, when button is pressed
  axFly = 35,
  axLine = 10,
  fxStand = 25, -- friction, natural stopping when no button is pressed
  fxFly = 12,
  fxLine = .1,
  status = 'fly',
  walkSpeedNormal = 13,
  jumpSpeedNormal = -13,
  walkSpeedWeak = 5,
  jumpSpeedWeak = -7.5,
  walljumpSpeedx1 = 9,
  walljumpSpeedx2 = 13,
  walljumpSpeedy = -13,
  wallgravity = 20,
  walltime = 0,
  releasetime = .15,
  unjumpSpeed = 6,
  jumpsLeft = 0,
  maxJumps = 1, -- number of jumps, put 1 for normal and 2 for doublejump
  dashDistance = 4, -- number of tiles to dash
  dashTimer = 0,
  dashDelay = 0.6,
  isGliding = false,
  glideSpeed = 1.5,--1.5,
  glideAcc = 44,--60, -- should be larger than gravity
  windMaxSpeed = -20,
	bungeeSpeed = 50, -- speed of rope shooting
  marginx = 0.3,
  marginy = 0.6,
  linePointx = 0,
  linePointy = -0.55,
  bandana = 'white',
  alpha = 255,
  poffTimer = 0,
  visible = true,
  canUnJump = false,
  nKeys = 0,
  hookAngle = -math.pi/4,

  prevAnim = "",	-- used for level statistics

  vis = {
		Visualizer:New('whiteStand'),
		Visualizer:New('targetline',{active = false})
  },
  properties = {
		canWalljump  = utility.newCycleProperty({true,false},{'true','false'}),
		canParachute = utility.newCycleProperty({true,false},{'true','false'}),
		canTeleport  = utility.newCycleProperty({true,false},{'true','false'}),
		canHook      = utility.newCycleProperty({true,false},{'true','false'}),
  },   
  })

function Player:applyOptions()
	if not editor.active then
		self:setBandana(Campaign.bandana)
	end
end

function Player:setBandana(color)

	local bandana2num = {blank=1,white=2,yellow=3,green=4,blue=5,red=6}
	local number = bandana2num[color]
	
	self.bandana = color	
	
	self.canWalljump = false
	self.canParachute= false
	self.Teleport    = false
	self.canHook     = false
	
	if number == 1 then --blank
	  self.jumpSpeed = Player.jumpSpeedWeak
	  self.walkSpeed = Player.walkSpeedWeak
	else -- white
		self.jumpSpeed = Player.jumpSpeedNormal
	  self.walkSpeed = Player.walkSpeedNormal
	  if number >= 3 then --yellow
			self.canWalljump = true
		end
		if number >= 4 then --green
			self.canParachute = true
		end
		if number >= 5 then --blue
			self.canTeleport   = true
		end
		if number >= 6 then --red
			self.canHook = true		
		end	  	  	  
	end
end


function Player:jump()
	game:checkControls()
  if self.status == 'stand' then
    self.status = 'fly'
    self.vy = self.jumpSpeed
    self.canUnJump = true
  elseif self.status == 'fly' and self.jumpsLeft > 0 then
    self.vy = self.jumpSpeed
    self.jumpsLeft = self.jumpsLeft - 1
    self.canUnJump = true
  elseif self.status == 'fly' and self.canParachute then
		self.isGliding = true
  elseif self.status == 'leftwall' then
    self.vy = self.walljumpSpeedy
    self.canUnJump = true
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
    self.canUnJump = true
			if game.isRight then
				self.vx = -self.walljumpSpeedx1
				self:flip(false)
			else
				self.vx = -self.walljumpSpeedx2
				self:flip(true)
			end
    self.status = 'fly'
  elseif self.status == 'online' then
		self.status = 'fly'
		self.vy = self.jumpSpeed
		self.line = nil
		self.canUnJump = true
  end
end

function Player:unjump()
	if self.canUnJump then
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
end

function Player:dash()
	if self.dashTimer > 0 or not self.canTeleport then
		return
	end
	-- determine direction
	game:checkControls()
	local direction = 0
	if game.isLeft then direction = direction - 1 end
	if game.isRight then direction = direction + 1 end
	if direction == 0 then direction = self.vis[1].sx end
		
	-- find new position
	local newX = self.x + self.dashDistance * direction
	
	-- Constraint to level bounds
	newX = math.max(newX,1+self.semiwidth)
	newX = math.min(newX,myMap.width+1-self.semiwidth)
	
	-- Check collision with map
	if myMap:collisionRectangleTest(newX,self.y,self.semiwidth,self.semiheight,self.tag) then
		if direction > 0 then
			newX = math.floor( newX+self.semiwidth)-self.semiwidth
		else
			newX = math.ceil ( newX-self.semiwidth)+self.semiwidth
		end
		
		local ok
		repeat
			if myMap:collisionRectangleTest(newX,self.y,self.semiwidth,self.semiheight,self.tag) then
				ok = false
				newX = newX - direction
			else
				ok = true
			end
		until ok
	end
	

	-- if position is different, generate smoke and teleport
	if self.x ~= newX then
		local ratio = (newX-self.x)/self.dashDistance
		local newSmoke = spriteFactory('Smoke',{x=self.x,y=self.y})
		spriteEngine:insert(newSmoke)
		self.vis[1].alpha = 0
		
		local newWoosh = spriteFactory('Woosh',{x=0.5*(self.x+newX),y=self.y})
		newWoosh.vis[1].sx = ratio
		newWoosh.vis[1].alpha = 150
		spriteEngine:insert(newWoosh)
		
		self.vis[1].alpha = 0
		
		self.x = newX
		self.status = 'fly'
		self.dashTimer = self.dashDelay
		
		if self.vx*direction < 0 then
			self.vx = 0
		end
	end
	
	-- disconnect from rope, if existant
	spriteEngine:DoAll('disconnect')

end

function Player:setAcceleration(dt)
  -- read controls
	game:checkControls()

	
	-- drop down from line
	if self.status == 'online' and game.isDown then
		self.status = 'fly'
		self.line = nil
	end
		
  -- Acceleration down
  if self.status == 'leftwall' or self.status == 'rightwall' then
		self.vy = self.vy + self.wallgravity * dt
	else
		self.vy = self.vy + gravity * dt
  end
	
  -- Gliding
  if not game.isJump then
		-- set back to false (setting to true is done in keypressed)
		self.isGliding = false
  end
  if self.status == 'fly' and self.isGliding then
		if self.vy > self.windMaxSpeed and
		   myMap.collision[math.floor(self.x)] and
		   myMap.collision[math.floor(self.x)][math.floor(self.y)] == 4 then --wind
			self.vy = self.vy - self.glideAcc*dt
			if self.vy < self.windMaxSpeed then
				self.vy = self.windMaxSpeed
			end
			self.canUnJump = false
		elseif self.vy > self.glideSpeed then
			self.vy = self.vy - self.glideAcc*dt
			self.canUnJump = false
			if self.vy < self.glideSpeed then
				self.vy = self.glideSpeed
			end
		end
  end		

	local ax,fx = 0,0
	-- Determine acceleration and friction
	if self.status == 'stand' then
	  ax = self.axStand
	  fx = self.fxStand
	elseif self.anchor then
		ax = self.axFly	  
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
	if self.status == 'fly' and self.anchor and self.anchor.y < self.y and self.anchor:relativeLength() < .3 then
		-- player is 'hanging' on grabbling hook, so only accelerate tangential
		local cosine = math.cos(self.vis[1].angle)
		local sine = math.sin(self.vis[1].angle)
		self.vx = self.vx + .5*axControl*cosine*dt*cosine
		self.vy = self.vy + .5*axControl*sine  *dt*cosine
	elseif self.status == 'stand' or self.status == 'fly' or self.status == 'online' then
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
	elseif self.status == 'rightwall' and axControl > 0 then
			-- Movement to the right is possible
			self.vx = math.min(self.vx+axControl*dt,self.walkSpeed)
	end
	
  if self.status == 'stand' and self.vy ~=0 then self.status = 'fly'  end	
  
  -- change rope length, if hooked
	if self.anchor then
		if game.isDown then
			self.anchor.length = math.min(self.anchor.length + 5*dt, self.anchor.maxLength)
		end
		if game.isUp then
			self.anchor.length = math.max(self.anchor.length - 5*dt, self.anchor.minLength)
		end
	end

end

function Player:collision(dt)
  local laststatus = self.status

	if self.anchor then
		local dx,dy = self.newX-self.anchor.x, self.newY-self.anchor.y
		local dist = math.sqrt(dx^2 + dy^2)
		local factor = self.anchor.length/dist
		if factor < 1 then
			self.newX = self.anchor.x + dx*(self.anchor.length/dist)
			self.newY = self.anchor.y + dy*(self.anchor.length/dist)
			
			-- player is pulled away from wall by rope
			if (self.status == 'leftwall' and dx*(factor-1) > 0) or
				 (self.status == 'rightwall' and dx*(factor-1) < 0) then
				self.status = 'fly'
			end
		end
		self.angle = math.atan2(-dx,dy)
	else
		self.angle = 0
	end
	
	-- velocity is only needed for determining sign, so /dt is omitted
	local vx = self.newX - self.x
	local vy = self.newY - self.y

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
  if vx > 0 then -- Bewegung nach rechts
    -- haben die rechten Eckpunkte die Zelle gewechselt?
    if math.ceil(self.x+self.semiwidth) ~= math.ceil(self.newX+self.semiwidth) then
      -- Kollision in neuen Feldern?
			if myMap:collisionTest(math.ceil(self.newX+self.semiwidth-1),math.floor(self.y-self.semiheight),'right',self.tag) or
				 myMap:collisionTest(math.ceil(self.newX+self.semiwidth-1),math.ceil(self.y+self.semiheight)-1,'right',self.tag) then
        self.newX = math.floor(self.newX+self.semiwidth)-self.semiwidth
				--if self.status ~= 'online' then 
					self.status = 'rightwall' 
				--end			
      end
    end
  elseif vx < 0 then -- Bewegung nach links
    -- Eckpunkte wechseln Zelle?
    if math.floor(self.x-self.semiwidth) ~= math.floor(self.newX-self.semiwidth) then
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.floor(self.y-self.semiheight),'left',self.tag) or
				 myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.ceil(self.y+self.semiheight)-1,'left',self.tag) then
        self.newX = math.ceil(self.newX-self.semiwidth)+self.semiwidth
        --if self.status ~= 'online' then
					self.status = 'leftwall'
				--end
      end
    end
  end
  
  
  -- vertical movements
  local verticalChange = false -- Flag, if player changed tile vertically
  
  if vy < 0 then -- rising
    if math.floor(self.y-self.semiheight) ~= math.floor(self.newY-self.semiheight) then
			verticalChange = true
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.floor(self.newY-self.semiheight),'up',self.tag) or
				 myMap:collisionTest(math.ceil(self.newX+self.semiwidth)-1,math.floor(self.newY-self.semiheight),'up',self.tag) then
        self.newY = math.ceil(self.newY-self.semiheight)+self.semiheight
        verticalChange = false
        if self.status == 'online' then
					self.status = 'fly'
					self.line = nil
        end
      end
    end
    
  elseif vy > 0 then -- falling
    if math.ceil(self.y+self.semiheight) ~= math.ceil(self.newY+self.semiheight) then
			verticalChange = true
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth),math.ceil(self.newY+self.semiheight)-1,'down',self.tag) or
				 myMap:collisionTest(math.ceil(self.newX+self.semiwidth)-1,math.ceil(self.newY+self.semiheight)-1,'down',self.tag) then
        self.newY = math.floor(self.newY+self.semiheight)-self.semiheight        
        verticalChange = false
        self.status = 'stand'
      end
    end
  end
  
  -- Attach to a wall, from every status but 'stand', if position is correct.
  if self.status ~= 'stand' and self.status ~= 'online' then
		if utility.isInteger(self.newX-self.semiwidth) then -- if aligned with the left
			if myMap:collisionTest(math.floor(self.newX-self.semiwidth)-1,math.floor(self.newY-self.semiheight),'left',self.tag) or
				 myMap:collisionTest(math.floor(self.newX-self.semiwidth)-1,math.ceil(self.newY+self.semiheight)-1,'left',self.tag) then
				self.status = 'leftwall'
			else
				self.status = 'fly'
			end
		elseif utility.isInteger(self.newX+self.semiwidth) then
			if myMap:collisionTest(math.floor(self.newX+self.semiwidth),math.floor(self.newY-self.semiheight),'right',self.tag) or
				 myMap:collisionTest(math.floor(self.newX+self.semiwidth),math.ceil(self.newY+self.semiheight)-1,'right',self.tag) then
				self.status = 'rightwall'
			else
				self.status = 'fly'
			end
		end
	end
	--[[
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
	end--]]
  
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
  
  if not self.canWalljump and (self.status == 'leftwall' or self.status == 'rightwall') then
		self.status = 'fly'
  end
  
  if self.status == 'stand' or self.status == 'leftwall' or self.status == 'rightwall' then
    self.jumpsLeft = self.maxJumps - 1
  end
  
  self.newX = math.min(math.max(self.newX,1+self.semiwidth),myMap.width+1-self.semiwidth)
	
	if self.status ~= 'online' then
		self.line = nil
	end
	
	-- correct rope length if shortening did not work (avoid unwanted snapping effects)
	if self.anchor and game.isUp then
		self.anchor.length = math.max(self.anchor.length, math.sqrt((self.x-self.anchor.x)^2+(self.y-self.anchor.y)^2))
	end
end

function Player:postStep(dt)

  self.vis[1].alpha = math.min(self.vis[1].alpha + 1000*dt,255)
  self.dashTimer = math.max(self.dashTimer-dt,0)
  
  -- Set animation
  -- Flip character left/right, if left or right is pressed  
  
	local control = 0
	if game.isLeft then control = control -1 end
	if game.isRight then control = control +1 end
	
	if not (self.status == 'fly' and self.anchor and self.anchor.y < self.y and self.anchor:relativeLength() < .3) then
		if control > 0 then self:flip(false) end
		if control < 0 then self:flip(true) end
	end
	
	self.vis[1].angle = 0
	local prefix = self.bandana
	if self.anchor then prefix = 'blank' end
	
	if self.status == 'fly' then
		if self.anchor and self.anchor:relativeLength() < .3 and self.anchor.y < self.y then
			local dx,dy = self.x-self.anchor.x,self.y-self.anchor.y
			if self.vis[1].animation ~= 'blankHooked' then
				self:setAnim('blankHooked')
				self:flip(dx>0)
			end
			self.vis[1].angle = math.atan2(-dx,dy)
		elseif self.isGliding then
			if self.vy > 0 or myMap.collision[math.floor(self.x)][math.floor(self.y)] == 4 then
				self:setAnim(prefix..'Gliding')
			else 
				self:setAnim(prefix..'Jump')
			end
		else
			if self.vy < 0 then
				if self.jumpsLeft == self.maxJumps - 1 then
					self:setAnim(prefix..'Jump')
				else
					self:setAnim(prefix..'DoubleJump')
				end
			else
				self:setAnim(prefix..'Fall')
			end
		end
	elseif self.status == 'stand' then
		if control == 0 and math.abs(self.vx) < .01 then
			self:setAnim(prefix..'Stand')
		elseif control*self.vx < 0 then
			if self.anchor and self.anchor:relativeLength() < .1 then
				self:setAnim(prefix..'Run')
			else
				self:setAnim(prefix..'Sliding')
			end
		elseif control == 0 then
			self:setAnim(prefix..'Walk',true)
		else
			self:setAnim(prefix..'Run')
		end
	elseif self.status == 'rightwall' then
		self:setAnim(prefix..'Wall')
		self:flip(false)
	elseif self.status == 'leftwall' then
		self:setAnim(prefix..'Wall')
		self:flip(true)
	elseif self.status == 'online' then
		if control == 0 then
			if self.vx == 0 then
				self:setAnim(prefix..'LineHang')
			else
				self:setAnim(prefix..'LineSlide')
			end
		else
			self:setAnim(prefix..'LineMove')
		end
	end

	-- Check for changes in statistics and record them
	-- for level-end-screen:
	levelEnd:registerVelocity( self.vx, self.vy)

	-- Get the name of the currently playing animation
	-- without the colour in the front. The string we're
	-- looking for always starts with an upper case letter,
	-- for example: "Stand" from "whiteStand"
	local animation = self:getAnim():match("%u.*")
	-- if this string has changed, then act on the change:
	if animation ~= self.prevAnim then
		-- record statistic if landed:
		if animation == "Jump" then
			levelEnd:registerJumpStart( self.x, self.y )
		elseif self.prevAnim == "Jump" then
			levelEnd:registerJumpPeak( self.x, self.y )
		end
		if self.prevAnim == "Fall" then
			levelEnd:registerJumpEnd( self.x, self.y )
		end
		if animation == "Wall" then
			levelEnd:registerWallHangStart()
		elseif self.prevAnim == "Wall" then
			levelEnd:registerWallHangEnd()
		end
		self.prevAnim = animation
	end
	if animation == "Stand" then
		levelEnd:registerIdle( dt )
	end
	if animation == "Run" or animation == "Walk" then
		levelEnd:registerWalkedDist( dt*math.abs(self.vx) )
	end

	if self.flipped then
		self.vis[1].sx = -1
	else
		self.vis[1].sx = 1
	end
	-- insert targetline if necessary
	if self.canHook and not self.anchor then
		self.vis[2].active = true
		self.vis[2].ox = - 5
		if game.isUp then 
			self.hookAngle	= math.max(self.hookAngle - 3*dt, -0.5*math.pi)
		end
		if game.isDown then
			self.hookAngle	= math.min(self.hookAngle + 3*dt, 0.5*math.pi)
		end
		if self.flipped then
			self.vis[2].angle = math.pi - self.hookAngle
		else
			self.vis[2].angle = self.hookAngle
		end
	else
		self.vis[2].active = false
	end
end

function Player:throwBungee()
	--game:checkControls()
	local vx = self.bungeeSpeed * math.cos(self.vis[2].angle)
	local vy = self.bungeeSpeed * math.sin(self.vis[2].angle)
	local newBungee = objectClasses.Bungee:New({x=self.x, y=self.y, vx=vx, vy=vy, vis = {Visualizer:New('bungee',{angle=self.vis[2].angle})} })
	spriteEngine:insert(newBungee)
	if self.status == 'online' then
		self.status = 'fly'
	end	
end

function Player:connect(anchor)
	self.anchor = anchor
	anchor.length = utility.pyth(self.x-anchor.x,self.y-anchor.y)+0.1
end

function Player:disconnect()
	if self.anchor then
		self.status = 'fly'
		self.canUnJump = false
		self.anchor = nil
	end
end

return Player
