Goalie = object:New({
  maxSpeed = 20,
  acc = 50,
  xSensing = 7, --how far can he see?
  ySensing = 20,
  img = love.graphics.newImage('goalie.png')
})

function Goalie:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  if math.abs(dx) < self.xSensing and math.abs(dy) < self.ySensing then
		-- run towards player
		if dy > 0 then
			self.vy = self.vy - self.acc * dt
		else
			self.vy = self.vy + self.acc * dt
		end
	else
	  -- stop running
	  if self.vy > self.acc * dt then
	    self.vy = self.vy - self.acc * dt
	  elseif self.vy < - self.acc * dt then
	    self.vy = self.vy + self.acc * dt
	  else
	    self.vy = 0
	  end
	end
  
  if self.vx < -self.maxSpeed then
    self.vx = -self.maxSpeed
  end
  if self.vx > self.maxSpeed then
    self.vx = self.maxSpeed
  end
    
  -- Kill player, if touching
  if dx < p.width and -dx < self.width and
     dy < p.height and -dy < self.height then
    p.dead = true
  end
end
