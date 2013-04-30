Bouncer = object:New({
  targetvy = -33,
  img = love.graphics.newImage('images/bouncer.png')
})

function Bouncer:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  if dx < p.width and -dx < self.width and
     dy < p.height and -dy < self.height then
     p.vy = self.targetvy
  end
end
