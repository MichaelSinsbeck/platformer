local Bouncer = object:New({
	tag = 'Bouncer',
	category = "Interactive",
  targetvy = -23,
  marginx = 0.8,
  marginy = 0.2,
  isInEditor = true,
  bounceTime = 0, -- timer for little squeeze effect
  vis = {
		Visualizer:New('weakBouncer',{frame = 2}),
  }, 
  properties = {
		angle = utility.newCycleProperty({-1,0,1,2},{'up', 'right', 'down', 'left'}),
		strength = utility.newProperty({16,23,30},{'weak','medium','strong'},2),
  }, 
})

function Bouncer:applyOptions()
	if self.angle == 0 or self.angle == 2 then
		self.semiwidth, self.semiheight = 0.125, 0.5
	else
		self.semiwidth, self.semiheight = 0.5, 0.125
	end
	local tileX, tileY = math.floor(self.x), math.floor(self.y)
	self.x = tileX+0.5-.375*math.cos(self.angle*0.5*math.pi)
	self.y = tileY+0.5-.375*math.sin(self.angle*0.5*math.pi)
	self.vis[1].angle = self.angle*0.5*math.pi+0.5*math.pi
	local s = self.properties.strength.names[self.strength]
	self:setAnim(s..'Bouncer',true)
end

function Bouncer:setAcceleration(dt)
end

function Bouncer:postStep(dt)
	self.bounceTime = math.max(self.bounceTime - dt,0)
	
	if self:touchPlayer() then
		local nx,ny = math.cos(self.angle*.5*math.pi),math.sin(self.angle*0.5*math.pi)
		local normal = nx*p.vx + ny*p.vy
		local tangential = ny*p.vx - nx*p.vy
		normal = math.max(normal, self.strength)
		p.vx = nx * normal + ny * tangential
		p.vy = ny * normal - nx * tangential
		self:resetAnimation()
		self.bounceTime = 0.2
		if self.angle == -1 then
			p.canUnJump = false
		end
		local pitch = self.strength/23
		
		self:playSound('bouncerBump',1,pitch) 
  end
  
  -- squash and stretch according to bounceTime
  local s = 1+250*(self.bounceTime^2*(0.2-self.bounceTime))
	self.vis[1].sx = s
	self.vis[1].sy = 1/s

end

return Bouncer
