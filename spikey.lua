Spikey = object:New({
  maxSpeed = 20,
  acc = 50,
  xSensing = 20, --how far can he see?
  ySensing = 7,
  img = love.graphics.newImage('spikey.png')
})

function Spikey:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y

  -- Kill player, if touching
  if dx < p.width and -dx < self.width and
     dy < p.height and -dy < self.height then
    p.dead = true
  end
end
