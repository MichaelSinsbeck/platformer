Clubber = object:New({
	tag = 'clubber',
  speed = 2,
  xSensing = 20, --how far can he see?
  ySensing = 7,
  state = 'walk',
  vis = {
		Visualizer:New('clubber'),
		Visualizer:New('club',{ox = -.8}),
  },
  marginx = 0.6,
  marginy = 0.8,
  radius = 1,
  targetv = 23,
  distmin = 0.5,
})

function Clubber:postStep(dt)
	local dx = self.x-p.x
  local dy = self.y-p.y
  
  self.vx = 0
	if self.state == 'walk' then
		if p.visible and not p.dead and math.abs(dx) < self.xSensing and math.abs(dy) < self.ySensing then
			-- walk towards player
			if dx > 0 then
				if dx > self.distmin then
					self.vx = -self.speed
				end
				self:flip(false)
				self.vis[2].angle = math.atan2(dy,dx)
			elseif dx < 0 then
				if dx < - self.distmin then
					self.vx = self.speed
				end
				self:flip(true)
				self.vis[2].angle = math.atan2(-dy,-dx)
			end
			-- check for punching
			if utility.pyth(dx,dy) < self. radius then
				local angle = math.atan2(-dy,-dx)
				p.vx = math.cos(angle) * self.targetv
				p.vy = math.sin(angle) * self.targetv
				p.canUnJump = false
				if self.flipped then
					self.vis[2].angle = math.atan2(dy,dx)	
				else
					self.vis[2].angle = angle
				end
				self.state = 'wait'
				self.vis[2].timer = 0
			end	
		else
			self.vx = 0
		end
	elseif self.state == 'wait' then
		self.vx = 0
		if self.vis[2].timer > 0.5 then
			self.state = 'walk'
		end
	end
  
	if self.flipped then
		self.vis[1].sx = -1
		self.vis[2].sx = -1
	else
		self.vis[1].sx = 1
		self.vis[2].sx = 1
	end
end
