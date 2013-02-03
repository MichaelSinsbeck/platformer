Player = {
  x = 0,
  y = 0,
  vx = 0,
  vy = 0,
  height = 1,
  width = 1,
  status = '',
  walkSpeed = 20,
  jumpSpeed = -20,
  unjumpSpeed = 12
  }

function Player:New(input)
  local o = input or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Player:setImage(filename)
  self.img = love.graphics.newImage(filename)
  self.width = self.img:getWidth()/myMap.tileSize
  self.height = self.img:getHeight()/myMap.tileSize
end

function Player:draw()
  if self.img then
  love.graphics.draw(self.img,math.floor(self.x*myMap.tileSize),math.floor(self.y*myMap.tileSize))
  end
end

function Player:jump()
  if self.status == 'stand' then
    self.status = 'jump'
    self.vy = self.jumpSpeed
  end
end

function Player:unjump()
	if self.status == 'fly' and self.vy < 0 then
		if self.vy < -self.unjumpSpeed then
			self.vy = self.vy + self.unjumpSpeed
		else
			self.vy = 0
		end
	end
end

function Player:update(dt)
  self.status = 'fly'
  self.tvx = 0
  if love.keyboard.isDown('left') then
    self.tvx = self.tvx - self.walkSpeed
  end
  if love.keyboard.isDown('right') then
    self.tvx = self.tvx + self.walkSpeed
  end
  -- Das hier muss noch schlauer gemacht werden!!
  self.vx = self.vx +0.1*(self.tvx-self.vx)
  self.vy = self.vy + gravity*dt

  -- Horizontale Bewegung und Kollisionskontrolle
  local newX = self.x + self.vx*dt
  
  if self.vx > 0 then -- Bewegung nach rechts
    -- haben die rechten Eckpunkte die Zelle gewechselt?
    if math.floor(self.x+self.width*0.99) ~= math.floor(newX+self.width*0.99) then
      -- Kollision in neuen Feldern?
      if myMap.collision[math.floor(newX+self.width)] and
      (myMap.collision[math.floor(newX+self.width*0.99)][math.floor(self.y)] or
        myMap.collision[math.floor(newX+self.width*0.99)][math.floor(self.y+0.99)]) then
        newX = math.floor(newX+self.width)-self.width
        self.vx = math.min(self.vx,0)
      end
    end
  elseif self.vx < 0 then -- Bewegung nach links
    -- Eckpunkte wechseln Zelle?
    if math.floor(self.x) ~= math.floor(newX) then
      if myMap.collision[math.floor(newX)] and
      (myMap.collision[math.floor(newX)][math.floor(self.y)] or
       myMap.collision[math.floor(newX)][math.floor(self.y+0.99)]) then
        newX = math.floor(newX+1)
        self.vx = math.max(self.vx,0)
      end
    end
  end  
  self.x = newX
  
  local newY = self.y + self.vy*dt
  if self.vy < 0 then -- rising
    if math.floor(self.y) ~= math.floor(newY) then
      if (myMap.collision[math.floor(self.x)] and
          myMap.collision[math.floor(self.x)][math.floor(newY)])
          or
         (myMap.collision[math.floor(self.x+self.width*0.99)] and
          myMap.collision[math.floor(self.x+self.width*0.99)][math.floor(newY)]) then
        newY = math.floor(newY+1)
        self.vy = math.max(self.vy,0)
      end
    end
    
  elseif self.vy > 0 then -- falling
    if math.floor(self.y+self.height*0.99) ~= math.floor(newY+self.height*0.99) then
      if ( myMap.collision[math.floor(self.x)] and 
        myMap.collision[math.floor(self.x)][math.floor(newY+self.height*0.99)])  or
        (myMap.collision[math.floor(self.x+self.width*0.99)] and 
        myMap.collision[math.floor(self.x+self.width*0.99)][math.floor(newY+self.height*0.99)]) then
        newY = math.floor(newY+self.height*0.99)-1---self.height*0.99-1
        
        self.vy = math.min(self.vy,0)
        self.status = 'stand'
      end
    end
  end
  self.y = newY
end

return Player
