Goalie = object:New({
	tag = 'goalie',
  maxSpeed = 20,
  acc = 50,
  xSensing = 7, --how far can he see?
  ySensing = 20,
	marginx = 0.4,
  marginy = 0.65,
  vis = {
		Visualizer:New('goalie'),
  },
})

function Goalie:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  if p.visible and not p.dead and math.abs(dx) < self.xSensing and math.abs(dy) < self.ySensing then
		-- run towards player
		if dy > 0 then
			self.vy = self.vy - self.acc * dt
		else
			self.vy = self.vy + self.acc * dt
		end
	else
	  -- stop moving
	  if self.vy > self.acc * dt then
	    self.vy = self.vy - self.acc * dt
	  elseif self.vy < - self.acc * dt then
	    self.vy = self.vy + self.acc * dt
	  else
	    self.vy = 0
	  end
	end
  
  if self.vy < -self.maxSpeed then
    self.vy = -self.maxSpeed
  end
  if self.vy > self.maxSpeed then
    self.vy = self.maxSpeed
  end
  
	self.vis[1].sx = 1 - 0.2* math.abs(self.vy)/self.maxSpeed
	self.vis[1].sy = 1/self.vis[1].sx
  
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p.dead = true
    Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end
end
