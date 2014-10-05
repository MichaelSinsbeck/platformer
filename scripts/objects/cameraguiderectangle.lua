local CameraguideRect = object:New({
	tag = 'CameraGuideRect',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  radius = 4,
  vis = {
		Visualizer:New('cameraRectangle'),
  },
	properties = {
		transition = utility.newNumericTextProperty(0.2,0,1),
		offsetX = utility.newNumericTextProperty(0,-math.huge,math.huge),
		offsetY = utility.newNumericTextProperty(0,-math.huge,math.huge),
		sensorW = utility.newNumericTextProperty( 5, 0, math.huge ),
		sensorH = utility.newNumericTextProperty( 3, 0, math.huge ),
	}, 
})

function CameraguideRect:applyOptions()
end

function CameraguideRect:setAcceleration(dt)
end

function CameraguideRect:draw()
	if mode == 'editor' then

		
		-- draw target area

		local thisWidth = self.sensorW * Camera.scale*8
		local thisHeight = self.sensorH * Camera.scale*8
		local x = (self.x + self.offsetX) * Camera.scale*8 - 0.5*thisWidth
		local y = (self.y + self.offsetY) * Camera.scale*8 - 0.5*thisHeight
		love.graphics.setColor(0,255,0,50)
		love.graphics.rectangle('fill',x,y,thisWidth,thisHeight)
		
		local thisWidth = self.sensorW * Camera.scale*8*(1-self.transition)
		local thisHeight = self.sensorH * Camera.scale*8*(1-self.transition)
		local x = (self.x + self.offsetX) * Camera.scale*8 - 0.5*thisWidth
		local y = (self.y + self.offsetY) * Camera.scale*8 - 0.5*thisHeight
		love.graphics.rectangle('fill',x,y,thisWidth,thisHeight)
		
		love.graphics.setColor(255,255,255)
	
		-- draw visualizers
		object.draw(self)
	end
end

function CameraguideRect:postStep(dt)
	local dx = p.x - self.x - self.offsetX
	local dy = p.y - self.y - self.offsetY


	if math.abs(dx) < 0.5*self.sensorW and math.abs(dy) < 0.5*self.sensorH then
		if self.transition == 0 then
			Camera:sendGuide(self.x,self.y,1)
		else
			local weight = 1-math.max(math.abs(dx/(0.5*self.sensorW)),math.abs(dy/(0.5*self.sensorH)))
			weight = weight / self.transition
			weight = math.min(weight,1)
			Camera:sendGuide(self.x,self.y,weight)
		end
	end
end

return CameraguideRect
