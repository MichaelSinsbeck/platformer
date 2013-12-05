WalkerDown = object:New({
	tag = 'walker-down',
	layout = 'center',
	speed = 2,
	vy = 2,
	vx = 0,
  vis = {
		Visualizer:New('walkerdown'),
  },
  marginx = 0.8,
  marginy = 0.25,
})

function WalkerDown:setAcceleration(dt)
end

function WalkerDown:postStep(dt)
	-- collision top:
	if self.collisionResult == 4 then
	  self.vy = self.speed
		self:setAnim('walkerdown')
	end
	
	if self.collisionResult == 8 then
		self.vy = -self.speed
		self:setAnim('walkerup')
	end
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p.dead = true
    levelEnd:addDeath("death_walker")
    Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end  
end

WalkerUp = WalkerDown:New({
	tag = 'walker-up',
	vy = - WalkerRight.speed,
	  vis = {
		Visualizer:New('walkerup'),
  },
})
