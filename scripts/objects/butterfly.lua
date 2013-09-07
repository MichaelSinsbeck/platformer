-- Butterfly is not yet prepared for visualization-system

Butterfly = object:New({
	tag = 'Butterfly',
  marginx = 0.4,
  marginy = 0.4,
  animation = 'butterflywing1',
  sonAngle = 0,
  angle = 0,
  rotating = true,
  rotSpeed = 5,
  acceleration = 5,
  lifetime = 0.6,
  sy = 1,
})

function Butterfly:setAcceleration(dt)
	self.vy = self.vy - gravity * dt
	local speed = math.sqrt(self.vx*self.vx+self.vy*self.vy)
	self.angle = math.atan2(self.vy,self.vx)
	self.sonAngle = self.angle
	self.sy = 1+0.5*math.sin(40*self.timer)
	if speed < self.acceleration*dt then
	  self.vx,self.vy = 0,0
	  else
	  local factor = (speed-self.acceleration*dt)/speed
	  self.vx,self.vy = factor*self.vx, factor*self.vy
	end
	
	if self.timer >= self.lifetime then
    self:kill()
	end
end

