Bouncer = object:New({
	tag = 'bouncer',
  targetvy = -23,
  marginx = 0.8,
  marginy = 0.2,
  animation = 'bouncer',
  frame = 2,
})

function Bouncer:setAcceleration(dt)
	if self:touchPlayer() then
     p.vy = math.min(self.targetvy,p.vy)
     p.canUnJump = false
     self:resetAnimation()
  end
end
