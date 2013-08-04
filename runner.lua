Runner = object:New({
	tag = 'runner',
  maxSpeed = 19,
  acc = 25,--17,
  xSensing = 20, --how far can he see?
  ySensing = 7,
  mouthRadius = 7,
  animation = 'runnerSleep',
  frame = 3,
  marginx = 0.7,
  marginy = 0.6,
  sonAnimation = 'runnerMouth',
  sonY = 0.2,
})

function Runner:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  

  if p.visible and not p.dead and math.abs(dx) < self.xSensing and math.abs(dy) < self.ySensing then
    self.sonSy = math.max(0,1-math.sqrt(dx*dx+dy*dy)/self.mouthRadius)
		self.sonSx = self.sonSy
  
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
	  self.sonSx, self.sonSy = 0,0
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
  
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p.dead = true
    Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end  
end
