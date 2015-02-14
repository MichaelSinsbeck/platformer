local Runner = object:New({
	tag = 'Runner',
	category = "Enemies",
  maxSpeed = 19,
  acc = 25,--17,
  xSensing = 20, --how far can he see?
  ySensing = 7,
  mouthRadius = 7,
  zoomState = 0,
  vis = {
		Visualizer:New('runnerSleep',{frame = 3}),
		Visualizer:New('runnerMouth',{relY = 0.2}),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  },
  marginx = 0.7,
  marginy = 0.6,
  isInEditor = true,
  anchorRadii = {.525,.5},
})

function Runner:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  

  if p.visible and not p.dead and math.abs(dx) < self.xSensing and math.abs(dy) < self.ySensing then
    self.vis[2].sy = math.max(0,1-math.sqrt(dx*dx+dy*dy)/self.mouthRadius)
		self.vis[2].sx = self.vis[2].sy
  
		-- run towards player
		if dx > 0 then
			self.vx = self.vx - self.acc * dt
			self:setAnim('runnerLeft')
		elseif dx < 0 then
			self.vx = self.vx + self.acc * dt
			self:setAnim('runnerRight')
		else
		self:setAnim('runnerWait')
		end
	else
	  -- stop running
	  self.vis[2].sx, self.vis[2].sy = 0,0
	  if self.vx > self.acc * dt then
	    self.vx = self.vx - self.acc * dt
	  elseif self.vx < - self.acc * dt then
	    self.vx = self.vx + self.acc * dt
	  else
	    self.vx = 0
	  end
	  self:setAnim('runnerSleep')
	end
  
  if self.vx < -self.maxSpeed then
    self.vx = -self.maxSpeed
  end
  if self.vx > self.maxSpeed then
    self.vx = self.maxSpeed
  end
  
  self.vy = self.vy + gravity * dt
	self.oldCollisionResult = self.collisionResult
end

function Runner:postStep(dt)
  -- show crosshairs
  if self.anchorRadii then
		if self.isCurrentTarget then
			self.zoomState = math.min(self.zoomState + 5*dt,1)
		else
			self.zoomState = math.max(self.zoomState - 7*dt,0)
		end
		local s = utility.easingOvershoot(self.zoomState)

		self.vis[3].angle = self.vis[3].angle + dt
		self.vis[3].sx = s
		self.vis[3].sy = s 
	end

  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p:kill()
    levelEnd:addDeath("death_runner")
    objectClasses.Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end

  local l0,r0,u0,d0 = utility.directions(self.oldCollisionResult)
  local l1,r1,u1,d1 = utility.directions(self.collisionResult)
  if l1 and not l0 then
		self:playSound('runnerCollide')		
  end
  if r1 and not r0 then
		self:playSound('runnerCollide')		
	end
  if d1 and not d0 then
		self:playSound('runnerLand')		
  end
	self:haveSound('runnerLong')
end

function Runner:onKill()
	if p.anchor and p.anchor.target == self then
		spriteEngine:DoAll('disconnect')
	end
end

return Runner
