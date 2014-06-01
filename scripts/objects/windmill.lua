local Windmill = object:New({
	tag = 'Windmill',
  isInEditor = true,
  --animation = 'windmillwing',
  marginx = 0,
  marginy = 0,
	rotating = true,
	angle = 0,
	ox = 12,
	oy = 98,
	z = 3,
	semiheight = 0.5,
	semiwidth = 0.5,
	properties = {
		wings = utility.newProperty({5,6,7,8},nil,3),
		speed = utility.newProperty({0,.2,.5,2},{'stopped','slow','medium','fast'},3),
	},
	vis = {Visualizer:New('windmillwing')},
	preview = Visualizer:New('windmillpreview'),	
})

function Windmill:setAcceleration(dt)
	self.angle = (self.angle + self.speed * dt)%(2*math.pi)
	self.ox = Camera.scale/5*12
	self.oy = Camera.scale/5*98
end

function Windmill:draw()
	for i=1,self.wings do
		local thisAngle = self.angle + i/self.wings*2*math.pi
			love.graphics.draw(self.vis[1]:getImage(),
			self.x*8*Camera.scale,
			self.y*8*Camera.scale,
			thisAngle,1,1,
			math.floor(self.ox),math.floor(self.oy))
	end
end

return Windmill
