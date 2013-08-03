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
	spreadSpeed  = 20,
	particleRotSpeed = 5,
})

function Shuriken:setAcceleration(dt)
	self.angle = self.angle + self.rotationVelocity*dt
	if self:touchPlayer() and self.animation == 'shuriken' and not p.dead then
    p.dead = true
    Meat:spawn(self.x,self.y,self.vx,self.vy,12)
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
