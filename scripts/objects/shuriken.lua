local Shuriken = object:New({
	tag = 'Shuriken',
	category = 'Enemies',
  vx = 1,
  vy = 1,
  z = -1,
  angle = 0,
  rotating = true,  
  rotationVelocity = 10,
  marginx = 0.3,
  marginy = 0.3,
  lifetime = 1.5,
	spreadSpeed  = 20,
	particleRotSpeed = 5,
	vis = {Visualizer:New('shuriken')},
})

function Shuriken:setAcceleration(dt)
end

function Shuriken:postStep(dt)
  if self.collisionResult > 0 then
		self:playSound('shurikenHit',1,1,0.03)
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
  end
end

return Shuriken
