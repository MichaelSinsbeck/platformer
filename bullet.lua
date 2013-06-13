Bullet = object:New({
	tag = 'bullet',
  vx = 1,
  vy = 1,
  z = -1,
  img = love.graphics.newImage('images/bullet.png')  ,
  marginx = 0.3,
  marginy = 0.3
})

function Bullet:setAcceleration(dt)
	if self:touchPlayer() then
    p.dead = true
  end
end

function Bullet:postStep(dt)
  if self.collisionResult then
		local newExplo = Explosion:New({x=self.x,y=self.y})
		spriteEngine:insert(newExplo)
    self:kill()
  end
end
