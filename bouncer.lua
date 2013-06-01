Bouncer = object:New({
  targetvy = -22,
  img = love.graphics.newImage('images/bouncer.png'),
  marginx = 0.8,
  marginy = 0.2
})

function Bouncer:setAcceleration(dt)
	if self:touchPlayer() then
     p.vy = self.targetvy
  end
end
