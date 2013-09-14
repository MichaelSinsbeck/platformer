Light = object:New({
	tag = 'light',
	layout = 'center',
  marginx = 0.4,
  marginy = 0.4,
  on = true,
  vis = {
		Visualizer:New('candlelight'),
		Visualizer:New('candle'),
		},
})

function Light:setAcceleration()
end

function Light:postStep(dt)
	if self:touchPlayer() then
		if self.on then
			self:switch(false)
			print("TURNED OFF")
			myMap:setShadowActive( self.x, self.y, false )
		end
	end
end

function Light:collectLights(lightList)
	if self.on then
		table.insert(lightList,{x = self.x, y = self.y})
	end
end

function Light:switch(newState)
	self.on = newState
	if self.on then
		self:setAnim('candle',false,2)
		self:setAnim('candlelight',false,1)
	else
		self:setAnim('candle',false,1)
		self:setAnim('',false,2)
	end
end

Torch = Light:New({
	tag = 'torch',
  vis = {
		Visualizer:New('flame'),
		Visualizer:New('torch'),
		},
})

function Torch:switch(newState)
	self.on = newState
	if self.on then
		self:setAnim('torch',false,2)
		self:setAnim('flame',false,1)
	else
		self:setAnim('torch',false,1)
		self:setAnim('',false,2)
	end
end


Lamp = Light:New({
	tag = 'torch',
  vis = {
		Visualizer:New('lamp'),
		Visualizer:New('lamplight'),
		},	
})

function Lamp:switch(newState)
	self.on = newState
	if self.on then
		self:setAnim('lamp',false,1)
		self:setAnim('lamplight',false,2)
	else
		self:setAnim('lamp',false,1)
		self:setAnim('',false,2)
	end
end
