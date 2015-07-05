local Glassblock = object:New({
	tag = 'Glassblock',
  marginx = 0.8,
  marginy = 0.8,
  isInEditor = true,
  solid = true,
  spreadSpeed = 8,  -- For explosion
  particleRotSpeed = 5, -- For explosion
	vis = {Visualizer:New('glassblock')},
})

function Glassblock:setAcceleration(dt)
end

function Glassblock:explode(args)
	local dx,dy = args.x-self.x,args.y-self.y
	-- check if explosion is within range
	if dx*dx+dy*dy < args.radius2 then
		self:playSound('glassBreak',1,1,0.1)
		myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
		
		for i = 1,6 do -- spawn 6 particles
				local angle, magnitude = math.pi*2*math.random(), 0.7+math.random()*0.3
				
				local vx = math.cos(angle)*self.spreadSpeed*magnitude
				local vy = (math.sin(angle)-0.2)*self.spreadSpeed*magnitude
				local x,y = self.x + math.random()-0.5, self.y+math.random()-0.5
				
				local rotSpeed = self.particleRotSpeed * (math.random()*2-1)
				local animation = 'glass' .. math.random(1,4)
				local newParticle = spriteFactory('Particle',{x=self.x,y=self.y,vx = vx,vy = vy,rotSpeed = rotSpeed,vis = {Visualizer:New(animation)} })
				spriteEngine:insert(newParticle)
			end
		self:kill()
	end
end

return Glassblock
