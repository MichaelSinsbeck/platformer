Spikey = object:New({
	tag = 'spikey',
  semiheight = 0.5,
  semiwidth = 0.5
})

function Spikey:setAcceleration(dt)
	if not p.dead and self:touchPlayer() then
    p.dead = true
    levelEnd:addDeath("death_spikey")
    Meat:spawn(p.oldx,p.oldy,self.vx,self.vy,12)
  end  
end
