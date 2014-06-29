local Woosh = object:New({
	tag = 'Woosh',
  marginx = 0.4,
  marginy = 0.4,
  vis = {Visualizer:New('woosh')},
})

function Woosh:setAcceleration(dt)
	self.vis[1].alpha = self.vis[1].alpha - 1000*dt
	
	if self.vis[1].alpha < 0 then
		self:kill()
	end
end

return Woosh
