local Spawner = object:New({
	tag = 'Spawner',
	category = 'Enemies',
  firerate = 3, -- in seconds
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  timer = 3,
  solid = true,
  vis = {
		Visualizer:New('spawnerback'),
		Visualizer:New('spawnerbar'),
		Visualizer:New('spawnerfront'),
	},
	properties = {
		direction = utility.newCycleProperty({"left", "right"},nil),
	}
})

function Spawner:setAcceleration(dt)
end

function Spawner:postStep(dt)
	self.timer = self.timer + dt
	if self.timer > self.firerate then --spawn new enemy
		self.timer = self.timer - self.firerate
		
		local direction = 1
		if self.left then direction = -1 end
		local newWalker = objectClasses.Walker:New({x=self.x,y=self.y,vx = 0, direction = direction})
		spriteEngine:insert(newWalker)
		self:playSound('spawnWalker')
	end
	
	local t = self.timer/self.firerate
	self.vis[2].sx = t*0.9
	self.vis[2].relX = -0.45+0.5*self.vis[2].sx
end

--SpawnerLeft = Spawner:New({left = true})
function Spawner:applyOptions()
	if self.direction == "left" then
		self.left = true
	else
		self.left = false
	end
end

return Spawner
