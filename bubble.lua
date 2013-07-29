Bubble = object:New({
	tag = 'bubble',
  marginx = 0.9,
  marginy = 0.9,
  animation = 'bubble',
	vy = -1,
	drift = 0,
	lifetime = 0.3,
})

function Bubble:setAcceleration(dt)
	self.vx = math.sin(15*self.timer+3*self.offset) + self.drift
	if self.timer > self.lifetime then
    self:kill()
	end
end
