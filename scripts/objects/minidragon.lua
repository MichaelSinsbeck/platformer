local Minidragon = object:New({
	tag = 'Minidragon',
	category = "Misc",
	marginx = 0.4,
	marginy = 0.4,
	isInEditor = true,
	anchorRadii = {.5,.5},
	zoomState = 0, -- for cross hairs
	targetSpeed = 13,
	acceleration = 8,
	flyTimer = 0,
	state = "waiting",
  vis = {
		Visualizer:New('batFly'),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  }, 
})

function Minidragon:onConnect()
	self.state = "flying"
	self.vis[1].sx = -1
end

function Minidragon:applyOptions()
end

function Minidragon:collision()
end

function Minidragon:setAcceleration(dt)
	if self.state == "flying" then
		self.vx = math.min(self.vx + self.acceleration * dt, self.targetSpeed)
		self.vis[1].angle = 0.3
	end
	self.flyTimer = self.flyTimer + dt
	self.vy = - math.cos(self.flyTimer) * 0.35
end

function Minidragon:postStep(dt)
	
	-- scale crosshair
	if self.isCurrentTarget then
		self.zoomState = math.min(self.zoomState + 5*dt,1)
	else
		self.zoomState = math.max(self.zoomState - 7*dt,0)
	end
	local s = utility.easingOvershoot(self.zoomState)

	self.vis[2].angle = self.vis[2].angle + dt
	self.vis[2].sx = s
	self.vis[2].sy = s 
end

function Minidragon:onKill()
	if p.anchor and p.anchor.target == self then
		spriteEngine:DoAll('disconnect')
	end
end

return Minidragon
