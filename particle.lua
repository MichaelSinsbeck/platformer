Particle = object:New({
	tag = 'particle',
  marginx = 0.4,
  marginy = 0.4,
  animation = 'particle',
  angle = 0,
  rotating = true,
  rotSpeed = 5,
  acceleration = 5,
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
	if self.frame == 5 then
    self:kill()
	end
end
