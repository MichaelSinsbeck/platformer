Runner = object:New({
	tag = 'runner',
  maxSpeed = 19,
  acc = 25,--17,
  xSensing = 20, --how far can he see?
  ySensing = 7,
  img = love.graphics.newImage('images/runner.png'),
  marginx = 0.6,
  marginy = 0.6
})

function Runner:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  if math.abs(dx) < self.xSensing and math.abs(dy) < self.ySensing then
		-- run towards player
		if dx > 0 then
			self.vx = self.vx - self.acc * dt
		elseif dx < 0 then
			self.vx = self.vx + self.acc * dt
		end
	else
	  -- stop running
	  if self.vx > self.acc * dt then
	    self.vx = self.vx - self.acc * dt
	  elseif self.vx < - self.acc * dt then
	    self.vx = self.vx + self.acc * dt
	  else
	    self.vx = 0
	  end
	end
  
  if self.vx < -self.maxSpeed then
    self.vx = -self.maxSpeed
  end
  if self.vx > self.maxSpeed then
    self.vx = self.maxSpeed
  end
  
  self.vy = self.vy + gravity * dt
  
  -- Kill player, if touching
	if self:touchPlayer(dx,dy) then
    p.dead = true
  end
end
