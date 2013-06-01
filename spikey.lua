Spikey = object:New({
  maxSpeed = 20,
  acc = 50,
  xSensing = 20, --how far can he see?
  ySensing = 7,
  img = love.graphics.newImage('images/spikey.png'),
  marginx = 0.8,
  marginy = 0.8
})

function Spikey:setAcceleration(dt)
	if self:touchPlayer() then  -- Kill player, if touching
    p.dead = true
  end
end
