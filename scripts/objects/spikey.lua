local Spikey = object:New({
	tag = 'Spikey',
  semiheight = 0.5,
  semiwidth = 0.5,
})

function Spikey:setAcceleration(dt)
	if not p.dead and self:touchPlayer() then
		p:kill()
    self:playSound('spikeDeath')
    levelEnd:addDeath("death_spikey")
    objectClasses.Meat:spawn(p.oldx,p.oldy,self.vx,self.vy,12)
  end  
end

return Spikey
