local Sweeper = object:New({
	tag = 'Sweeper',
	category = "Enemies",
  targetv = 23,
  marginx = 0.8,
  marginy = 0.8,
  isInEditor = true,
  solid = true,
  layout = 'center',
  vis = {
		Visualizer:New('rotatorStick'),
  },
  preview = Visualizer:New('shurikenlarge'),	
  speed = 5,
	properties = {
		height = utility.newIntegerProperty(5,1,60),
	},  
})
	
function Sweeper:applyOptions()

	self.vis[1].sx = self.height
	self.vis[1].angle = 0.5 * math.pi
	self.vis[1].relY = self.height/2
	
	-- empty list of visualizers
	for i = 2,#self.vis do
		self.vis[i] = nil
	end
	self.directions = {}
	for iShuriken = 0, self.height do
		local thisAngle = love.math.random()*2*math.pi
		local newVis = Visualizer:New('shurikenlarge') 
		newVis.angle = thisAngle
		newVis.relY = iShuriken
		newVis:init()
		local idx = #self.vis+1
		self.vis[idx] = newVis 
		
		
		local dir = 10*(love.math.random()*0.5 + 0.75)
		if love.math.random() < 0.5 then dir = - dir end
		self.directions[idx] = dir
	end

end

function Sweeper:setAcceleration(dt)
end

function Sweeper:postStep(dt)
	self.x = self.x + self.speed * dt
	for i=2,#self.vis do
		--self.vis[i].angle = self.vis[i].angle - 10*dt 
		self.vis[i].angle = self.vis[i].angle - self.directions[i] * dt 
	end
end

function Sweeper:postpostStep(dt)
	local dx,dy = p.x - self.x, p.y - self.y
	if math.abs(dx) < p.semiwidth + 0.5 and
	   dy > -0.5 - p.semiheight and
	   dy < 0.5 + self.height + p.semiheight and
	   not p.dead then
	   
	  p:kill()
		objectClasses.Meat:spawn(p.x,p.y,2*self.speed,-2*self.speed,12)
	end
end

return Sweeper
