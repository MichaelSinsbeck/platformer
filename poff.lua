Poff = object:New({
	tag = 'explosion',
  marginx = 0.4,
  marginy = 0.4,
  animation = 'poff',
  z = -1,
})

function Poff:setAcceleration(dt)
	if self.frame == 5 then
    self:kill()
	end
end
