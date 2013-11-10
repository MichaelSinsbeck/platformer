Walker = object:New({
	tag = 'walker',
	speed = 2,
	vx = 2,
  vis = {
		Visualizer:New('roller'),
  },
  marginx = 0.6,
  marginy = 0.6,
})

function Walker:init()
	object.init(self)
	self.vis[1].angle = math.random()*math.pi*2
end

function Walker:setAcceleration(dt)
-- apply acceleration to object, generically, this is only gravity
  self.vx = self.vx
  self.vy = self.vy + gravity * dt
  
  self.vis[1].angle = self.vis[1].angle + 1.5*dt*self.vx
end

function Walker:postStep(dt)
	if self.collisionResult%2 == 1 then
	  self.vx = -self.speed
	end
	
	local truncated = (self.collisionResult - self.collisionResult%2)/2
	if truncated%2 == 1 then
		self.vx = self.speed
	end
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p.dead = true
    levelEnd:addDeath("walker")
    Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end  
end
