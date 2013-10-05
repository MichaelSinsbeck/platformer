Bonus = object:New({
	tag = 'bonus',
  marginx = .8,
  marginy = .8,
  vis = {
		Visualizer:New('starBandana'),
		Visualizer:New('chickenleg'),
  },
})

function Bonus:setAcceleration(dt)
	self.vis[1].angle = self.vis[1].timer * 2
	self.vis[2].sx = 0.95+0.05*math.sin(10*self.vis[1].timer)
	self.vis[2].sy = 0.95+0.05*math.sin(10*self.vis[1].timer)
	if self:touchPlayer() then
		self:kill()
  end
end
