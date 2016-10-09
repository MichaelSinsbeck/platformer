local Water = object:New({
	tag = 'Water',
  semiheight = 0.2,
  semiwidth = 0.5,
})

function Water:setAcceleration(dt)
	if not p.dead and self:touchPlayer() then
    p.dead = true
    levelEnd:addDeath("death_falls")
    objectClasses.Droplet:spawn(p.oldx,p.oldy,p.vx,p.vy)
  end  
end

return Water
