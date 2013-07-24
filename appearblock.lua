Appearblock = object:New({
	tag = 'appearblock',
  marginx = 0.8,
  marginy = 0.8,
  animation = 'appearBlockNotThere',
})

function Appearblock:setAcceleration(dt)
  
end

function Appearblock:buttonPress()
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

Disappearblock = Appearblock:New({
	tag = 'Disappearblock',
	animation = 'appearBlockThere',
})
