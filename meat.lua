Meat = Particle:New({
	tag = 'Meat',
  marginx = 0.1,
  marginy = 0.1,
  lifetime = 5,
  spreadSpeed = 15,
  rotSpeed = 5,
})

function Meat:setAcceleration(dt)
	if self.animation == 'meatWall' then
		self.vy = 0
		self.vx = 0
		return
	end
	self.vy = self.vy + gravity * dt
	self.angle = self.angle + self.rotSpeed

	self.alpha = math.min(2*(self.lifetime - self.timer)/self.lifetime,1)*255
	if self.timer >= self.lifetime then
    self:kill()
	end
end

function Meat:postStep(dt)
	if self.collisionResult == 1 then
		self.animation = 'meatWall'
		self.rotSpeed = 0
		self.angle = -math.pi/2
	elseif self.collisionResult == 2 then
		self.animation = 'meatWall'
		self.rotSpeed = 0
		self.angle = math.pi/2
	elseif self.collisionResult == 4 then
		self.animation = 'meatWall'
		self.rotSpeed = 0
		self.angle = math.pi
	elseif self.collisionResult == 8 then
		self.animation = 'meatWall'
		self.rotSpeed = 0
		self.angle = 0
	end
end

function Meat:spawn(x,y,vx,vy,number)
local number = number or 12
for i=1,number do
	local angle, magnitude = math.pi*2*math.random(), 0.5+math.random()*0.5
	local cos,sin = math.cos(angle),math.sin(angle)
	local vx = cos*self.spreadSpeed*magnitude+0.7*vx
	local vy = sin*self.spreadSpeed*magnitude+0.7*vy
	local lifetime = self.lifetime * 0.8+ 0.4*math.random()
	local animation = 'meat' .. math.random(1,4)
	local rotSpeed = self.rotSpeed * (math.random()*2-1)
	local newParticle = self:New({x=x,y=y,vx = vx,vy = vy,animation=animation,rotSpeed = rotSpeed,lifetime = lifetime})
	spriteEngine:insert(newParticle)
end
end
