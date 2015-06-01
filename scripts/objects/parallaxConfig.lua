local ParallaxConfig = object:New({
	tag = 'ParallaxConfig',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  radius = 4,
  vis = {
		Visualizer:New('parallaxConfig'),
  },
	properties = {
		--frontlayers = utility.newProperty({1,2,3,4,5,6,7,8}),
		--backlayers = utility.newProperty({1,2,3,4,5}),
		location = utility.newCycleProperty({1,2,3,4,5}),
		color = utility.newCycleProperty({'blue','red','yellow','green','gray'})
	}, 
})

function ParallaxConfig:applyOptions()
end

function ParallaxConfig:setAcceleration(dt)
end

function ParallaxConfig:postStep(dt)
	local dist = math.sqrt((self.x+self.offsetX - p.x)^2 + (self.y+self.offsetY-p.y)^2)
	if dist < self.radius then
		local weight
		weight = (1-(dist/self.radius))/self.transition
		weight = math.min(weight,1)
		Camera:sendGuide(self.x,self.y,weight)
	end
end

return ParallaxConfig
