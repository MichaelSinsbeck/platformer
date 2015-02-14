local Goalie = object:New({
	tag = 'Goalie',
	category = 'Enemies',
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
  zoomState = 0,
  vis = {
		Visualizer:New('goalie'),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  },
	properties = {
		direction = utility.newCycleProperty({0, .5, 1, -.5}, {'vertical', 'diagonal1','horizontal','diagonal2'}),
	},
	anchorRadii = {.45,.45},
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
  
  self.oldCollisionResult = self.collisionResult
end

function Goalie:postStep(dt)
	if self.collisionResult > 0 and self.oldCollisionResult == 0 then
		self:playSound('goalieCollide')
	end
	
	  -- show crosshairs
  if self.anchorRadii then
		if self.isCurrentTarget then
			self.zoomState = math.min(self.zoomState + 5*dt,1)
		else
			self.zoomState = math.max(self.zoomState - 7*dt,0)
		end
		local s = utility.easingOvershoot(self.zoomState)

		self.vis[2].angle = self.vis[2].angle + dt
		self.vis[2].sx = s
		self.vis[2].sy = s 
	end
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p:kill()
    levelEnd:addDeath("death_goalie")
    objectClasses.Meat:spawn(p.x,p.y,self.vx,self.vy,12)
    self:playSound('goalieDeath')
  end
end

function Goalie:onKill()
	if p.anchor and p.anchor.target == self then
		spriteEngine:DoAll('disconnect')
	end
end

return Goalie
