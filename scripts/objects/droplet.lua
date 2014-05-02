local Droplet = object:New({
	tag = 'Droplet',
  marginx = 0.3,
  marginy = 0.3,
  lifetime = 5,
  spreadSpeed = 7,
	angle = 0,
  rotating = true,
  vis = {Visualizer:New('droplet1')},
})

function Droplet:setAcceleration(dt)
	if self.vis[1].animation == 'dropletWall' then
		self.vy = 0
		self.vx = 0
		return
	end
	self.vy = self.vy + gravity * dt
	--self.vis[1].angle = self.vis[1].angle + self.rotSpeed
	self.vis[1].angle = math.atan2(self.vy,self.vx)


	self.vis[1].alpha = math.min(2*(self.lifetime - self.vis[1].timer)/self.lifetime,1)*255
	if self.vis[1].timer >= self.lifetime then
    self:kill()
	end
end

function Droplet:postStep(dt)
	if self.collisionResult == 1 then
		self:setAnim('dropletWall')
		self.rotSpeed = 0
		self.vis[1].angle = -math.pi/2
	elseif self.collisionResult == 2 then
		self:setAnim('dropletWall')
		self.rotSpeed = 0
		self.vis[1].angle = math.pi/2
	elseif self.collisionResult == 4 then
		self:setAnim('dropletWall')
		self.rotSpeed = 0
		self.vis[1].angle = math.pi
	elseif self.collisionResult == 8 then
		self:setAnim('dropletWall')
		self.rotSpeed = 0
		self.vis[1].angle = 0
	end
end

function Droplet:spawn(x,y,vx,vy,number)
	local number = number or 20
	for i=1,number do
		local angle, magnitude = math.pi*2*math.random(), 0.2+math.random()*0.8
		local cos,sin = math.cos(angle),math.sin(angle)
		local vx = cos*self.spreadSpeed*magnitude+0.7*vx
		local vy = sin*self.spreadSpeed*magnitude-0.8*vy
		local lifetime = self.lifetime * 0.8+ 0.4*math.random()
		local animation = 'droplet' .. math.random(1,4)
		local newPiece = self:New({x=x,y=y,vx = vx,vy = vy,vis={Visualizer:New(animation)},lifetime = lifetime})
		spriteEngine:insert(newPiece)
	end
end

return Droplet
