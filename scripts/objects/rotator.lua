local Rotator = object:New({
	tag = 'Rotator',
  targetv = 23,
  marginx = 0.8,
  marginy = 0.8,
  isInEditor = true,
  solid = true,
  layout = 'center',
  vis = {
		Visualizer:New('rotatorBlock'),
  }, 
	properties = {
		nArms = utility.newProperty({1,2,3,4,5}),
		rInner = utility.newProperty({1,2,3,4,5,6,7,8,9,10}),
		rOuter = utility.newProperty({1,2,3,4,5,6,7,8,9,10}),
		speed = utility.newProperty({-4,-3,-2,-1,0,1,2,3,4}),
		angle = utility.newCycleProperty({0,0.25*math.pi,0.5*math.pi,0.75*math.pi,math.pi,1.25*math.pi,1.5*math.pi,1.75*math.pi},{0,1,2,3,4,5,6,7}),
	},
  ballSpeed = 7.23,
})
	
function Rotator:applyOptions()
	-- empty list of visualizers
	for i = 2,#self.vis do
		self.vis[i] = nil
	end

	-- three Arms
	for iArm = 1,self.nArms do
		local thisAngle = iArm/self.nArms * 2 * math.pi+self.angle
		local newVis = Visualizer:New('rotatorStick')
		newVis.angle = thisAngle
		newVis:init()
		newVis.ox = 1
		newVis.sx = self.rOuter * 0.6
		self.vis[#self.vis+1] = newVis		
	end
	
	-- Cap
	local newVis = Visualizer:New('rotatorCap')	
	newVis:init()
	self.vis[#self.vis+1] = newVis
	
	-- Shurikens
	for iArm = 1,self.nArms do
		local thisAngle = iArm/self.nArms * 2 * math.pi+self.angle
		for r = self.rInner,self.rOuter do
			local newVis = Visualizer:New('shuriken')
			local sin,cos = math.sin(thisAngle), math.cos(thisAngle)
			newVis.relX = 0.6* (r-0.1) * cos
			newVis.relY = 0.6* (r-0.1) * sin
			newVis.angle = thisAngle + r^2
			newVis:init()
			self.vis[#self.vis+1] = newVis
		end
	end

end

function Rotator:setAcceleration(dt)
end

function Rotator:postStep(dt)
	self.angle = (self.angle + self.speed * dt)%(2*math.pi)
	local sx
	if self.speed >= 0 then
		sx = 1
	else
		sx = -1
	end

	local count = 2
	for iArm = 1,self.nArms do
		local thisAngle = (iArm-1)/self.nArms * 2 * math.pi
		self.vis[count].angle = thisAngle + self.angle
		count = count + 1
	end
	count = count + 1 -- skip cap
	for iArm = 1,self.nArms do
		local thisAngle = (iArm-1)/self.nArms * 2 * math.pi
		for r = self.rInner,self.rOuter do
			local sin,cos = math.sin(self.angle + thisAngle), math.cos(self.angle + thisAngle)
			self.vis[count].relX = 0.6* (r-0.1) * cos
			self.vis[count].relY = 0.6* (r-0.1) * sin
			self.vis[count].angle = self.vis[count].angle - sx * self.ballSpeed * dt
			count = count + 1
		end
	end
	
	-- check collision with player
	-- determine arm closest to player
	local dx,dy = p.x-self.x, p.y-self.y

	local dist2 = dx^2+dy^2
	if not p.dead and dist2 < (0.6*(self.rOuter+0.8))^2 and dist2 > (0.6*(self.rInner-0.8))^2 then
		dist2 = math.sqrt(dist2)
		local pAngle = math.atan2(dy,dx)
		local iSegment = math.floor((pAngle-self.angle)/(2*math.pi/self.nArms)+0.5)%self.nArms+1
		local thisAngle = (iSegment-1)/self.nArms*2*math.pi + self.angle
		local deltaAngle = (pAngle-thisAngle+math.pi)%(2*math.pi)-math.pi
		if math.cos(deltaAngle) > 0 and math.abs(dist2*math.sin(deltaAngle)) < 0.4 then
			p:kill()
			local vx = -math.sin(thisAngle) * dist2 * self.speed
			local vy =  math.cos(thisAngle) * dist2 * self.speed
			objectClasses.Meat:spawn(p.x,p.y,vx,vy,12)
		end
	end

end

return Rotator
