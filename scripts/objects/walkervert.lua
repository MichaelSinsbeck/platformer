WalkerVert = object:New({
	tag = 'walker-vert',
	speed = 2,
	vy = 2,
	vx = 0,
  vis = {
		Visualizer:New('walkervert'),
  },
  marginx = 0.8,
  marginy = 0.25,
})

function WalkerVert:setAcceleration(dt)
end

function WalkerVert:postStep(dt)
	-- collision top:
	if self.collisionResult == 4 then
	  self.vy = self.speed
	end
	
	if self.collisionResult == 8 then
		self.vy = -self.speed
	end
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p.dead = true
    levelEnd:addDeath("walker")
    Meat:spawn(p.x,p.y,self.vx,self.vy,12)
  end  
end
