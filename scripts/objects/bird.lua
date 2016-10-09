local Bird = object:New({
	tag = 'Bird',
	category = "Misc",
  marginx = 0.4,
  marginy = 0.4,
  isInEditor = true,
  --solid = true,
  --layout = 'center',
  state = 'sitting',
  acceleration = 20,
  vxTarget = 5,
  vyTarget = -10,
  direction = 1,
  vis = {
		Visualizer:New('birdStand1'),
  },
	properties = {
		type = utility.newCycleProperty({'1','2'}),
	},  
})

function Bird:applyOptions()
	if self.state == 'sitting' then
		self:setAnim('birdStand' .. self.type)
	end
end

function object:collision()
end

function Bird:setAcceleration(dt)
	if self.state == 'flying' then
		self.vy = math.max(self.vy - self.acceleration * dt,self.vyTarget)
		self.vx = self.vx + self.direction * 2 * self.acceleration * dt
		if self.direction == 1 then
			self.vx = math.min(self.vx, self.vxTarget)
		else
			self.vx = math.max(self.vx, self.vxTarget)
		end
	end
end

function Bird:scare()
	if p.x < self.x then
		self.direction = 1
	else
		self.direction = -1
	end
	local thisAngle = love.math.random()*0.25*math.pi + 0.125 * math.pi
	local thisSpeed = love.math.random()*4 + 8
	self.vyTarget = -math.cos(thisAngle) * thisSpeed
	self.vxTarget = math.sin(thisAngle) * thisSpeed * self.direction
	self.state = 'flying'
	self:setAnim('birdFly'..self.type)
	self.vis[1].sx = -self.direction
end

function Bird:postStep(dt)
	if self.state == 'sitting' then
		local dx = math.abs(self.x - p.x)
		local dy = math.abs(self.y - p.y)
		if dx < 5 and dy < 5 then 
			self:scare()
		end
	end
end

return Bird
