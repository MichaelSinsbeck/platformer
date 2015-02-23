local Follower = object:New({
	tag = 'Follower',
	category = 'Enemies',
	layout = 'center',
  --maxSpeed = 20,
  range = 7, --how far can he see?
	state = 'wait',
	marginx = 0.7,
  marginy = 0.7,
  acceleration = 60,
  isInEditor = true,
  zoomState = 0,
  vis = {
		Visualizer:New('followerBack'),
		Visualizer:New('followerPupil'),
		Visualizer:New('followerClose',{frame = 2}),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  },
  properties = {
		maxSpeed = utility.newCycleProperty({10,15,20},{'slow','medium','fast'},2)
  },
	--properties = {
	--	direction = utility.newCycleProperty({0, .5, 1, -.5}, {'vertical', 'diagonal1','horizontal','diagonal2'}),
	--},
	anchorRadii = {.6,.6},
})

function Follower:applyOptions()

end

function Follower:setAcceleration(dt)
	if p.dead then return end
	if self.state == 'wait' then
	local dx, dy = p.x-self.x, p.y-self.y
		if math.abs(dx) < self.semiwidth + p.semiwidth then
			if myMap:lineOfSight(self.x,self.y,p.x,p.y) then
				self.ax = 0
				if dy > 0 then
					self.ay = self.acceleration
				else
					self.ay = -self.acceleration
				end
				self:wake()
			end
			-- up or down
		elseif math.abs(dy) < self.semiheight + p. semiheight and
					myMap:lineOfSight(self.x,self.y,p.x,p.y) then
			self.ay = 0
			if dx > 0 then
				self.ax = self.acceleration
			else
				self.ax = -self.acceleration
			end
			self:wake()
		end
	else -- is awake
		self.vx = self.vx + self.ax * dt
		self.vy = self.vy + self.ay * dt
		
		-- velocity constraint
		self.vx = math.min(self.vx,self.maxSpeed)
		self.vx = math.max(self.vx,-self.maxSpeed)
		self.vy = math.min(self.vy,self.maxSpeed)
		self.vy = math.max(self.vy,-self.maxSpeed)
		
	end
end

function Follower:wake()
	self.state = 'follow'
	self:setAnim('followerOpen',nil,3)
	local angle = math.atan2(self.ay,self.ax)
	self.vis[2].relX = 0.15*math.cos(angle)
	self.vis[2].relY = 0.15*math.sin(angle)
end

function Follower:postStep(dt)

	if self.collisionResult > 0 then
		self.state = 'wait'
		self:setAnim('followerClose',nil,3)
	end
	
	if self.state == 'wait' then
		self.vx = 0
		self.vy = 0
	end
	-- show crosshairs
  if self.anchorRadii then
		if self.isCurrentTarget then
			self.zoomState = math.min(self.zoomState + 5*dt,1)
		else
			self.zoomState = math.max(self.zoomState - 7*dt,0)
		end
		local s = utility.easingOvershoot(self.zoomState)

		self.vis[4].angle = self.vis[4].angle + dt
		self.vis[4].sx = s
		self.vis[4].sy = s 
	end 
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p:kill()
    levelEnd:addDeath("death_goalie")
    objectClasses.Meat:spawn(p.x,p.y,self.vx,self.vy,12)
    self:playSound('followerDeath')
  end
end

function Follower:onKill()
	if p.anchor and p.anchor.target == self then
		spriteEngine:DoAll('disconnect')
	end
end

return Follower
