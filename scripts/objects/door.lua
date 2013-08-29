Door = object:New({
	tag = 'Door',
  marginx = 0.8,
  marginy = 0.8,
  animation = 'door',
  status = 'passive',
  openTime = 0.05,
  spreadSpeed = 8,  -- For explosion
  particleRotSpeed = 5, -- For explosion  
})

function Door:setAcceleration(dt)
end

function Door:activate(args)
	if self.status == 'passive' and 
		math.abs(self.x-args.x)+math.abs(self.y-args.y) <= 1 then
		self.status = 'active'
		self.timer = args.t
		myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
		--self.alpha = math.min(255*(self.openTime-self.timer)/self.openTime,255)
	end
end

function Door:postStep(dt)
	if self.status == 'active' then
		--self.alpha = math.min(255*(self.openTime-self.timer)/self.openTime,255)
		self.sx = math.min((self.openTime-self.timer)/self.openTime,1)
		self.sy = math.min((self.openTime-self.timer)/self.openTime,1)
		if self.timer > self.openTime then
			local args = {t=self.timer-self.openTime, x = self.x, y=self.y}
			spriteEngine:DoAll('activate',args)
			self:die()
		end
	end
end

function Door:die()
	myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
	self:kill()
	for i = 1,6 do -- spawn 6 particles
		local angle, magnitude = math.pi*2*math.random(), 0.7+math.random()*0.3
		
		local vx = math.cos(angle)*self.spreadSpeed*magnitude
		local vy = (math.sin(angle)-0.2)*self.spreadSpeed*magnitude
		local x,y = self.x + math.random()-0.5, self.y+math.random()-0.5
		
		local rotSpeed = self.particleRotSpeed * (math.random()*2-1)
		local animation = 'door' .. math.random(1,4)
		local newParticle = Particle:New({x=self.x,y=self.y,vx = vx,vy = vy,rotSpeed = rotSpeed,animation = animation})
		--spriteEngine:insert(newParticle)
	end
end
