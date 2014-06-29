local Bean = object:New({
	tag = 'Bean',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  vis = {
		Visualizer:New('starBandana'),
		Visualizer:New('bean'),
  },
})

function Bean:setAcceleration(dt)
	self.vis[1].angle = self.vis[1].timer * 2
	self.vis[2].sx = 0.95+0.05*math.sin(10*self.vis[1].timer)
	self.vis[2].sy = 0.95+0.05*math.sin(10*self.vis[1].timer)
	if self:touchPlayer() then
		self:kill()
		p.maxJumps = p.maxJumps + 1
		p.jumpsLeft = p.jumpsLeft + 1
  end
end

return Bean
