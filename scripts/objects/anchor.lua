local Anchor = object:New({
	tag = 'Anchor',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
	solid = true,
  vis = {
		Visualizer:New('anchor'),
  },
})

function Anchor:setAcceleration(dt)
end

return Anchor
