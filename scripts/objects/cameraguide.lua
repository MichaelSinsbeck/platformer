local Cameraguide = object:New({
	tag = 'CameraGuide',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  radius = 4,
  vis = {
		Visualizer:New('cameraRound'),
  },
	properties = {
		radius = utility.newNumericTextProperty( 5,1,math.huge),
		transition = utility.newNumericTextProperty(0.2,0.01,1),
		offsetX = utility.newNumericTextProperty(0,-math.huge,math.huge),
		offsetY = utility.newNumericTextProperty(0,-math.huge,math.huge),
	}, 
})

function Cameraguide:applyOptions()
end

function Cameraguide:setAcceleration(dt)
end

function Cameraguide:draw()
	if mode == 'editor' then

		
		-- draw target area
		local thisRadius = self.radius * Camera.scale*8
		local thisSmallRadius = thisRadius * (1-self.transition)
		local x = (self.x + self.offsetX) * Camera.scale*8
		local y = (self.y + self.offsetY) * Camera.scale*8
		love.graphics.setColor(0,1,0,0.2)
		--love.graphics.rectangle('fill',x,y,thisWidth,thisHeight)
		love.graphics.circle('fill',x,y,thisRadius)
		love.graphics.circle('fill',x,y,thisSmallRadius)
		love.graphics.setColor(1,1,1)
		
		-- draw visualizers
		object.draw(self)
	end
end

function Cameraguide:postStep(dt)
	local dist = math.sqrt((self.x+self.offsetX - p.x)^2 + (self.y+self.offsetY-p.y)^2)
	if dist < self.radius then
		local weight
		weight = (1-(dist/self.radius))/self.transition
		weight = math.min(weight,1)
		Camera:sendGuide(self.x,self.y,weight)
	end
end

return Cameraguide
