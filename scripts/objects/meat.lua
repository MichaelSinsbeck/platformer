local Meat = object:New({
	tag = 'Meat',
  marginx = 0.3,
  marginy = 0.3,
  lifetime = 5,
  spreadSpeed = 15,
  rotSpeed = 1,
	angle = 0,
  rotating = true,
  vis = {Visualizer:New('meat1')},
})

function Meat:setAcceleration(dt)
	if self.vis[1].animation == 'meatWall' then
		self.vy = 0
		self.vx = 0
		return
	end
	self.vy = self.vy + gravity * dt
	self.vis[1].angle = self.vis[1].angle + self.rotSpeed

	self.vis[1].alpha = math.min(2*(self.lifetime - self.vis[1].timer)/self.lifetime,1)*255
	if self.vis[1].timer >= self.lifetime then
    self:kill()
	end
end

function Meat:postStep(dt)
	if self.collisionResult > 0 then
		self:playSound('meatCollide')
	end
	if self.collisionResult == 1 then
		self:setAnim('meatWall')
		self.rotSpeed = 0
		self.vis[1].angle = -math.pi/2
	elseif self.collisionResult == 2 then
		self:setAnim('meatWall')
		self.rotSpeed = 0
		self.vis[1].angle = math.pi/2
	elseif self.collisionResult == 4 then
		self:setAnim('meatWall')
		self.rotSpeed = 0
		self.vis[1].angle = math.pi
	elseif self.collisionResult == 8 then
		self:setAnim('meatWall')
		self.rotSpeed = 0
		self.vis[1].angle = 0
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
		local newPiece = self:New({x=x,y=y,vx = vx,vy = vy,vis={Visualizer:New(animation)},rotSpeed = rotSpeed,lifetime = lifetime})
		spriteEngine:insert(newPiece)
	end
end

return Meat
