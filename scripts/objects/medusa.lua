local Medusa = object:New({
	tag = 'Medusa',
	category = "Enemies",
	layout = 'center',
  marginx = 0.6,
  marginy = 0.6,
  isInEditor = true,  
	vis = {Visualizer:New('medusa')},
	timer = 0,
	properties = {
		amplitude = utility.newCycleProperty({0,1,2,3,4,5},nil,3),
		period = utility.newProperty({2,2.5,3,3.5,4}),
		velocity = utility.newProperty({-4,-3,-2,-1,0,1,2,3,4},nil,3),
		phase = utility.newCycleProperty({0,0.25,0.5,0.75}),
	},  
})

function Medusa:applyOptions()
	if self.velocity >= 0 then
		self.vis[1].sx = 1
	else
		self.vis[1].sx = -1
	end
end

-- Medusa does not have collision, so overwrite update
function Medusa:update(dt)
	if self.size then
		self.size = math.min(self.size + dt,1)
		self.vis[1].sy = self.size
		if self.velocity >= 0 then
			self.vis[1].sx = self.size
		else
			self.vis[1].sx = -self.size
		end
	end
		
	
	self.startX = self.startX or self.x
	self.startY = self.startY or self.y

	self.timer = self.timer + dt
	self.x = self.startX + self.velocity * self.timer
	self.y = self.startY + math.sin(2*math.pi*self.timer/self.period+2*self.phase*math.pi)*self.amplitude
	
	if self.vis then
		for i = 1,#self.vis do
			self.vis[i]:update(dt)
		end	
	end
	
	if self:touchPlayer() and not p.dead then
		p.dead = true
		levelEnd:addDeath("death_medusa")
		local vx = self.velocity
		local vy = self.amplitude*math.cos(2*math.pi*self.timer/self.period+2*self.phase*math.pi)*2*math.pi/self.period
		objectClasses.Meat:spawn(p.x,p.y,vx,vy,12)
	end
end

return Medusa
