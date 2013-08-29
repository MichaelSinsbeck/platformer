Keyhole = Door:New({
	tag = 'keyhole',
  animation = 'keyhole',
})

function Keyhole:activate(args)
end

function Keyhole:postStep(dt)
	if self.status == 'passive' and
		 p.nKeys > 0 and
		 math.abs(self.x-p.x) <= self.semiwidth+p.semiwidth and
		 math.abs(self.y-p.y) <= self.semiheight+p.semiheight then
		self.status = 'active'
		self.timer = 0
		myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
		p.nKeys = p.nKeys - 1
	elseif self.status == 'active' and self.timer > self.openTime then
		spriteEngine:DoAll('activate',{t=self.timer-self.openTime,x=self.x,y=self.y})
		self:die()
	end
end
