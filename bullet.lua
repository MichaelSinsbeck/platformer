Bullet = object:New({
	tag = 'bullet',
  vx = 1,
  vy = 1,
  z = -1,
  angle = 0,
  rotating = true,  
  rotationVelocity = 20,
  img = love.graphics.newImage('images/bullet.png')  ,
  marginx = 0.3,
  marginy = 0.3
})

function Bullet:setAcceleration(dt)
	self.angle = self.angle + self.rotationVelocity*dt
	if self:touchPlayer() then
    p.dead = true
  end
end

function Bullet:postStep(dt)
  if self.collisionResult then
		local deadThing = Shuriken:New({x=self.x,y=self.y,angle=self.angle})
		spriteEngine:insert(deadThing)
    self:kill()
  end
end
