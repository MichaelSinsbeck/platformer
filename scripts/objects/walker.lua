Walker = object:New({
	tag = 'walker',
	speed = 1.6,
	vx = 1.6,
	timer = 0,
  vis = {
		Visualizer:New('walker'),
		Visualizer:New('walkerfoot'),
		Visualizer:New('walkerfoot'),
  },
  marginx = 0.8,
  marginy = 0.50,
  period = 0.5, -- should be (0.8/speed)
})

function Walker:postStep(dt)
	if self.collisionResult >= 8 then
		self.timer = (self.timer + dt)%self.period
	else
		self.timer = self.period*0.25
	end

	if self.collisionResult%2 == 1 then
	  self.vx = -self.speed
	  for i = 1,3 do
			self.vis[i].sx = -1
	  end
	end
	
	local truncated = (self.collisionResult - self.collisionResult%2)/2
	if truncated%2 == 1 then
		self.vx = self.speed
		for i = 1,3 do
			self.vis[i].sx = 1
	  end
	end
	
	-- positioning of feed
	local sign = self.vis[1].sx
	local t = self.timer/self.period -- effective timer
	local pi = math.pi
	if t < .5 then
		self.vis[2].relX = sign*(0.4 - 0.2*math.cos(2*pi*t))
		self.vis[2].relY = 0.25 - 0.1*math.sin(2*pi*t)
		self.vis[2].angle = -sign*0.3*math.sin(2*pi*t)
		
		self.vis[3].relX = sign*(- 0.8*t)
		self.vis[3].relY = 0.25
		self.vis[3].angle = 0
  else
		self.vis[2].relX = sign*(1 - 0.8*t)
		self.vis[2].relY = 0.25
		self.vis[2].angle = 0
		
		self.vis[3].relX = sign*(-0.2 + 0.2*math.cos(2*pi*t))
		self.vis[3].relY = 0.25 + 0.1*math.sin(2*pi*t)
		self.vis[3].angle = sign*0.3*math.sin(2*pi*t)
  end
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p.dead = true
    levelEnd:addDeath("death_walker")
    Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end  
end
