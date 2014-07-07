local FlameRotator = object:New({
	tag = 'FlameRotator',
  targetv = 23,
  marginx = 0.8,
  marginy = 0.8,
  isInEditor = true,
  solid = true,
  layout = 'center',
  vis = {
		Visualizer:New('flameRotator'),
  }, 
	properties = {
		nArms = utility.newProperty({1,2,3,4,5}),
		rInner = utility.newProperty({0,1,2,3,4,5,6,7,8,9,10}),
		rOuter = utility.newProperty({1,2,3,4,5,6,7,8,9,10}),
		speed = utility.newProperty({-4,-3,-2,-1,0,1,2,3,4})
	},
  speed = 1,
  angle = 0,
  ballAngle = 0,
  ballSpeed = 3.5,
  
})
	
function FlameRotator:applyOptions()
	-- empty list of visualizers
	for i = 2,#self.vis do
		self.vis[i] = nil
	end
	for iArm = 1,self.nArms do
		local thisAngle = iArm/self.nArms * 2 * math.pi
		local rStart = self.rInner
		if iArm > 1 then
			rStart = math.max(1,rStart)
		end
		for r = self.rInner,self.rOuter do
			local newVis = Visualizer:New('miniFlame')
			local sin,cos = math.sin(thisAngle), math.cos(thisAngle)
			newVis.relY = 0.5 * r * cos
			newVis.relX = 0.5 * r * sin
			newVis:init()
			self.vis[#self.vis+1] = newVis
		end
	end
end

function FlameRotator:setAcceleration(dt)
end

function FlameRotator:postStep(dt)
	self.angle = (self.angle + self.speed * dt)%(2*math.pi)
	self.ballAngle = (self.ballAngle - self.ballSpeed * dt)%(2*math.pi)
	count = 2
	for iArm = 1,self.nArms do
		local thisAngle = iArm/self.nArms * 2 * math.pi
		for r = self.rInner,self.rOuter do
			local sin,cos = math.sin(self.angle + thisAngle), math.cos(self.angle + thisAngle)
			self.vis[count].relX = 0.5 * r * cos
			self.vis[count].relY = 0.5 * r * sin
			self.vis[count].angle = self.ballAngle
			count = count + 1
		end
	end
	-- check collision with player: circle arcs
	local dx,dy = p.x-self.x,p.y-self.y
	if dx^2+dy^2 < (0.5*self.rOuter)^2 then
		for i = 2, #self.vis do
			
		end
	end

end


return FlameRotator
