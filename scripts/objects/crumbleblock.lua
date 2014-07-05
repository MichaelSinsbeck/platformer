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
				local lifetime = 0.4 + 0.4*math.random()
				local newParticle = spriteFactory('Particle',{x=x,y=y,vx = vx,vy = 0,rotSpeed = rotSpeed,vis = {Visualizer:New(vis.animation)}})
				spriteEngine:insert(newParticle)
			  self.vis[i] = nil
			end
		end
		if #self.vis == 0 then
			myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
			self:kill()
		end
	end
end

return Crumbleblock
