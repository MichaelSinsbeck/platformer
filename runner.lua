Runner = object:New({
  maxSpeed = 20,
  acc = 50,
  xSensing = 20, --how far can he see?
  ySensing = 7,
  img = love.graphics.newImage('runner.png')
})

function Runner:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  if math.abs(dx) < self.xSensing and math.abs(dy) < self.ySensing then
		-- run towards player
		if dx > 0 then
			self.vx = self.vx - self.acc * dt
		else
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
  if dx < p.width and -dx < self.width and
     dy < p.height and -dy < self.height then
    p.dead = true
  end
end