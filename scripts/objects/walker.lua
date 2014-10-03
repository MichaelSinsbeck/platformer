local Walker = object:New({
	tag = 'Walker',
	category = 'Enemies',
	speed = 1.6,
	vx = 0,
	timer = 0,
	vis = {Visualizer:New('evilprewalker')},
  marginx = 0.6,
  marginy = 0.6,
  isInEditor = true,
  period = 0.5, -- should be (0.8/speed)
	properties = {
		isEvil = utility.newCycleProperty({true,false},{'enemy','bouncy'}),	
		direction = utility.newCycleProperty({-1,1},{"left", "right"},nil),
		strength = utility.newProperty({16,23},{'weak','strong'},2),		
	}  
})
	
function Walker:applyOptions()
	if self.strength == 16 then
		self.arrows = 1
	else
		self.arrows = 2
	end
	
	local prefix
	local body
	if self.isEvil then
		prefix = 'evil'
		body = 'walker'
	else
		prefix = 'good'
		body = 'walker' .. self.arrows
	end
	if self.status == 'normal' then
		self:setAnim(prefix .. 'walkerfoot2',false,1)
		self:setAnim(prefix .. 'walkerfoot2',false,2)
		self:setAnim(prefix .. body,false,3)
		self:setAnim(prefix .. 'walkerfoot',false,4)
		self:setAnim(prefix .. 'walkerfoot',false,5)
	else
		self:setAnim(prefix .. 'prewalker')
	end
end

function Walker:postStep(dt)
	local t0 = self.timer / self.period
	if self.collisionResult >= 8 then
		self.timer = (self.timer + dt)%self.period
	else
		self.timer = 0
	end
	local t1 = self.timer / self.period

	if (t0-0.5)*(t1-0.5)<= 0 then
		self:playSound('walkerStep')
	end
	   

	local right,left,up,down = utility.directions(self.collisionResult)
	if right then
	  self.vx = -self.speed
	end
	if left then
		self.vx = self.speed
	end
	
	local sign = 1
	if self.vx < 0 then sign = -1 end
	for i = 1,#self.vis do
		self.vis[i].sx = sign
	end
	
	-- positioning of feed (if normal)
	if self.status == 'normal' or self.status == 'fall' then
		local t = self.timer/self.period -- effective timer
		local pi = math.pi
		
		self.vis[3].relY = sign*0.03*math.cos(4*pi*t) -- body of walker bounced on walk
		
		if self.collisionResult >= 8 then -- walking
			if t < .5 then -- set animation (feed position)
				self.vis[1].relX = sign*(0.6 - 0.8*t)
				self.vis[1].relY = 0.3
				self.vis[1].angle = 0
				
				self.vis[2].relX = sign*(-0.2 - 0.2*math.cos(2*pi*t))
				self.vis[2].relY = 0.3 - 0.1*math.sin(2*pi*t)
				self.vis[2].angle = -sign*0.3*math.sin(2*pi*t)
			
				self.vis[4].relX = sign*(0.4 - 0.2*math.cos(2*pi*t))
				self.vis[4].relY = 0.3 - 0.1*math.sin(2*pi*t)
				self.vis[4].angle = -sign*0.3*math.sin(2*pi*t)
				
				self.vis[5].relX = sign*(- 0.8*t)
				self.vis[5].relY = 0.3
				self.vis[5].angle = 0
			else
				self.vis[1].relX = sign*(0.4 + 0.2*math.cos(2*pi*t))
				self.vis[1].relY = 0.3 + 0.1*math.sin(2*pi*t)
				self.vis[1].angle = sign*0.3*math.sin(2*pi*t)  

				self.vis[2].relX = sign*(0.4 - 0.8*t)
				self.vis[2].relY = 0.3
				self.vis[2].angle = 0
						
				self.vis[4].relX = sign*(1 - 0.8*t)
				self.vis[4].relY = 0.3
				self.vis[4].angle = 0
				
				self.vis[5].relX = sign*(-0.2 + 0.2*math.cos(2*pi*t))
				self.vis[5].relY = 0.3 + 0.1*math.sin(2*pi*t)
				self.vis[5].angle = sign*0.3*math.sin(2*pi*t)
				
			end
			if self.status == 'fall' then
				self:playSound('walkerLand')
			end
			self.status = 'normal'
		else -- falling
			self.vis[1].relX = sign*0.4
			self.vis[1].relY = 0.3
			self.vis[1].angle = 0.3*sign

			self.vis[2].relX = -sign*0.2
			self.vis[2].relY = 0.3
			self.vis[2].angle = 0.3*sign
		
			self.vis[4].relX = sign*0.4
			self.vis[4].relY = 0.3
			self.vis[4].angle = 0.3*sign

			self.vis[5].relX = -sign*0.2
			self.vis[5].relY = 0.3
			self.vis[5].angle = 0.3*sign
			self.status = 'fall'
		end
	else -- status == ball
		if self.collisionResult > 0 then
			self:playSound('walkerLand')
			self:wake()
		end
	end
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
		if self.isEvil then
    p.dead = true
    levelEnd:addDeath("death_walker")
    objectClasses.Meat:spawn(p.x,p.y,self.vx,self.vy,12)
    self:playSound('walkerDeath')
    elseif self.status == 'normal' or self.status == 'fall' then
			p.vy = -self.strength;
			self:setAnim('goodwalkerblink' .. self.arrows,false,3)
			self:resetAnimation()
			p.canUnJump = false		
    end
  end  
end

function Walker:wake()
	self.status = 'normal'
	self:resize(0.48,0.375)
	self.vis = {
		Visualizer:New('evilwalkerfoot2'),
		Visualizer:New('evilwalkerfoot2'),  
		Visualizer:New('evilwalker'),
		Visualizer:New('evilwalkerfoot'),
		Visualizer:New('evilwalkerfoot'),
  }
  self:init()
	self.vx = self.speed * self.direction
end

return Walker

--[[WalkerLeft = Walker:New({
  direction = -1,
})]]
