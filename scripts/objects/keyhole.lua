local Keyhole = object:New({
	tag = 'Keyhole',
	category = 'Interactive',
	category = 'Interactive',
  marginx = 0.8,
  marginy = 0.8,
  isInEditor = true,
  status = 'passive',
  openTime = 0.05,	
	solid = true,	
	vis = {Visualizer:New('keyhole')},
})

function Keyhole:setAcceleration(dt)
end

function Keyhole:activate(args)
end

function Keyhole:postStep(dt)
	if self.status == 'passive' and
		 p.nKeys > 0 and
		 math.abs(self.x-p.x) <= self.semiwidth+p.semiwidth and
		 math.abs(self.y-p.y) <= self.semiheight+p.semiheight then
		self.status = 'active'
		self.vis[1].timer = 0
		myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
		myMap:queueShadowUpdate()
		p.nKeys = p.nKeys - 1
		self:playSound('doorOpen')
	elseif self.status == 'active' and self.vis[1].timer > self.openTime then
		spriteEngine:DoAll('activate',{t=self.vis[1].timer-self.openTime,x=self.x,y=self.y})
		self:die()
	end
end

function Keyhole:die()
	myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
	self:kill()
	myMap:queueShadowUpdate()
end

return Keyhole
