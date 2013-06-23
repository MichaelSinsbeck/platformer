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
  marginy = 0.3
})

function Shuriken:setAcceleration(dt)
	self.angle = self.angle + self.rotationVelocity*dt
	if self:touchPlayer() and self.animation == 'shuriken' then
    p.dead = true
  end
	if self.animation == 'shurikenDead' and self.frame == 5 then
    self:kill()
	end  
end

function Shuriken:postStep(dt)
  if self.collisionResult then
		self:setAnim('shurikenDead')
		self.vx = 0
		self.vy = 0	
		self.rotationVelocity = 0
		--local deadThing = Shuriken:New({x=self.x,y=self.y,angle=self.angle})
		--spriteEngine:insert(deadThing)
    --self:kill()
  end
end
