Cannon = object:New({
  radius2 = 20^2,
  firerate = .2, -- in seconds
  angle = 0,
  ox = .75,
  oy = .5,
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
			local newBullet = Bullet:New({x=self.x+self.ox-Bullet.width/2,y=self.y+self.oy-Bullet.height/2,vx=vx,vy=vy})
			spriteEngine:insert(newBullet)
			self.timeleft = self.firerate
    end
  end
end

function Cannon:draw()
  if self.img and self.width and self.height then
    love.graphics.draw(self.img,
      math.floor((self.x+self.ox)*myMap.tileSize),
      math.floor((self.y+self.oy)*myMap.tileSize),
      self.angle,
      1,1,
      self.ox*myMap.tileSize,
      self.oy*myMap.tileSize)
  end
end
