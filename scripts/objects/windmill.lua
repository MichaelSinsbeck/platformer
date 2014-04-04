local Windmill = object:New({
	tag = 'Windmill',
  isInEditor = true,
  --animation = 'windmillwing',
  marginx = 0,
  marginy = 0,
	rotating = true,
	angle = 0,
	vRot = .5,
	nWings = 7,
	ox = 12,
	oy = 98,
	semiheight = 0.5,
	semiwidth = 0.5,
	vis = {Visualizer:New('windmillwing')},
})

function Windmill:setAcceleration(dt)
	self.angle = (self.angle + self.vRot * dt)%(2*math.pi)
	self.ox = Camera.scale/5*12
	self.oy = Camera.scale/5*98
end

function Windmill:draw()
	for i=1,self.nWings do
		local thisAngle = self.angle + i/self.nWings*2*math.pi
			love.graphics.draw(self.vis[1].img,
			self.x*myMap.tileSize,
			self.y*myMap.tileSize,
			thisAngle,1,1,
			math.floor(self.ox),math.floor(self.oy))
	end
end

return Windmill
