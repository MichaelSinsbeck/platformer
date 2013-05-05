Cannon = object:New({
  radius2 = 20^2,
  firerate = .2, -- in seconds
  rotating = true,
  timeleft = 0,
  velocity = 15,
  img = love.graphics.newImage('images/cannon.png')
  
})

function Cannon:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  self.timeleft = self.timeleft - dt
  if self.timeleft < 0 then self.timeleft = 0 end
  
  if dx*dx+dy*dy < self.radius2 then
    self.angle = math.atan2(dy,dx)
    
    if self.timeleft == 0 then --shoot
			local vx = -self.velocity*math.cos(self.angle)
			local vy = -self.velocity*math.sin(self.angle)
			local newBullet = Bullet:New({x=self.x,y=self.y,vx=vx,vy=vy})
			spriteEngine:insert(newBullet)
			self.timeleft = self.firerate
    end
  end
end
