Emitter = object:New({
	tag = 'emitter',
  emissionTimer = 0,
  rate = .3,
  semiheight = .5,
  semiwidth = .5,
})

function Emitter:setAcceleration(dt)
end

function Emitter:postStep(dt)
	self.emissionTimer = self.emissionTimer - dt
	while self.emissionTimer < 0 do
		self.emissionTimer = self.emissionTimer+self.rate*(0.5+math.random())
			local newX = self.x + math.random() - 0.5
			local newY = self.y + 0.5
			local newAni = 'wind' .. math.random(1,3)
			local newDot = Winddot:New({x=newX,y=newY,animation=newAni})
			spriteEngine:insert(newDot)		
	end
end