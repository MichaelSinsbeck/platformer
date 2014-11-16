local Upwind = object:New({
	tag = 'Upwind',
  isInEditor = true,	
  emissionTimer = 0,
  rate = .3,
  semiheight = .5,
  semiwidth = .5,
  vis = {
		Visualizer:New('upwind'),
  },  
	properties = {
		height = utility.newNumericTextProperty( 3, 0, math.huge ),
	}, 
})

function Upwind:setAcceleration(dt)
end

function Upwind:draw()
	if mode == 'editor' then
		object.draw(self)
		local thisWidth = 1 * Camera.scale*8
		local thisHeight = self.height * Camera.scale*8
		local x = (self.x - 0.5) * Camera.scale*8
		local y = (self.y + 0.5 - self.height) * Camera.scale*8
		love.graphics.setColor(0,127,255,50)
		love.graphics.rectangle('fill',x,y,thisWidth,thisHeight)
	end
end

function Upwind:postStep(dt)
	self.emissionTimer = self.emissionTimer - dt
	while self.emissionTimer < 0 do
		self.emissionTimer = self.emissionTimer+self.rate*(0.5+math.random())
			local newX = self.x + math.random() - 0.5
			local newY = self.y + 0.5
			local yDeath = self.y + 0.5 - self.height
			local newAni = 'wind' .. math.random(1,3)
			local newDot = spriteFactory('Winddot',{x=newX,y=newY,yDeath = yDeath,vis = {Visualizer:New(newAni)}})
			spriteEngine:insert(newDot)		
	end
end

return Upwind
