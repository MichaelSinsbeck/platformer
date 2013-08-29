Key = object:New({
	tag = 'key',
  marginx = .8,
  marginy = .8,
  animation = 'starBandana',
  sonAnimation = 'key',
})

function Key:setAcceleration(dt)
	self.angle = self.angle + 2*dt
	self.sonSx = 0.9+0.1*math.sin(10*self.timer)
	self.sonSy = 0.9+0.1*math.sin(10*self.timer)
	if self:touchPlayer() then
		p.nKeys = p.nKeys + 1
		self:kill()
  end
end
