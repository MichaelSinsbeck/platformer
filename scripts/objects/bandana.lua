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
	--self:setAnim(self.color .. 'Bandana',true,2)
end

function Bandana:setAcceleration(dt)
	--self.vis[1].angle = self.vis[1].angle + 2*dt
	self.vis[1].angle = self.vis[1].timer * 2
	self.vis[2].sx = 0.9+0.1*math.sin(10*self.vis[1].timer)
	self.vis[2].sy = 0.9+0.1*math.sin(10*self.vis[1].timer)
	if self:touchPlayer() then
		if editor.active or menu.state == 'userlevels' then
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

function Bandana:draw()
	local x = self.x*8*Camera.scale
	local y = self.y*8*Camera.scale
	
	self.vis[1]:draw(x,y,true)
	local color = utility.bandana2color[self.color]
	if color and not self.anchor then
		local r,g,b = love.graphics.getColor()
		love.graphics.setColor(color[1],color[2],color[3],255)
		self.vis[2]:draw(x,y,true)
		love.graphics.setColor(r,g,b)
	end
end

return Bandana
