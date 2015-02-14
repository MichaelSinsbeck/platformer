local FixedCannon = object:New({
	tag = 'Fixedcannon',
	category = 'Enemies',
  --firerate = 1.2, -- in seconds
  --velocity = 15,
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  solid = true,
  vis = {
		Visualizer:New('shuriken'),
		Visualizer:New('fixedcannon')
	},
	properties = {
		angle = utility.newCycleProperty({0, 1, 2, -1}, {'right', 'down', 'left', 'up'}),
		firerate = utility.newProperty({.4, .6, .8, 1, 1.2, 1.4, 1.6, 1.8, 2},nil,5),
		phase = utility.newCycleProperty({0, .1, .2, .3, .4, .5, .6, .7, .8, .9}),
		velocity = utility.newCycleProperty({5,10,15,20},{'slow','semi-slow', 'normal', 'fast'},3),
		ammo = utility.newCycleProperty({'Shuriken','Anchor'}),
	},
})

function FixedCannon:applyOptions()
	self.vis[2].angle = self.angle*0.5*math.pi
	self.vis[1].timer = self.firerate*self.phase
	
	if self.ammo == 'Shuriken' then
		self:setAnim('shuriken',false,1)
	else
		self:setAnim('anchor',false,1)
	end
end

function FixedCannon:setAcceleration(dt)
	self.vis[1].angle = self.vis[1].angle + 5*dt
  
  if self.vis[1].timer > self.firerate then
		self.vis[1].timer = self.vis[1].timer - self.firerate
		local vx,vy = math.cos(self.vis[2].angle) * self.velocity, math.sin(self.vis[2].angle) * self.velocity
		local newAngle = 6.28 * math.random()
		local newShuriken = spriteFactory(self.ammo,{x=self.x,y=self.y,vx=vx,vy=vy})
		newShuriken.vis[1].angle = newAngle
		spriteEngine:insert(newShuriken)
		self:playSound('shurikenShoot')
  end
end

return FixedCannon
-- Create Cannon object for 4 directions in with 4 different phases
--[[FixedCannon1r = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 1.2}),Visualizer:New('fixedcannon',{angle = 0})}})
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
FixedCannon4d = FixedCannon:New({vis = {Visualizer:New('shuriken',{timer = 0.3}),Visualizer:New('fixedcannon',{angle = 0.5*math.pi})}})]]
