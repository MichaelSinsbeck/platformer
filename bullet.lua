Bullet = object:New({
  vx = 1,
  vy = 1,
  z = -1,
  img = love.graphics.newImage('images/bullet.png')  
})

function Bullet:setAcceleration(dt)
	if self:touchPlayer() then
    p.dead = true
  end
end

function Bullet:postStep(dt)
  if self.collisionResult then
    self:kill()
  end
end