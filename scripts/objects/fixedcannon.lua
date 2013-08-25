FixedCannon = object:New({
	tag = 'Fixed Cannon',

  firerate = 1.2, -- in seconds
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
FixedCannon1r = FixedCannon:New({timer = 1.2})
FixedCannon2r = FixedCannon:New({timer = 0.9})
FixedCannon3r = FixedCannon:New({timer = 0.6})
FixedCannon4r = FixedCannon:New({timer = 0.3})

FixedCannon1u = FixedCannon1r:New({sonAngle = -0.5*math.pi})
FixedCannon2u = FixedCannon2r:New({sonAngle = -0.5*math.pi})
FixedCannon3u = FixedCannon3r:New({sonAngle = -0.5*math.pi})
FixedCannon4u = FixedCannon4r:New({sonAngle = -0.5*math.pi})

FixedCannon1l = FixedCannon1r:New({sonAngle = math.pi})
FixedCannon2l = FixedCannon2r:New({sonAngle = math.pi})
FixedCannon3l = FixedCannon3r:New({sonAngle = math.pi})
FixedCannon4l = FixedCannon4r:New({sonAngle = math.pi})

FixedCannon1d = FixedCannon1r:New({sonAngle = 0.5*math.pi})
FixedCannon2d = FixedCannon2r:New({sonAngle = 0.5*math.pi})
FixedCannon3d = FixedCannon3r:New({sonAngle = 0.5*math.pi})
FixedCannon4d = FixedCannon4r:New({sonAngle = 0.5*math.pi})
