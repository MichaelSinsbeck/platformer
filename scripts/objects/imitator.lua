local Imitator = object:New({
	tag = 'Imitator',
	category = "Enemies",
	--animation = 'imitatorStand',
  marginx = 0.3,
  marginy = 0.6,
  isInEditor = true,
  
	axStand = 48.5, --40,--35, -- acceleration, when button is pressed
  axFly = 48.5, --40,--35,
  fxStand = 34.6,--25, -- friction, natural stopping when no button is pressed
  fxFly = 16.6,--12,
  status = 'fly',
  walkSpeed = 18,--13,
  jumpSpeed = -13,
  unjumpSpeed = 6,
  zoomState = 0,
  vis = {
		Visualizer:New('imitatorStand'),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  },
	anchorRadii = {.3,.5} 
})

function Imitator:setAcceleration(dt)
	game:checkControls()
	
  -- Acceleration down

	self.vy = self.vy + gravity*dt

	local ax,fx = 0,0
	-- Determine acceleration and friction
	if self.status == 'stand' then
	  ax = self.axStand
	  fx = self.fxStand
	elseif self.status == 'fly' then
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
end

function Imitator:postStep(dt)
	if not p.dead and self:touchPlayer(dx,dy) then
    p:kill()
    levelEnd:addDeath("death_imitator")
    objectClasses.Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end  
	if self.collisionResult >= 8 or self.vy == 0 then
		self.status = 'stand'
	else
		self.status = 'fly'
	end
	
	local control = 0
	if game.isLeft then control = control -1 end
	if game.isRight then control = control +1 end  	
	if control > 0 then self:flip(false) end
	if control < 0 then self:flip(true) end
	if self.flipped then self.vis[1].sx = -1 else self.vis[1].sx = 1 end
	
	if self.status == 'fly' then
		if self.vy < 0 then
			self:setAnim('imitatorJump')
		else 
			self:setAnim('imitatorFall')
		end
	elseif self.status == 'stand' then
		if control == 0 and self.vx == 0 then
			self:setAnim('imitatorStand')
		elseif control*self.vx < 0 then
			self:setAnim('imitatorSliding')
		elseif control == 0 then
			self:setAnim('imitatorWalk',true)
		else
			self:setAnim('imitatorRun')
		end
	end
	
	  -- show crosshairs
  if self.anchorRadii then
		if self.isCurrentTarget then
			self.zoomState = math.min(self.zoomState + 5*dt,1)
		else
			self.zoomState = math.max(self.zoomState - 7*dt,0)
		end
		local s = utility.easingOvershoot(self.zoomState)

		self.vis[2].angle = self.vis[2].angle + dt
		self.vis[2].sx = s
		self.vis[2].sy = s 
	end
	
end

function Imitator:jump()
	game:checkControls()
  if self.status == 'stand' then
    self.status = 'fly'
    self.vy = self.jumpSpeed
  end
end

function Imitator:unjump()
	if self.status == 'fly' and self.vy < 0 then
		if self.vy < -self.unjumpSpeed then
			self.vy = self.vy + self.unjumpSpeed
		else
			self.vy = 0
		end
	end
end

function Imitator:onKill()
	if p.anchor and p.anchor.target == self then
		spriteEngine:DoAll('disconnect')
	end
end

return Imitator
