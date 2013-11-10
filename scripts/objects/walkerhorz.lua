WalkerHorz = object:New({
	tag = 'walker-horz',
	speed = 2,
	vx = 2,
  vis = {
		Visualizer:New('walkerhorz'),
  },
  marginx = 0.25,
  marginy = 0.8,
})

function WalkerHorz:setAcceleration(dt)
end

function WalkerHorz:postStep(dt)
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
