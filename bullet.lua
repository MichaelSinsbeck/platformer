Bullet = object:New({
  vx = 1,
  vy = 1,
  img = love.graphics.newImage('images/bullet.png')  
})

function Bullet:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y

  -- Kill player, if touching
  if dx < p.width and -dx < self.width and
     dy < p.height and -dy < self.height then
    p.dead = true
  end
end

function Bullet:postStep(dt)
  if self.collisionResult then
    self:kill()
  end
end
