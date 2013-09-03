Poff = object:New({
	tag = 'Poff',
  marginx = 0.4,
  marginy = 0.4,
  animation = 'poff',
})

function Poff:setAcceleration(dt)
	self.vy = self.vy - 3*dt
	if self.vis[1].frame == 6 then
    self:kill()
	end
end
