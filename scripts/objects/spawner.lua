local Spawner = object:New({
	tag = 'Spawner',
	category = 'Enemies',
  --firerate = 3, -- in seconds
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  --timer = 3,
  solid = true,
  vis = {
		Visualizer:New('spawnerback'),
		Visualizer:New('spawnerbar'),
		Visualizer:New('spawnerfront'),
		Visualizer:New('spawnersymbolenemy')
	},
	properties = {
		type = utility.newCycleProperty({'enemy','bouncy','anchor'}),	
		direction = utility.newCycleProperty({"left", "right"},nil),
		strength = utility.newCycleProperty({16,23},{'weak','strong'},2),
		spawnTime = utility.newNumericTextProperty( 3, 0.1, math.huge ),
		phase = utility.newNumericTextProperty( 1, 0, 1),
	}
})

--SpawnerLeft = Spawner:New({left = true})
function Spawner:applyOptions()
	self:setAnim('spawnersymbol' .. self.type ,true,4)

	if self.direction == "left" then
		self.left = true
	else
		self.left = false
	end
	self.timer = self.spawnTime*self.phase
end

function Spawner:setAcceleration(dt)
end

function Spawner:postStep(dt)
	self.timer = self.timer + dt
	if self.timer > self.spawnTime then --spawn new enemy
		self.timer = self.timer - self.spawnTime
		
		local direction = 1
		if self.left then direction = -1 end
		local newWalker = objectClasses.Walker:New({x=self.x,y=self.y,vx = 0, direction = direction, type = self.type,strength = self.strength})
		spriteEngine:insert(newWalker)
		self:playSound('spawnWalker')
	end
	
	local t = self.timer/self.spawnTime
	self.vis[2].sx = t*0.9
	self.vis[2].relX = -0.45+0.5*self.vis[2].sx
end

return Spawner
