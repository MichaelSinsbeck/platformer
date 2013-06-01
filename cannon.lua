Cannon = object:New({
  radius2 = 20^2,
  firerate = .5, -- in seconds
  rotating = true,
  timeleft = 0,
  velocity = 15,
  img = love.graphics.newImage('images/cannon.png'),
  marginx = 0.4,
  marginy = 0.4
})

function Cannon:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  self.timeleft = self.timeleft - dt
  if self.timeleft < 0 then self.timeleft = 0 end
  
  if lineOfSight(self.x,self.y,p.x,p.y) then
  
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
