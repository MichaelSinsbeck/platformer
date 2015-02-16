local Anchor = object:New({
	tag = 'Anchor',
  marginx = 0.2,
  marginy = 0.2,
  isInEditor = true,
  layout = 'center',
  isCurrentTarget = false,
  zoomState = 0,
  anchorRadii = {.5,.5},
  isActive = true,
	spreadSpeed = 8,  -- For explosion
  particleRotSpeed = 5, -- For explosion
  lifetime = .5, -- after hitting something
  vis = {
		Visualizer:New('anchor'),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  },
})

function Anchor:setAcceleration(dt)
end

function Anchor:postStep(dt)
	if self.isCurrentTarget then
		self.zoomState = math.min(self.zoomState + 5*dt,1)
	else
		self.zoomState = math.max(self.zoomState - 7*dt,0)
	end
	local s = utility.easingOvershoot(self.zoomState)

	self.vis[2].angle = self.vis[2].angle + dt
	self.vis[2].sx = s
	self.vis[2].sy = s
	
	if self.collisionResult > 0 then
		for i = 1,6 do -- spawn 6 particles
			local angle, magnitude = math.pi*2*math.random(), 0.7+math.random()*0.3
			
			local vx = math.cos(angle)*self.spreadSpeed*magnitude
			local vy = (math.sin(angle)-0.2)*self.spreadSpeed*magnitude
			local x,y = self.x + math.random()-0.3, self.y+math.random()-0.3
			
			local rotSpeed = self.particleRotSpeed * (math.random()*2-1)
			local animation = 'anchor' .. math.random(1,4)
			local newParticle = spriteFactory('Particle',{x=self.x,y=self.y,vx = vx,vy = vy,rotSpeed = rotSpeed,vis = {Visualizer:New(animation)} })
			spriteEngine:insert(newParticle)
		end
		self:kill()
	--]]
	
	

		--[[self:setAnim('anchorHit')
		self.vis[1].angle = math.atan2(self.vy,self.vx)
		self.vis[1].alpha = 127
		self.anchorRadii = false
		self.isActive = false
		self.vx = 0
		self.vy = 0	--]]
		if p.anchor and p.anchor.target == self then
			local thisAnchor = p.anchor
			spriteEngine:DoAll('disconnect')
			--thisAnchor:kill()
		end
		--self.deathTimer = 1
  end
  if not self.isActive then
		self.vis[1].alpha = math.min(1, self.lifetime-self.vis[1].timer)*255
		if self.vis[1].timer > self.lifetime then
				self:kill()
		end
  end
end


--[[
 if self.collisionResult > 0 then
		self:playSound('shurikenHit')
		self:setAnim('shurikenDead')
		self.vx = 0
		self.vy = 0	
		self.rotationVelocity = 0
  else
  	self.vis[1].angle = self.vis[1].angle + self.rotationVelocity*dt
		if self.vis[1].animation == 'shuriken' and not self.dead then
			self:haveSound('shurikenFly')
		end
		if self:touchPlayer() and self.vis[1].animation == 'shuriken' and not p.dead then
			p:kill()
			self:playSound('shurikenDeath')
			levelEnd:addDeath("death_shuriken")
			objectClasses.Meat:spawn(self.x,self.y,self.vx,self.vy,12)
		end
		if self.vis[1].animation == 'shurikenDead' then
			self.vis[1].alpha = math.min(1, self.lifetime-self.vis[1].timer)*255
			if self.vis[1].timer > self.lifetime then
				self:kill()
			end
		end
--]]
function Anchor:onKill()
	if p.anchor and p.anchor.target == self then
		spriteEngine:DoAll('disconnect')
	end
end

return Anchor
