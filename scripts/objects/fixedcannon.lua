FixedCannon = object:New({
	tag = 'Fixed Cannon',

  firerate = 1.5, -- in seconds
  velocity = 15,
  animation = 'shuriken',
  marginx = .8,
  marginy = .8,
  sonAnimation = 'fixedcannon',
  sonAngle = 0,
  angle = -0.5*math.pi,
})

function FixedCannon:setAcceleration(dt)
	self.angle = self.angle + 5*dt
  
  if self.timer > self.firerate then
		self.timer = self.timer - self.firerate
		local vx,vy = math.cos(self.sonAngle) * self.velocity, math.sin(self.sonAngle) * self.velocity
		local newAngle = 6.28 * math.random()
		local newShuriken = Shuriken:New({x=self.x,y=self.y,vx=vx,vy=vy,angle=newAngle})
		spriteEngine:insert(newShuriken)	
  end
end

-- Create Cannon object for 4 directions in with two different delays
FixedCannon1r = FixedCannon:New({timer = 0   ,sonAngle = 0})
FixedCannon2r = FixedCannon:New({timer = 0.75,sonAngle = 0})
FixedCannon1u = FixedCannon:New({timer = 0   ,sonAngle = -0.5*math.pi})
FixedCannon2u = FixedCannon:New({timer = 0.75,sonAngle = -0.5*math.pi})
FixedCannon1l = FixedCannon:New({timer = 0   ,sonAngle = math.pi})
FixedCannon2l = FixedCannon:New({timer = 0.75,sonAngle = math.pi})
FixedCannon1d = FixedCannon:New({timer = 0   ,sonAngle = 0.5*math.pi})
FixedCannon2d = FixedCannon:New({timer = 0.75,sonAngle = 0.5*math.pi})
