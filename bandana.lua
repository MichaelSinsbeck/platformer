Bandana = object:New({
	tag = 'bandana',
  marginx = 1,
  marginy = 1,
  animation = 'starBandana',
  sonAnimation = 'whiteBandana',
})

function Bandana:setAcceleration(dt)
	self.angle = self.angle + 2*dt
	self.sonSx = 0.9+0.1*math.sin(10*self.timer)
	self.sonSy = 0.9+0.1*math.sin(10*self.timer)
	if self:touchPlayer() then
		p.bandana = self.color
		self:kill()
  end
end

Bandana.blue = Bandana:New({color = 'blue',sonAnimation = 'blueBandana'})
Bandana.white = Bandana:New({color = 'white',sonAnimation = 'whiteBandana'})
Bandana.red = Bandana:New({color = 'red',sonAnimation = 'redBandana'})
Bandana.green = Bandana:New({color = 'green',sonAnimation = 'greenBandana'})
