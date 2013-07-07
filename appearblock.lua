Appearblock = object:New({
	tag = 'appearblock',
  --img = love.graphics.newImage('images/appearblock.png'),
  marginx = 0.8,
  marginy = 0.8,
  animation = 'appearBlockNotThere',
  lifetime = 2,
  timer2 = 0,
})

function Appearblock:setAcceleration(dt)
	if self.timer2*(self.timer2-dt) < 0 then
    self:invert()
  end
  self.timer2 = math.max(0,self.timer2-dt)
  
end

function Appearblock:buttonPress()
  self.timer2 = self.lifetime
  self:invert()
end

function Appearblock:invert()
  if self.animation == 'appearBlockThere' then
    self.animation = 'appearBlockNotThere'
    myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
  else
		self.animation = 'appearBlockThere'
		myMap.collision[math.floor(self.x)][math.floor(self.y)] = 1
  end
end
