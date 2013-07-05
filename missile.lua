Missile = object:New({
	tag = 'missile',
  vx = 1,
  vy = 1,
  maxspeed = 25,--18,--30,
  seekspeed = 80,--55,
  rotating = true,
  z = -1,
  img = love.graphics.newImage('images/missile.png'),
  marginx = 0.4,
  marginx = 0.4,
  spreadSpeed = 10,--5,
  particleRotSpeed = 20,
})

function Missile:setAcceleration(dt)
	if p.visible then
		local dx = self.x-p.x
		local dy = self.y-p.y
		local distance = math.sqrt(dx*dx+dy*dy)
		
		self.vx = self.vx - self.seekspeed*dx/distance*dt
		self.vy = self.vy - self.seekspeed*dy/distance*dt
		
		local speed = math.sqrt(self.vx^2+self.vy^2)
		
		if speed > self.maxspeed then
			self.vx = self.vx/speed*self.maxspeed
			self.vy = self.vy/speed*self.maxspeed
		end
		
		self.angle = math.atan2(self.vy,self.vx)
  end
end

function Missile:postStep(dt)
	local dx = self.x-p.x
	local dy = self.y-p.y
	if self:touchPlayer(dx,dy) then
    p.dead = true
  end

  if self.collisionResult > 0 then
  	local newExplo = Explosion:New({x=self.x,y=self.y,angle=2*math.pi*math.random()})
		spriteEngine:insert(newExplo)
		
		if self.collisionResult % 2 == 1 then self.vx = math.min(self.vx,0) end --collision right
		if math.floor(self.collisionResult/2)%2 == 1 then self.vx = math.max(self.vx,0) end --collision left
		if math.floor(self.collisionResult/4)%2 == 1 then self.vy = math.max(self.vy,0) end --collision top
		if math.floor(self.collisionResult/8)%2 == 1 then self.vy = math.min(self.vy,0) end --collision bottom
		local baseVx,baseVy = 0.2*self.vx,0.2*self.vy

		for i = 1,6 do -- spawn 5 particles
		  local angle, magnitude = math.pi*2*math.random(), 0.7+math.random()*0.3
		  local cos,sin = math.cos(angle),math.sin(angle)
			if self.collisionResult % 2 == 1 then cos = -math.abs(cos) end --collision right
			if math.floor(self.collisionResult/2)%2 == 1 then cos = math.abs(cos) end --collision left
			if math.floor(self.collisionResult/4)%2 == 1 then sin = math.abs(sin) end --collision top
			if math.floor(self.collisionResult/8)%2 == 1 then sin = -math.abs(sin) end --collision bottom
		  
		  local vx = cos*self.spreadSpeed*magnitude+baseVx
		  local vy = sin*self.spreadSpeed*magnitude+baseVy
		  
		  local rotSpeed = self.particleRotSpeed * (math.random()*2-1)
		  local newParticle = Particle:New({x=self.x,y=self.y,vx = vx,vy = vy,rotSpeed = rotSpeed})
		  spriteEngine:insert(newParticle)
		end
    self:kill()
  end
end
