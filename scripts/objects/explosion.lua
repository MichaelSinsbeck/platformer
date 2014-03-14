local Explosion = object:New({
	tag = 'Explosion',
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

return Explosion
