Crumbleblock = object:New({
	tag = 'crumbleblock',
  marginx = 0.8,
  marginy = 0.8,
  state = 'sleep',
  crumbleTime = 1,
  animation = 'crumbleblock',
  spreadSpeed = 8,  -- For explosion
  particleRotSpeed = 5, -- For explosion  
})

function Crumbleblock:setAcceleration(dt)
end

function Crumbleblock:postStep(dt)
	if self.state == 'sleep' and
		math.abs(self.x-p.x) <= self.semiwidth+p.semiwidth and
		math.abs(self.y-p.y) <= self.semiheight+p.semiheight then
		self.state = 'wait'
	elseif self.state == 'wait' then
		self.crumbleTime = self.crumbleTime - dt
		self.vis[1].alpha = 120+125*self.crumbleTime
		if self.crumbleTime < 0 then
			myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
			self:kill()
			for i = 1,6 do -- spawn 6 particles
				local angle, magnitude = math.pi*2*math.random(), 0.7+math.random()*0.3
				
				local vx = math.cos(angle)*self.spreadSpeed*magnitude
				local vy = (math.sin(angle)-0.2)*self.spreadSpeed*magnitude
				local x,y = self.x + math.random()-0.5, self.y+math.random()-0.5
				
				local rotSpeed = self.particleRotSpeed * (math.random()*2-1)
				local animation = 'crumble' .. math.random(1,4)
				local newParticle = Particle:New({x=self.x,y=self.y,vx = vx,vy = vy,rotSpeed = rotSpeed,animation = animation})
				spriteEngine:insert(newParticle)
			end
		end
	end
end
