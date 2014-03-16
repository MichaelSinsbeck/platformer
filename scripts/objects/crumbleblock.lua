local Crumbleblock = object:New({
	tag = 'Crumbleblock',
  isInEditor = true,
  --marginx = 0.8,
  --marginy = 0.8,
  marginx = 2,
  marginy = 2,
  state = 'sleep',
  solid = true,
  spreadSpeed = 2,  -- For explosion
  particleRotSpeed = 5, -- For explosion
  deathtime = 0.1, -- time from frist crumbling till end
  nCrumbs = 9,
  --vis = {Visualizer:New('crumbleblock')},
  vis = {Visualizer:New('crumble1',{relY = -.25, relX = -.25}),
				 Visualizer:New('crumble2',{relY = 0,    relX = -.25}),
				 Visualizer:New('crumble3',{relY = .25, relX = -.25}),
				 Visualizer:New('crumble4',{relY = -.25, relX = 0}),
				 Visualizer:New('crumble5',{relY = 0,    relX = 0}),
				 Visualizer:New('crumble6',{relY = .25, relX = 0}),
				 Visualizer:New('crumble7',{relY = -.25, relX = .25}),
				 Visualizer:New('crumble8',{relY = 0,    relX = .25}),
				 Visualizer:New('crumble9',{relY = .25, relX = .25}),	},
	properties = {
		lifetime = utility.newProperty({.5 , 1, 1.5, 2, 2.5, 3},nil,2)
	},  
})

function Crumbleblock:setAcceleration(dt)
end

function Crumbleblock:postStep(dt)
	if self.state == 'sleep' and
		math.abs(self.x-p.x) <= self.semiwidth+p.semiwidth and
		math.abs(self.y-p.y) <= self.semiheight+p.semiheight then
		self.state = 'wait'
		self.vis[1].timer = 0
	elseif self.state == 'wait' then
		for i = #self.vis,1,-1 do
			local vis = self.vis[i]
			if (self.lifetime - self.vis[1].timer)/self.deathtime < i / (self.nCrumbs-1) then
			
				local x, y = self.x + vis.relX, self.y + vis.relY
				local vx = (math.random()*2-1)*self.spreadSpeed
				local rotSpeed = self.particleRotSpeed * (math.random()*2-1)
				local newParticle = spriteFactory('Particle',{x=x,y=y,vx = vx,vy = 0,rotSpeed = rotSpeed,vis = {Visualizer:New(vis.animation)}})
				spriteEngine:insert(newParticle)
			  self.vis[i] = nil
			end
		end
		--self.vis[1].alpha = 120+125*math.max(1-self.vis[1].timer/self.lifetime,0)
		--[[
		if self.vis[1].timer > self.lifetime then
			myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
			myMap:queueShadowUpdate()
			self:kill()
			for i = 1,6 do -- spawn 6 particles
				local angle, magnitude = math.pi*2*math.random(), 0.7+math.random()*0.3
				
				local vx = math.cos(angle)*self.spreadSpeed*magnitude
				local vy = (math.sin(angle)-0)*self.spreadSpeed*magnitude
				--local vx = 0
				--local vy = 0
				local x,y = self.x + math.random()-0.5, self.y+math.random()-0.5
				
				local rotSpeed = self.particleRotSpeed * (math.random()*2-1)
				local animation = 'crumble' .. math.random(1,12)
				local newParticle = Particle:New({x=x,y=y,vx = vx,vy = vy,rotSpeed = rotSpeed,vis = {Visualizer:New(animation)} })
				spriteEngine:insert(newParticle)
			end
		end--]]
	end
end

return Crumbleblock
