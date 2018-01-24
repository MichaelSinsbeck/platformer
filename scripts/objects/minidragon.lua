local Minidragon = object:New({
	tag = 'Minidragon',
	layout = 'center',
	category = "Misc",
	marginx = 0.4,
	marginy = 0.4,
	isInEditor = true,
	anchorRadii = {.5,.5},
	zoomState = 0, -- for cross hairs
	targetSpeed = 13,
	acceleration = 8,
	flyTimer = 0,
	phase = 1,
	speed = 13,
	transformTimer = 0,
	state = "seeking",
  vis = {
		Visualizer:New('batFly'),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  }, 
})

function Minidragon:findTarget()
	for k,v in pairs(spriteEngine.objects) do
		if v.tag == 'Dragonmarker' and v.phase == self.phase then
			self.targetX = v.x - 11.75
			self.targetY = v.y - 3.75
			self.state = "toTarget"
		end
	end
end

function Minidragon:onConnect()
	self.state = "seeking"
	self.vis[1].sx = -1
end

function Minidragon:onDisconnect()
end

function Minidragon:applyOptions()
end

function Minidragon:collision()
end

function Minidragon:setAcceleration(dt)
	if self.state == "transform" then
		if p.x < self.x then
			self.vis[1].sx = 1
		elseif p.x > self.x then
			self.vis[1].sx = -1
		end
		self.transformTimer = self.transformTimer + dt
		if self.transformTimer > .3 and not self.spawnedBoss then
			local newBoss = spriteFactory('Boss',{x=self.x + 11.75,y=self.y+3.75, phase = self.phase})
			spriteEngine:insert(newBoss,2)
			self.spawnedBoss = true
		end
		if self.transformTimer > 1.1 then
			self:kill()
		end
	end
	if self.state == "seeking" then
		self:findTarget()
	end
	if self.state == "toTarget" then
		self.speed = math.min(self.speed + self.acceleration * dt, self.targetSpeed)
		local dx,dy = self.targetX - self.x, self.targetY - self.y
		local distance = utility.pyth(dx,dy)
		if distance < 0.5 * self.targetSpeed^2 / self.acceleration then -- slow down close to target
			self.speed = math.sqrt(2*distance*self.acceleration)
		end
		--if distance < 7 then
		--	self.speed = math.max(distance/7 * self.targetSpeed,0.5)
		--end
		if distance < self.speed * dt then
			self.state = "transform"
			self.vx = 0
			self.vy = 0
			self.x = self.targetX
			self.y = self.targetY
		else
			self.vx = dx/distance * self.speed
			self.vy = dy/distance * self.speed
			if self.vx > 0 then self.vis[1].sx = -1 end
			if self.vx < 0 then self.vis[1].sx = 1 end
		end
	end

	self.flyTimer = self.flyTimer + dt
	if self.state == "waiting" then
		self.vy = - math.cos(self.flyTimer) * 0.35
	end
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
