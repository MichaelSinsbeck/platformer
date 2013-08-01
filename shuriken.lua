Shuriken = object:New({
	tag = 'bullet',
  vx = 1,
  vy = 1,
  z = -1,
  angle = 0,
  rotating = true,  
  rotationVelocity = 20,
  animation = 'shuriken',
  marginx = 0.3,
  marginy = 0.3,
  timer = 0,
  lifetime = 3,
	spreadSpeed  = 10,
	particleRotSpeed = 20,
})

function Shuriken:setAcceleration(dt)
	self.angle = self.angle + self.rotationVelocity*dt
	if self:touchPlayer() and self.animation == 'shuriken' and not p.dead then
    p.dead = true
    
		for i = 1,12 do -- spawn 6 particles
		  local angle, magnitude = math.pi*2*math.random(), 0.5+math.random()*0.5
		  local cos,sin = math.cos(angle),math.sin(angle)
		  local vx = cos*self.spreadSpeed*magnitude+0.7*self.vx
		  local vy = sin*self.spreadSpeed*magnitude+0.7*self.vy
		  local timer = -math.random()
		  local animation = 'butterflywing' .. math.random(1,3)
		  local rotSpeed = self.particleRotSpeed * (math.random()*2-1)
		  local newParticle = Butterfly:New({timer = timer,x=self.x,y=self.y,vx = vx,vy = vy,animation=animation})
		  spriteEngine:insert(newParticle)
		end    
    
  end
  if self.animation == 'shurikenDead' then
    self.timer = self.timer + dt
    self.alpha = math.min(1, self.lifetime-self.timer)*255
  end
  if self.timer > self.lifetime then
    self:kill()
  end
end

function Shuriken:postStep(dt)
  if self.collisionResult > 0 then
		self:setAnim('shurikenDead')
		self.vx = 0
		self.vy = 0	
		self.rotationVelocity = 0
  end
end
