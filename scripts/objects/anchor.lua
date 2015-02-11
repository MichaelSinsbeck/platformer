local Anchor = object:New({
	tag = 'Anchor',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
	solid = true,
  vis = {
		Visualizer:New('anchor'),
		Visualizer:New('crosshairs',{active = false}),
  },
})

function Anchor:setAcceleration(dt)
end

function Anchor:postStep(dt)
	self.vis[2].angle = self.vis[2].angle + dt
end

return Anchor
