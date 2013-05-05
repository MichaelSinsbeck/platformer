Bouncer = object:New({
  targetvy = -33,
  img = love.graphics.newImage('images/bouncer.png')
})

function Bouncer:setAcceleration(dt)
	if self:touchPlayer() then
     p.vy = self.targetvy
  end
end
