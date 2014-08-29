
local Text = object:New({
	tag = 'Text',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  radius = 4,
  status = 0, -- determines the visibility - 0 invisible, 1 visible
  speed = 5,
  vis = {
		Visualizer:New('speechbubble'),
		Visualizer:New( nil, {active = false,relY = 0}, '' ),
		Visualizer:New('speechbubblepointer', {active=false}),
  },
	properties = {
		text = utility.newTextProperty(),
		display = utility.newCycleProperty( {"here", "player"},
				{"here", "on player"} , 1 ),
		sensorX = utility.newNumericTextProperty( 0, -math.huge, math.huge ),
		sensorY = utility.newNumericTextProperty( 3, -math.huge, math.huge ),
		sensorW = utility.newNumericTextProperty( 5, 0, math.huge ),
		sensorH = utility.newNumericTextProperty( 3, 0, math.huge ),
		--delay = utility.newNumericTextProperty( 0, -math.huge, math.huge ),
		--displayTime = utility.newNumericTextProperty( 10, 0.1, math.huge ),
		--regionSize = utility.newNumericTextProperty( 10, -math.huge, math.huge ),
	}, 
})

function Text:applyOptions()
	self.vis[2].text = self.text
	self.vis[2].ox = 0.5*fontSmall:getWidth(self.text)/Camera.scale
	
	local maxWidth = Camera.scale*8*6
	local width, nLines = fontSmall:getWrap(self.text, maxWidth)
	self.width = width+Camera.scale*4
	self.height = nLines * fontSmall:getHeight()+Camera.scale*4

	self.polygon = {}

	for i = 0, self.width, 15 do
		table.insert(self.polygon, -self.width*0.5 + i + math.random(-10,10)/10)	-- x value
		table.insert(self.polygon, -self.height*0.5 + math.random(-10,10)/10)	-- x value
	end
	for i = 0, self.height, 15 do
		table.insert(self.polygon, self.width*0.5 + math.random(-10,10)/10)	-- x value
		table.insert(self.polygon, -self.height*0.5 + i + math.random(-10,10)/10)	-- x value
	end
	for i = self.width, 0, -15 do
		table.insert(self.polygon, -self.width*0.5 + i + math.random(-10,10)/10)	-- x value
		table.insert(self.polygon, self.height*0.5 + math.random(-10,10)/10)	-- x value
	end
	for i = self.height, 0, -15 do
		table.insert(self.polygon, -self.width*0.5 + math.random(-10,10)/10)	-- x value
		table.insert(self.polygon, -self.height*0.5 + i + math.random(-10,10)/10)	-- x value
	end

	self.polygonTriangulated = love.math.triangulate( self.polygon )

	self.vis[3].relY = self.height/2/Camera.scale/8
	--self.vis[3].ox = self.vis[2].ox
end

function Text:setAcceleration(dt)
end

function Text:draw()
	-- draw speech bubble
	local x = self.x*Camera.scale*8
	local y = self.y*Camera.scale*8

	local tween = math.sqrt(1-(1-self.status)^2)
	-- local tween = self.status^2
	local thisWidth = self.width * tween
	local thisHeight = self.height * tween

	love.graphics.push()
	love.graphics.translate( x, y )
	love.graphics.scale( tween, tween )
	love.graphics.setColor(255,255,255,tween*255)
	--love.graphics.rectangle('fill',x-0.5*thisWidth,y-0.5*thisHeight,thisWidth,thisHeight)
	for i = 1, #self.polygonTriangulated do
		love.graphics.polygon( 'fill', self.polygonTriangulated[i] )
	end
	love.graphics.setColor(0,0,0,tween*255)
	--love.graphics.rectangle('line',x-0.5*thisWidth,y-0.5*thisHeight,thisWidth,thisHeight)
	love.graphics.polygon( 'line', self.polygon )
	love.graphics.setColor(255,255,255)
	love.graphics.pop()
	-- draw visualizers
	object.draw(self)
	
	if mode == 'editor' then
		thisWidth = self.sensorW * Camera.scale*8
		thisHeight = self.sensorH * Camera.scale*8
		x = (self.x + self.sensorX) * Camera.scale*8 - 0.5*thisWidth
		y = (self.y + self.sensorY) * Camera.scale*8 - 0.5*thisHeight
		love.graphics.setColor(0,0,0,50)
			love.graphics.rectangle('fill',x,y,thisWidth,thisHeight)
		love.graphics.setColor(255,255,255)
	end
end

function Text:postStep(dt)
	self.vis[1].active = (mode == 'editor')
	local dx = p.x - self.x
	local dy = p.y - self.y
	
	if dx > self.sensorX-0.5*self.sensorW and dx < self.sensorX + 0.5*self.sensorW and
	   dy > self.sensorY-0.5*self.sensorH and dy < self.sensorY + 0.5*self.sensorH then
		self.status = math.min(self.status + self.speed * dt,1)
	else
		self.status = math.max(self.status - self.speed * dt,0)
	end
	self.vis[2].active = (self.status > 0.9)
	self.vis[3].active = self.vis[2].active and (mode ~= 'editor')
end

return Text
