Keyhole = Door:New({
	tag = 'keyhole',
  marginx = 0.8,
  marginy = 0.8,
  animation = 'keyhole',
  spreadSpeed = 8,  -- For explosion
  particleRotSpeed = 5, -- For explosion  
})

function Keyhole:activate(args)
end

function Keyhole:postStep(dt)
	if p.nKeys > 0 and
		 math.abs(self.x-p.x) <= self.semiwidth+p.semiwidth and
		 math.abs(self.y-p.y) <= self.semiheight+p.semiheight then
		p.nKeys = p.nKeys - 1
		spriteEngine:DoAll('activate',{t=0,x=self.x,y=self.y})
		self:die()
	end
end
