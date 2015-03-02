local Follower = object:New({
	tag = 'Follower',
	category = 'Enemies',
	layout = 'center',
  --maxSpeed = 20,
  range = 7, --how far can he see?
	state = 'wait',
	marginx = 0.7,
  marginy = 0.7,
  acceleration = 60,
  isInEditor = true,
  zoomState = 0,
	spreadSpeed = 8,  -- For explosion
  particleRotSpeed = 5, -- For explosion  
  vis = {
		Visualizer:New('followerBack'),
		Visualizer:New('followerPupil'),
		Visualizer:New('followerClose',{frame = 4}),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  },
  properties = {
		maxSpeed = utility.newCycleProperty({10,15,20},{'slow','medium','fast'},2)
  },
	--properties = {
	--	direction = utility.newCycleProperty({0, .5, 1, -.5}, {'vertical', 'diagonal1','horizontal','diagonal2'}),
	--},
	anchorRadii = {.6,.6},
})

function Follower:applyOptions()

end

function Follower:setAcceleration(dt)
	if p.dead then return end
	if self.state == 'wait' then
	local dx, dy = p.x-self.x, p.y-self.y
		if math.abs(dx) < self.semiwidth + p.semiwidth then
			if myMap:lineOfSight(self.x,self.y,p.x,p.y) then
				self.ax = 0
				if dy > 0 then
					self.ay = self.acceleration
				else
					self.ay = -self.acceleration
				end
				self:wake()
			end
			-- up or down
		elseif math.abs(dy) < self.semiheight + p. semiheight and
					myMap:lineOfSight(self.x,self.y,p.x,p.y) then
			self.ay = 0
			if dx > 0 then
				self.ax = self.acceleration
			else
				self.ax = -self.acceleration
			end
			self:wake()
		end
	else -- is awake
		self.vx = self.vx + self.ax * dt
		self.vy = self.vy + self.ay * dt
		
		-- velocity constraint
		self.vx = math.min(self.vx,self.maxSpeed)
		self.vx = math.max(self.vx,-self.maxSpeed)
		self.vy = math.min(self.vy,self.maxSpeed)
		self.vy = math.max(self.vy,-self.maxSpeed)
		
	end
end

function Follower:wake()
	self.state = 'follow'
	self:setAnim('followerOpen',nil,3)
	local angle = math.atan2(self.ay,self.ax)
	self.vis[2].relX = 0.15*math.cos(angle)
	self.vis[2].relY = 0.15*math.sin(angle)
end

function Follower:postStep(dt)

	if self.collisionResult > 0 then
		self.state = 'wait'
		self:setAnim('followerClose',nil,3)
	end
	
	if self.state == 'wait' then
		self.vx = 0
		self.vy = 0
	end
	-- show crosshairs
  if self.anchorRadii then
		if self.isCurrentTarget then
			self.zoomState = math.min(self.zoomState + 5*dt,1)
		else
			self.zoomState = math.max(self.zoomState - 7*dt,0)
		end
		local s = utility.easingOvershoot(self.zoomState)

		self.vis[4].angle = self.vis[4].angle + dt
		self.vis[4].sx = s
		self.vis[4].sy = s 
	end 
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p:kill()
    levelEnd:addDeath("death_follower")
    objectClasses.Meat:spawn(p.x,p.y,self.vx,self.vy,12)
    self:playSound('followerDeath')
  end
end

function Follower:postpostStep()
	for k,v in pairs(spriteEngine.objects) do
		if v ~= self and v.tag == 'Follower' then
			local dx,dy = v.x-self.x,v.y-self.y
			if math.abs(dx) < self.semiheight+v.semiheight and
				 math.abs(dy) < self.semiwidth +v.semiwidth then
				self:kill()
				for i = 1,6 do -- spawn 6 particles
					local angle, magnitude = math.pi*2*math.random(), 0.7+math.random()*0.3
					
					local vx = math.cos(angle)*self.spreadSpeed*magnitude - 0.5 * v.vx
					local vy = (math.sin(angle)-0.2)*self.spreadSpeed*magnitude - 0.5 * v.vy
					local x,y = self.x + math.random()-0.3, self.y+math.random()-0.3
					
					local rotSpeed = self.particleRotSpeed * (math.random()*2-1)
					local animation = 'anchor' .. math.random(1,4)
					local newParticle = spriteFactory('Particle',{x=self.x,y=self.y,vx = vx,vy = vy,rotSpeed = rotSpeed,vis = {Visualizer:New(animation)} })
					spriteEngine:insert(newParticle)
				end
				break
			end
		end
	end
end

function Follower:onKill()
	if p.anchor and p.anchor.target == self then
		spriteEngine:DoAll('disconnect')
	end
end

return Follower
