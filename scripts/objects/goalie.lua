local Goalie = object:New({
	tag = 'Goalie',
	layout = 'center',
  maxSpeed = 20,
  acc = 50,
  xSensing = 7, --how far can he see?
  ySensing = 20,
	marginx = 0.6,
  marginy = 0.6,  
	--marginx = 0.4,
  --marginy = 0.65,
  isInEditor = true,
  vis = {
		Visualizer:New('goalie'),
  },
	properties = {
		direction = utility.newCycleProperty({0, .5, 1, -.5}, {'vertical', 'diagonal1','horizontal','diagonal2'}),
	},  
})

function Goalie:applyOptions()
	self.angle = self.direction*0.5*math.pi
	self.sin = math.sin(self.angle)
	self.cos = math.cos(self.angle)
	self.vis[1].angle = self.angle
end

function Goalie:setAcceleration(dt)
	local speed = - self.vx * self.sin + self.vy * self.cos
  local dx = self.x-p.x
  local dy = self.y-p.y
  
	dx,dy = self.cos*dx+self.sin*dy, -self.sin*dx+self.cos*dy
  
  if p.visible and not p.dead and math.abs(dx) < self.xSensing and math.abs(dy) < self.ySensing then
		-- run towards player
		if dy > 0 then
			speed = speed - self.acc * dt
		else
			speed = speed + self.acc * dt
		end
	else
	  -- stop moving
	  if speed > self.acc * dt then
	    speed = speed - self.acc * dt
	  elseif speed < - speed * dt then
	    speed = speed + self.acc * dt
	  else
	    speed = 0
	  end
	end
  
  if speed < -self.maxSpeed then
    speed = -self.maxSpeed
  end
  if speed > self.maxSpeed then
    speed = self.maxSpeed
  end
  
	self.vis[1].sx = 1 - 0.2* math.abs(speed)/self.maxSpeed
	self.vis[1].sy = 1/self.vis[1].sx
  
  self.vx = -self.sin*speed
  self.vy =  self.cos*speed
  
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p.dead = true
    levelEnd:addDeath("death_goalie")
    objectClasses.Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end
end

return Goalie
