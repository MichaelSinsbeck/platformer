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
		--speed = utility.newProperty({0,.2,.5,2},{'stopped','slow','medium','fast'},3),
		speed = utility.newNumericTextProperty( 0.2, -2, 2 )
	},
	vis = {Visualizer:New('windmillwing')},
	preview = Visualizer:New('windmillpreview'),	
})

function Windmill:applyOptions()
	self.vis = {}
	for i=1,self.wings do
		local newVis = Visualizer:New('windmillwing')
		
		newVis:init()
		newVis.angle = self.angle + i/self.wings*2*math.pi
		newVis.ox = 2.5
		newVis.oy = 20
		
		self.vis[i] = newVis
	end
	self.vis[self.wings+1] = Visualizer:New('rotatorCap')
	self.vis[self.wings+1]:init()
end

function Windmill:setAcceleration(dt)
	self.angle = (self.angle + self.speed * dt)%(2*math.pi)
	for i=1,self.wings do
		self.vis[i].angle = self.angle + i/self.wings*2*math.pi
	end
	self.vis[self.wings+1].angle = self.angle
end

--[[function Windmill:draw()
	for i=1,self.wings do
		local thisAngle = self.angle + i/self.wings*2*math.pi
			love.graphics.draw(self.vis[1]:getImage(),
			self.x*8*Camera.scale,
			self.y*8*Camera.scale,
			thisAngle,1,1,
			math.floor(self.ox),math.floor(self.oy))
	end
end--]]

return Windmill
