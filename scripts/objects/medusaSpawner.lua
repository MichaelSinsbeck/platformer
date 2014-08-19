local MedusaSpawner = object:New({
	tag = 'MedusaSpawner',
	category = "Enemies",
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  timer = 0,
  solid = true,
  vis = {
		Visualizer:New('medusaSpawner'),
		Visualizer:New('medusaVortex'),
		Visualizer:New('medusa'),
	},
	properties = {
		firerate = utility.newCycleProperty({1,2,3,4,5}),
		amplitude = utility.newCycleProperty({0,1,2,3,4,5},nil,3),
		period = utility.newProperty({2,2.5,3,3.5,4}),
		velocity = utility.newProperty({-4,-3,-2,-1,1,2,3,4},nil,3),
	}, 
})

function MedusaSpawner:applyOptions()
	if self.velocity >= 0 then
		self.vis[1].sx = 1
	else
		self.vis[1].sx = -1
	end
	self.vis[3].sx = 0
	self.vis[3].sy = 0
end

function MedusaSpawner:setAcceleration(dt)
end

function MedusaSpawner:postStep(dt)
	self.timer = self.timer + dt
	if self.timer > self.firerate then --spawn new enemy
		self.timer = self.timer - self.firerate
		
		local newMedusa = spriteFactory('Medusa',{x=self.x,y=self.y,phase = 0, velocity = self.velocity,amplitude=self.amplitude,period=self.period,size=.5})
		spriteEngine:insert(newMedusa)	
	end

	self.vis[2].angle = self.vis[2].angle + dt
	self.vis[3].sx = self.vis[1].sx * 0.5*self.timer / self.firerate
	self.vis[3].sy = 0.5*self.timer / self.firerate
	

end

return MedusaSpawner
