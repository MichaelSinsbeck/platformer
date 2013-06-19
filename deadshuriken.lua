Shuriken = object:New({
	tag = 'dead shuriken',
  animation = 'shuriken',
  marginx = 0.3,
  marginy = 0.3,
  angle = 0,
  rotating = true,
})

function Shuriken:setAcceleration(dt)
	if self.frame == 5 then
    self:kill()
	end
end
