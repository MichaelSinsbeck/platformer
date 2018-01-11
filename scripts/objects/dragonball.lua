local Dragonball = object:New({
	tag = 'Dragonball',
  marginx = 0.4,
  marginy = 0.4,
  speed = 30,
  acceleration = 25,
  tx = 0,
  ty = 0,
  state = 'coming',
	spreadSpeed = 8,  -- For explosion
  particleRotSpeed = 5, -- For explosion  
  vis = {Visualizer:New('enemyprewalker'),},
})

function Dragonball:setAcceleration(dt)
	if self.state == 'coming' then
	local dx,dy = self.tx - self.x, self.ty - self.y
	local distance = utility.pyth(dx,dy)
	
	local vxTarget = dx/distance * self.speed
	local vyTarget = dy/distance * self.speed
	
	local dax = vxTarget - self.vx
	local day = vyTarget - self.vy
	local da = utility.pyth(dx,dy)
	
	self.vx = self.vx + dax/da * self.acceleration * dt
	self.vy = self.vy + day/da * self.acceleration * dt
	
	if distance < 1 then
		self.state = 'leaving'
	end
	
	else
		local currentSpeed = utility.pyth(self.vx,self.vy)
		self.vx = self.vx/currentSpeed * self.speed
		self.vy = self.vy/currentSpeed * self.speed
	end
end

function Dragonball:postStep(dt)
	-- gets destroyed after collision
	if self.collisionResult > 0 then
		for i = 1,6 do -- spawn 6 particles
			local angle, magnitude = math.pi*2*math.random(), 0.7+math.random()*0.3
			
			local right,left,up,down = utility.directions(self.collisionResult)
			local signx, signy = 1, 1
			if right or left then
				signx = -1
			end
			if up or down then
				signy = -1
			end
			
			local vx = math.cos(angle)*self.spreadSpeed*magnitude + signx * 0.3 * self.vx 
			local vy = (math.sin(angle)-0.2)*self.spreadSpeed*magnitude + signy * 0.3 * self.vy
			local x,y = self.x + math.random()-0.3, self.y+math.random()-0.3
			
			local rotSpeed = self.particleRotSpeed * (math.random()*2-1)
			local animation = 'anchor' .. math.random(1,4)
			local newParticle = spriteFactory('Particle',{x=self.x,y=self.y,vx = vx,vy = vy,rotSpeed = rotSpeed,vis = {Visualizer:New(animation)} })
			spriteEngine:insert(newParticle)
		end
		self:kill()
	end
	
	-- kill player on contact
	if not p.dead and self:touchPlayer(dx,dy) then
    p:kill()
    --levelEnd:addDeath("death_imitator")
    objectClasses.Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end 
end

--function Dragonball:collision()
--end

return Dragonball
