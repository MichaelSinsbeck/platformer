Particle = object:New({
	tag = 'particle',
  marginx = 0.4,
  marginy = 0.4,
  animation = 'particle',
  angle = 0,
  rotating = true,
  rotSpeed = 5,
  acceleration = 5,
  lifetime = 0.6,
})

function Particle:setAcceleration(dt)
	self.vy = self.vy + gravity * dt
	local speed = math.sqrt(self.vx*self.vx+self.vy*self.vy)
	self.angle = self.angle + self.rotSpeed*dt*speed
	if speed < self.acceleration*dt then
	  self.vx,self.vy = 0,0
	  else
	  local factor = (speed-self.acceleration*dt)/speed
	  self.vx,self.vy = factor*self.vx, factor*self.vy
	end
	
	self.alpha = math.min(2*(self.lifetime - self.timer)/self.lifetime,1)*255
	if self.timer >= self.lifetime then
    self:kill()
	end
end
