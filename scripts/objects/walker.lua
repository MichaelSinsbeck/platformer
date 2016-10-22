local Walker = object:New({
	tag = 'Walker',
	category = 'Enemies',
	speed = 1.6,
	vx = 0,
	timer = 0,
	vis = {Visualizer:New('enemyprewalker')},
  marginx = 0.6,
  marginy = 0.6,
  isInEditor = true,
  period = 0.5, -- should be (0.8/speed)
  zoomState = 0, -- for cross hairs
  soundCoolDown = 0,
  bounceTime = 0, -- timer for little squeeze effect
	properties = {
		type = utility.newCycleProperty({'enemy','bouncy'}),	
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
	
	local prefix = self.type
	local body
	if self.type == 'bouncy' then
		body = 'walker' .. self.arrows
	else
		body = 'walker'
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
	self.soundCoolDown = self.soundCoolDown - dt
	self.bounceTime = math.max(self.bounceTime - dt,0) -- for squash and stretch
	
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
	
  -- calculate direction (left/right)
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
		self.anchorRy = self.vis[3].relY
		
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
			local volume = self.vy/20
			volume = math.min(math.max(volume,0),1)
			self:playSound('walkerLand',volume)
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
			local volume = self.vy/20
			volume = math.min(math.max(volume,0),1)
			self:playSound('walkerLand',volume)
			self:wake()
		end
	end
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
		if self.type == 'enemy' then
			p.dead = true
			levelEnd:addDeath("death_walker")
			objectClasses.Meat:spawn(p.x,p.y,self.vx,self.vy,12)
			self:playSound('death')
    elseif self.type == 'bouncy' then
				if self.status == 'normal' or self.status == 'fall' then
				p.vy = -self.strength;
				self:setAnim('bouncywalkerblink' .. self.arrows,false,3)
				self:resetAnimation()
				p.canUnJump = false
				self.bounceTime = 0.2
				if self.soundCoolDown < 0 then
					local pitch = self.strength/23
					self:playSound('bouncerBump',1,pitch) 
					self.soundCoolDown = 0.1
				end
			end
    end
  end
  
  -- squash and stretch according to bounceTime
  if self.status == "normal" then
		local s = 1+250*(self.bounceTime^2*(0.2-self.bounceTime))
		self.vis[3].sx = s * sign
		self.vis[3].sy = 1/s  
	end
  
  -- show crosshairs
  if self.anchorRadii then
		if self.isCurrentTarget then
			self.zoomState = math.min(self.zoomState + 5*dt,1)
		else
			self.zoomState = math.max(self.zoomState - 7*dt,0)
		end
		local s = utility.easingOvershoot(self.zoomState)

		self.vis[6].angle = self.vis[6].angle + dt
		self.vis[6].sx = s
		self.vis[6].sy = s 
	end
end

function Walker:wake()
	self.status = 'normal'
	self:resize(0.48,0.375)
	self.vis = {
		Visualizer:New('enemywalkerfoot2'),
		Visualizer:New('enemywalkerfoot2'),  
		Visualizer:New('enemywalker'),
		Visualizer:New('enemywalkerfoot'),
		Visualizer:New('enemywalkerfoot'),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  }
  self:init()
  if self.type == 'enemy' then
		self.anchorRadii = {.6,.4}
  end
	self.vx = self.speed * self.direction
end

function Walker:onKill()
	if p.anchor and p.anchor.target == self then
		spriteEngine:DoAll('disconnect')
	end
end

return Walker
