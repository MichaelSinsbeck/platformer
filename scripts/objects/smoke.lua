local Smoke = object:New({
	tag = 'Smoke',
  marginx = 0.4,
  marginy = 0.4,
  vis = {Visualizer:New('smoke')},
})

function Smoke:setAcceleration(dt)
	self.vy = self.vy - 3*dt
	if self.vis[1].frame == 6 then
    self:kill()
		p.canDash = true
	end
end

return Smoke
