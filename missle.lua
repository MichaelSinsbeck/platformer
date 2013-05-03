Missle = object:New({
  vx = 1,
  vy = 1,
  maxspeed = 20,
  seekspeed = 20,
  angle = 0,
  ox = 0.5,
  oy = 0,5,
  img = love.graphics.newImage('images/missle.png')  
})

function Missle:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y

  self.vx = self.vx - self.seekspeed*dx*dt
  self.vy = self.vy - self.seekspeed*dy*dt
  
  local speed = math.sqrt(self.vx^2+self.vy^2)
  
  if speed > self.maxspeed then
    self.vx = self.vx/speed*self.maxspeed
    self.vy = self.vy/speed*self.maxspeed
  end
  
  self.angle = math.atan2(self.vy,self.vx)
  
  -- Kill player, if touching
  if dx < p.width and -dx < self.width and
     dy < p.height and -dy < self.height then
    p.dead = true
  end
end

function Missle:draw()
  if self.img and self.width and self.height then
    love.graphics.draw(self.img,
      math.floor((self.x+self.ox)*myMap.tileSize),
      math.floor((self.y+self.oy)*myMap.tileSize),
      self.angle,
      1,1,
      self.ox*myMap.tileSize,
      self.oy*myMap.tileSize)
  end
end

function Missle:postStep(dt)
  if self.collisionResult then
    self:kill()
  end
end
