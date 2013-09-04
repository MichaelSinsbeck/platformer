Explosion = object:New({
	tag = 'explosion',
  marginx = 0.4,
  marginy = 0.4,
  vis = {Visualizer:New('explosionExplode'),},
  --animation = 'explosionExplode',
  --rotating = true,
})

function Explosion:setAcceleration(dt)
	if self.vis[1].frame == 7 then
    self:kill()
	end
end
