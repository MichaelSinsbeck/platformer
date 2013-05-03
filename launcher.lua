Launcher = object:New({
  radius2 = 20^2,
  firerate = 1.5, -- in seconds
  angle = 0,
  ox = .5,
  oy = 0.5,
  timeleft = 0,
  velocity = 10,
  img = love.graphics.newImage('images/launcher.png')
  
})

function Launcher:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  self.timeleft = self.timeleft - dt
  if self.timeleft < 0 then self.timeleft = 0 end
  
  if dx*dx+dy*dy < self.radius2 then
    self.angle = math.atan2(dy,dx)
    
    if self.timeleft == 0 then --shoot
			local vx = -self.velocity*math.cos(self.angle)*0
			local vy = -self.velocity*math.sin(self.angle)*0
			local x = self.x+self.ox*self.width-0.5*15/20
			local y = self.y+self.oy*self.height-0.5*8/20
			local newBullet = Missle:New({x=x,y=y,vx=vx,vy=vy})
			spriteEngine:insert(newBullet)
			self.timeleft = self.firerate
    end
  end
end

function Launcher:draw()
  if self.img and self.width and self.height then
    love.graphics.draw(self.img,
      math.floor((self.x+self.ox*self.width)*myMap.tileSize),
      math.floor((self.y+self.oy*self.height)*myMap.tileSize),
      self.angle,
      1,1,
      self.ox*self.width*myMap.tileSize,
      self.oy*self.height*myMap.tileSize)
  end
end
