local Bouncer = object:New({
	tag = 'Bouncer',
	category = "Interactive",
  targetvy = -23,
  marginx = 0.8,
  marginy = 0.2,
  isInEditor = true,
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
	self:playSound(s..'BouncerBump')
end

function Bouncer:setAcceleration(dt)
end

function Bouncer:postStep(dt)
	if self:touchPlayer() then
		local nx,ny = math.cos(self.angle*.5*math.pi),math.sin(self.angle*0.5*math.pi)
		local normal = nx*p.vx + ny*p.vy
		local tangential = ny*p.vx - nx*p.vy
		normal = math.max(normal, self.strength)
		p.vx = nx * normal + ny * tangential
		p.vy = ny * normal - nx * tangential
		self:resetAnimation()
		if self.angle == -1 then
			p.canUnJump = false
		end
  end
end

return Bouncer
