local Bandana = object:New({
	tag = 'Bandana',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  vis = {
		Visualizer:New('starBandana'),
		Visualizer:New('whiteBandana'),
  },
	properties = {
		color = newCycleProperty({'white','blue','red'})
	},  
})

function Bandana:applyOptions()
	self:setAnim(self.color .. 'Bandana',true,2)
end

function Bandana:setAcceleration(dt)
	--self.vis[1].angle = self.vis[1].angle + 2*dt
	self.vis[1].angle = self.vis[1].timer * 2
	self.vis[2].sx = 0.9+0.1*math.sin(10*self.vis[1].timer)
	self.vis[2].sy = 0.9+0.1*math.sin(10*self.vis[1].timer)
	if self:touchPlayer() then
		p.bandana = self.color
		self:kill()
  end
end

return Bandana
--[[Bandana.blue = Bandana:New({color = 'blue', vis = {Visualizer:New('starBandana'),	Visualizer:New('blueBandana'),},})
Bandana.white = Bandana:New({color = 'white', vis = {Visualizer:New('starBandana'),	Visualizer:New('whiteBandana'),},})
Bandana.green = Bandana:New({color = 'green', vis = {Visualizer:New('starBandana'),	Visualizer:New('greenBandana'),},})
Bandana.red = Bandana:New({color = 'red', vis = {Visualizer:New('starBandana'),	Visualizer:New('redBandana'),},})]]
