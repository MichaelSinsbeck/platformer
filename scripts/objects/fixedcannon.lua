FixedCannon = object:New({
	tag = 'Fixed Cannon',
  firerate = 1.2, -- in seconds
  velocity = 15,
  marginx = .8,
  marginy = .8,
  angle = -0.5*math.pi,
  delay = 0,
  solid = true,
  vis = {
		Visualizer:New('shuriken'),
		Visualizer:New('fixedcannon')
	},
	properties = {
		angle = newCycleProperty({0, 0.5*math.pi, math.pi, -0.5*math.pi}, {'right', 'down', 'left', 'up'}),
		firerate = newProperty({.4, .6, .8, 1, 1.2, 1.4}),
		delay = newProperty({0, .2 , .4 , .6 , .8})
	},
})

function FixedCannon:applyOptions()
	self.vis[2].angle = self.angle
	self.vis[1].timer = self.firerate*self.delay
end

function FixedCannon:setAcceleration(dt)
	self.vis[1].angle = self.vis[1].angle + 5*dt
  
  if self.vis[1].timer > self.firerate then
		self.vis[1].timer = self.vis[1].timer - self.firerate
		local vx,vy = math.cos(self.vis[2].angle) * self.velocity, math.sin(self.vis[2].angle) * self.velocity
		local newAngle = 6.28 * math.random()
		local newShuriken = Shuriken:New({x=self.x,y=self.y,vx=vx,vy=vy,angle=newAngle})
		spriteEngine:insert(newShuriken)	
  end
end

-- Create Cannon object for 4 directions in with 4 different delays
FixedCannon1r = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 1.2}),Visualizer:New('fixedcannon',{angle = 0})}})
FixedCannon2r = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.9}),Visualizer:New('fixedcannon',{angle = 0})}})
FixedCannon3r = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.6}),Visualizer:New('fixedcannon',{angle = 0})}})
FixedCannon4r = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.3}),Visualizer:New('fixedcannon',{angle = 0})}})

FixedCannon1u = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 1.2}),Visualizer:New('fixedcannon',{angle = -0.5*math.pi})}})
FixedCannon2u = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.9}),Visualizer:New('fixedcannon',{angle = -0.5*math.pi})}})
FixedCannon3u = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.6}),Visualizer:New('fixedcannon',{angle = -0.5*math.pi})}})
FixedCannon4u = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.3}),Visualizer:New('fixedcannon',{angle = -0.5*math.pi})}})

FixedCannon1l = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 1.2}),Visualizer:New('fixedcannon',{angle = math.pi})}})
FixedCannon2l = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.9}),Visualizer:New('fixedcannon',{angle = math.pi})}})
FixedCannon3l = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.6}),Visualizer:New('fixedcannon',{angle = math.pi})}})
FixedCannon4l = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.3}),Visualizer:New('fixedcannon',{angle = math.pi})}})

FixedCannon1d = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 1.2}),Visualizer:New('fixedcannon',{angle = 0.5*math.pi})}})
FixedCannon2d = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.9}),Visualizer:New('fixedcannon',{angle = 0.5*math.pi})}})
FixedCannon3d = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.6}),Visualizer:New('fixedcannon',{angle = 0.5*math.pi})}})
FixedCannon4d = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.3}),Visualizer:New('fixedcannon',{angle = 0.5*math.pi})}})
