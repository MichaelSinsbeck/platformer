local Anchor = object:New({
	tag = 'Anchor',
  marginx = 0.4,
  marginy = 0.4,
  isInEditor = true,
  isCurrentTarget = false,
  zoomState = 0,
  anchorRadii = {.3,.3},
  vis = {
		Visualizer:New('anchor'),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  },
})

function Anchor:setAcceleration(dt)
end

function Anchor:postStep(dt)
	if self.isCurrentTarget then
		self.zoomState = math.min(self.zoomState + 5*dt,1)
	else
		self.zoomState = math.max(self.zoomState - 7*dt,0)
	end
	local s = utility.easingOvershoot(self.zoomState)

	self.vis[2].angle = self.vis[2].angle + dt
	self.vis[2].sx = s
	self.vis[2].sy = s
	
	if self.collisionResult > 0 then
		self:kill()
		self.vx = 0
		self.vy = 0	
  end
end

function Anchor:onKill()
	if p.anchor and p.anchor.target == self then
		spriteEngine:DoAll('disconnect')
	end
end

return Anchor
