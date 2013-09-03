Bandana = object:New({
	tag = 'bandana',
  marginx = .8,
  marginy = .8,
  animation = 'starBandana',
  sonAnimation = 'whiteBandana',
})

function Bandana:setAcceleration(dt)
	for k,v in pairs(self.vis[1]) do
		print(k)
	end
	--self.vis[1].angle = self.vis[1].angle + 2*dt
	self.vis[1].angle = self.vis[1].timer * 2
	self.vis[2].sx = 0.9+0.1*math.sin(10*self.vis[1].timer)
	self.vis[2].sy = 0.9+0.1*math.sin(10*self.vis[1].timer)
	if self:touchPlayer() then
		p.bandana = self.color
		self:kill()
  end
end

Bandana.blue = Bandana:New({color = 'blue',animation = 'starBandana', sonAnimation = 'blueBandana'})
Bandana.white = Bandana:New({color = 'white',animation = 'starBandana', sonAnimation = 'whiteBandana'})
Bandana.red = Bandana:New({color = 'red',animation = 'starBandana', sonAnimation = 'redBandana'})
Bandana.green = Bandana:New({color = 'green',animation = 'starBandana', sonAnimation = 'greenBandana'})
