Cannon = object:New({
	tag = 'cannon',
  radius2 = 20^2,
  firerate = 1,--1.5, -- in seconds
  rotating = true,
  timeleft = 0,
  velocity = 10,
  img = love.graphics.newImage('images/cannon.png'),
  frame = 3
})

function Cannon:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  self.timeleft = self.timeleft - dt
  if self.timeleft < 0 then self.timeleft = 0 end
  
  if p.visible and lineOfSight(self.x,self.y,p.x,p.y) then
		self.angle = math.atan2(dy,dx)										    
    if self.timeleft == 0 then --shoot
			local vx = -self.velocity*math.cos(self.angle)
			local vy = -self.velocity*math.sin(self.angle)
			local newBullet = Missile:New({x=self.x,y=self.y,vx=vx,vy=vy})
			spriteEngine:insert(newBullet)
			self.timeleft = self.firerate
			self:resetAnimation()
    end
  end
end
