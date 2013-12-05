WalkerRight = object:New({
	tag = 'walker-right',
	layout = 'center',
	speed = 2,
	vx = 2,
  vis = {
		Visualizer:New('walkerup',{angle = 0.5*math.pi}),
  },
  marginx = 0.25,
  marginy = 0.8,
})

function WalkerRight:setAcceleration(dt)
end

function WalkerRight:postStep(dt)
	if self.collisionResult%2 == 1 then
	  self.vx = -self.speed
	  self:setAnim('walkerdown')
	end
	
	local truncated = (self.collisionResult - self.collisionResult%2)/2
	if truncated%2 == 1 then
		self.vx = self.speed
		self:setAnim('walkerup')
	end
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p.dead = true
    levelEnd:addDeath("death_walker")
    Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end  
end

WalkerLeft = WalkerRight:New({
	tag = 'walker-left',
	vx = - WalkerRight.speed,
	  vis = {
		Visualizer:New('walkerdown',{angle = 0.5*math.pi}),
  },
})
