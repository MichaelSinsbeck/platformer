Shuriken = object:New({
	tag = 'bullet',
  vx = 1,
  vy = 1,
  z = -1,
  angle = 0,
  rotating = true,  
  rotationVelocity = 20,
  marginx = 0.3,
  marginy = 0.3,
  lifetime = 1.5,
	spreadSpeed  = 20,
	particleRotSpeed = 5,
	vis = {Visualizer:New('shuriken')},
})

function Shuriken:setAcceleration(dt)
	self.vis[1].angle = self.vis[1].angle + self.rotationVelocity*dt
	if self:touchPlayer() and self.vis[1].animation == 'shuriken' and not p.dead then
    p.dead = true
    levelEnd:addDeath("death_shuriken")
    Meat:spawn(self.x,self.y,self.vx,self.vy,12)
  end
  if self.vis[1].animation == 'shurikenDead' then
    self.vis[1].alpha = math.min(1, self.lifetime-self.vis[1].timer)*255
		if self.vis[1].timer > self.lifetime then
			self:kill()
		end
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
