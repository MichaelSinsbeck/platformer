Launcher = object:New({
	tag = 'Shuriken Launcher',
  radius2 = 20^2,
  firerate = 0.2,--.5, -- in seconds
  rotating = true,
  timeleft = 0,
  velocity = 15,
  img = love.graphics.newImage('images/launcher.png'),
  marginx = .8,
  marginy = .8,
  sonImg = love.graphics.newImage('images/launcherSon.png'),
  sonAngle = 0,
})

function Launcher:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  self.timeleft = self.timeleft - dt
  if self.timeleft < 0 then self.timeleft = 0 end
  
  if lineOfSight(self.x,self.y,p.x,p.y) then
  
    self.angle = math.atan2(dy,dx)    
    if self.timeleft == 0 then --shoot
			local vx = -self.velocity*math.cos(self.angle)
			local vy = -self.velocity*math.sin(self.angle)
			local newAngle = math.random()*math.pi*2
			local newShuriken = Shuriken:New({x=self.x,y=self.y,vx=vx,vy=vy,angle=newAngle})
			spriteEngine:insert(newShuriken)
			self.timeleft = self.firerate
    end
  end
  self.sonAngle = self.sonAngle + 5*dt
end
