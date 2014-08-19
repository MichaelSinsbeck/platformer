local Key = object:New({
	tag = 'Key',
	category = 'Interactive',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  vis = {
		Visualizer:New('starBandana'),
		Visualizer:New('key'),
  },
})

function Key:setAcceleration(dt)
	self.vis[1].angle = self.vis[1].angle + 2*dt
	self.vis[2].sx = 0.9+0.1*math.sin(10*self.vis[2].timer)
	self.vis[2].sy = 0.9+0.1*math.sin(10*self.vis[2].timer)
	if self:touchPlayer() then
		p.nKeys = p.nKeys + 1
		self:kill()
  end
end

return Key
