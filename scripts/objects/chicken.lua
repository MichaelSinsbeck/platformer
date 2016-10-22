local Chicken = object:New({
	tag = 'Chicken',
	category = "Misc",
  marginx = 0.6,
  marginy = 0.6,
  isInEditor = true,
  state = 'Stand',
  soundDelay = 0, -- timer to avoid too many sounds
  direction = 1,
  vxJump = 1,
  vxPanic = 5,
  stateTimer = 0,
  vis = {
		Visualizer:New('chickenStand'),
  },
	properties = {
		unlockID = utility.newIntegerProperty(1,1,10,1)
	},  
})

function Chicken:applyOptions()
	self.stateTimer = 2 * love.math.random()
end

function Chicken:setAcceleration(dt)
	-- set x-velocity
	if self.state == 'Jump' then
		self.vx = self.direction * self.vxJump
	elseif self.state == 'Panic' then
		self.vx = self.direction * self.vxPanic
	else
		self.vx = 0
	end
	
	-- y velocity according to gravity
	self.vy = self.vy + gravity*dt
end

function Chicken:postStep(dt)
	self.soundDelay = math.max(self.soundDelay - dt,0)
	if self:touchPlayer() then
		self:kill()
	end
	-- change between states : stand, eat, jump
	self.stateTimer = self.stateTimer - dt
	local right, left, up, down = utility.directions(self.collisionResult)
	
	if self.stateTimer < 0 then -- change state randomly
		if self.state == 'Stand' then -- if standing, do something else
			if love.math.random() < 0.5 then
				self.state = 'Eat'
				self.vx = 0
				self.stateTimer = 1.6
			else
				self.state = 'Jump'
				if love.math.random() > 0.5 then
					self.direction = 1
				else
					self.direction = -1
				end
				self.stateTimer = 2
			end
		elseif self.state == 'Panic' then
			self.state = 'Jump'
			self.stateTimer = 1
		elseif self.state == 'Jump' then
			if down then
				self.state = 'Stand'
				self.stateTimer = 2 + love.math.random()
			end
		else -- otherwise go back to standing around
			self.state = 'Stand'
			self.stateTimer = 2 + love.math.random()
		end
		self:setAnim('chicken'..self.state)
	end
	-- player comes close, go to panic-mode
	local dx,dy = self.x - p.x, self.y - p.y
	if utility.pyth(dx,dy) < 5 then
		if self.state ~= 'Panic' then -- set direction only, if not in panic mode already
			self.state = 'Panic'
			if dx > 0 then self.direction = 1 else self.direction = -1 end
			self:setAnim('chicken'..self.state)		
		end
		self.stateTimer = 3 + love.math.random() -- set timer always
	end
	
	-- if in jump-state, jump
	if self.state == 'Jump' and down then
		self.vy = -2.5 -- - 3*love.math.random()
	end
	if self.state == 'Panic' and down then
		self.vy = -5 - 5*love.math.random()
		if self.soundDelay == 0 then
			self:playSound('chicken') -- sound only in panic-mode
			self.soundDelay = 1
		end
	end
	
	-- collision left and right
	if left then
		self.direction = 1
	elseif right then
		self.direction = -1
	end

	self.vis[1].sx = - self.direction
end

return Chicken
