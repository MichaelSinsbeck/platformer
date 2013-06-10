Missile = object:New({
  vx = 1,
  vy = 1,
  maxspeed = 18,--30,
  seekspeed = 80,--55,
  rotating = true,
--  ox = 0.75,
--  oy = 0.5,
  z = -1,
  img = love.graphics.newImage('images/missile.png'),
  marginx = 0.4,
  marginx = 0.4
})

function Missile:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  local distance = math.sqrt(dx*dx+dy*dy)
  
  self.vx = self.vx - self.seekspeed*dx/distance*dt
  self.vy = self.vy - self.seekspeed*dy/distance*dt
  
  local speed = math.sqrt(self.vx^2+self.vy^2)
  
  if speed > self.maxspeed then
    self.vx = self.vx/speed*self.maxspeed
    self.vy = self.vy/speed*self.maxspeed
  end
  
  self.angle = math.atan2(self.vy,self.vx)
  
	if self:touchPlayer(dx,dy) then
    p.dead = true
  end
end

--[[function Missile:draw()
  if self.img and self.width and self.height then
    love.graphics.draw(self.img,
      math.floor((self.x)*myMap.tileSize)+self.ox*self.width*myMap.tileSize,
      math.floor((self.y)*myMap.tileSize)+self.oy*self.height*myMap.tileSize,
      self.angle,
      1,1,
      self.ox*self.width*myMap.tileSize,
      self.oy*self.height*myMap.tileSize)
  end
end--]]

function Missile:postStep(dt)
  if self.collisionResult then
  	local newExplo = Explosion:New({x=self.x,y=self.y})
		spriteEngine:insert(newExplo)
    self:kill()
  end
end
