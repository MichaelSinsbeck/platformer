Explosion = object:New({
	tag = 'explosion',
  marginx = 0.4,
  marginy = 0.4,
  animation = 'explosionExplode'
})

function Explosion:setAcceleration(dt)
	if self.frame == 7 then
    self:kill()
	end
end
