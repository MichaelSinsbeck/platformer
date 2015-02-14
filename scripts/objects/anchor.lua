local Anchor = object:New({
	tag = 'Anchor',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  isCurrentTarget = false,
  zoomState = 0,
  anchorRadii = {.6,.6},
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
	local s = self:easing(self.zoomState)

	self.vis[2].angle = self.vis[2].angle + dt
	self.vis[2].sx = s
	self.vis[2].sy = s
end

function Anchor:easing(t)
	if t <= 0 then
		return 0
	elseif t >= 1 then
		return 1
	else
		return 1-(1-3*t)*((1-t)^2)
	end
end

return Anchor
