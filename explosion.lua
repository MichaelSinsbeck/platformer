Explosion = object:New({
	tag = 'explosion',
  marginx = 0.4,
  marginy = 0.4,
  animation = 'explosionExplode',
  angle = 0,
  rotating = true,
})

function Explosion:setAcceleration(dt)
	if self.frame == 7 then
    self:kill()
	end
end
