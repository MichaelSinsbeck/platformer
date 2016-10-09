local Water = object:New({
	tag = 'Water',
  semiheight = 0.5,
  semiwidth = 0.5,
})

function Water:setAcceleration(dt)
	if not p.dead and self:touchPlayer() and p.y>self.y-self.semiheight then
	print(p.y)
	print(self.y)
    p.dead = true
    levelEnd:addDeath("death_water")
    objectClasses.Droplet:spawn(p.oldx,p.oldy,p.vx,p.vy)
  end  
end

return Water
