Bumper = object:New({
	tag = 'bumper',
  targetv = 23,
  marginx = 0.8,
  marginy = 0.8,
  layout = 'center',
  vis = {
		Visualizer:New('bumper'),
  },  
  radius = .8,
})

function Bumper:setAcceleration(dt)
end

function Bumper:postStep(dt)
		self.vis[1].sx = math.min(1,self.vis[1].sx+dt)
		self.vis[1].sy = self.vis[1].sx

	local dx,dy = p.x-self.x,p.y-self.y
	if utility.pyth(dx,dy) < self. radius then
		local angle = math.atan2(dy,dx)
		p.vx = math.cos(angle) * self.targetv
		p.vy = math.sin(angle) * self.targetv
		p.canUnJump = false
		self.vis[1].sx = .8
		self.vis[1].sy = .8
	end
end
