Bandana = object:New({
	tag = 'bandana',
  marginx = 1,
  marginy = 1,
  animation = 'whiteBandana',
})

function Bandana:setAcceleration(dt)
	
	if self:touchPlayer() then
		p.bandana = self.color
		self:kill()
  end
end

Bandana.blue = Bandana:New({color = 'blue',animation = 'blueBandana'})
Bandana.white = Bandana:New({color = 'white',animation = 'whiteBandana'})
Bandana.red = Bandana:New({color = 'red',animation = 'redBandana'})
Bandana.green = Bandana:New({color = 'green',animation = 'greenBandana'})
