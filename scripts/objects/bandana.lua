local Bandana = object:New({
	tag = 'Bandana',
	category = 'Essential',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  vis = {
		Visualizer:New('starBandana'),
		Visualizer:New('whiteBandana'),
  },
	properties = {
		color = utility.newCycleProperty({'white','yellow','green','blue','red'})
	},  
})

function Bandana:applyOptions()
	self:setAnim(self.color .. 'Bandana',true,2)
end

function Bandana:setAcceleration(dt)
	--self.vis[1].angle = self.vis[1].angle + 2*dt
	self.vis[1].angle = self.vis[1].timer * 2
	self.vis[2].sx = 0.9+0.1*math.sin(10*self.vis[1].timer)
	self.vis[2].sy = 0.9+0.1*math.sin(10*self.vis[1].timer)
	if self:touchPlayer() then
		if editor.active then
			p:setBandana(self.color)
			gui.addBandana( self.color )
		else
			upgrade:newBandana(self.color)
			--Campaign:upgradeBandana(self.color)
			--mode = 'upgrade'
			--shaders:setDeathEffect( .8 )
		end
		--p.bandana = self.color
		self:kill()
  end
end

return Bandana
