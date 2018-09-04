
local Text = object:New({
	tag = 'Text',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  radius = 4,
  status = 0, -- determines the visibility - 0 invisible, 1 visible
  speed = 5,
  vis = {
		Visualizer:New('speechbubbleSector'),
		Visualizer:New( nil, {active = false,relY = 0}, '' ),
		Visualizer:New('speechbubblepointer', {active=false}),
  },
	properties = {
		text = utility.newTextProperty(),
		location = utility.newCycleProperty( {"here", "player"},
				{"here", "player"} , 1 ),
		offsetX = utility.newNumericTextProperty( 0, -math.huge, math.huge ),
		offsetY = utility.newNumericTextProperty( 3, -math.huge, math.huge ),
		sensorW = utility.newNumericTextProperty( 5, 0, math.huge ),
		sensorH = utility.newNumericTextProperty( 3, 0, math.huge ),
		hasPointer = utility.newCycleProperty({true,false},{'true','false'}),		
	}, 
})

function Text:applyOptions()
	-- calculate size of speech bubble and generate a rectangle
	self.vis[2].text = self.text
	self.vis[2].ox = 0.5*fontSmall:getWidth(self.text)/Camera.scale
	
	local maxWidth = Camera.scale*8*6
	local width, nLines = fontSmall:getWrap(self.text, maxWidth)
	nLines = #nLines
	self.width = width+Camera.scale*4
	self.height = nLines * fontSmall:getHeight()+Camera.scale*4

	self.polygon = {}
	local nSegmentsx = math.floor(self.width/15)
	local nSegmentsy = math.floor(self.height/15)
	
	for i = 1, nSegmentsx do
		local step = self.width / nSegmentsx
		table.insert(self.polygon, -self.width*0.5 + i*step + math.random(-10,10)/10);
		table.insert(self.polygon, -self.height*0.5 + math.random(-10,10)/10);
	end
	for i = 1, nSegmentsy do
		local step = self.height / nSegmentsy
		table.insert(self.polygon, self.width*0.5 + math.random(-10,10)/10);
		table.insert(self.polygon, -self.height*0.5 + i*step+ math.random(-10,10)/10);
	end
	for i = 1, nSegmentsx do
		local step = self.width / nSegmentsx
		table.insert(self.polygon, self.width*0.5 - i*step + math.random(-10,10)/10);
		table.insert(self.polygon, self.height*0.5 + math.random(-10,10)/10);
	end
	for i = 1, nSegmentsy do
		local step = self.height / nSegmentsy
		table.insert(self.polygon, -self.width*0.5 + math.random(-10,10)/10);
		table.insert(self.polygon, self.height*0.5 - i*step+ math.random(-10,10)/10);
	end	

	self.polygonTriangulated = love.math.triangulate( self.polygon )

	self.vis[3].relY = self.height/2/Camera.scale/8
end

function Text:setAcceleration(dt)
end

function Text:draw()

	-- draw speech bubble
	local x,y
	if mode ~= 'editor' and self.location == 'player' then
		x = p.x * Camera.scale*8
		y = (p.y-2) * Camera.scale*8 - 0.5 * self.height		
		self.vis[2].relX = p.x-self.x
		self.vis[2].relY = p.y-self.y-2 - 0.5*self.height/(8*Camera.scale)		
		self.vis[3].relX = p.x - self.x
		self.vis[3].relY = p.y - self.y - 2
	else
		x = self.x*Camera.scale*8
		y = self.y*Camera.scale*8
	end

	local tween = math.sqrt(1-(1-self.status)^2)
	local thisWidth = self.width * tween
	local thisHeight = self.height * tween

	love.graphics.push()
	love.graphics.translate( x, y )
	love.graphics.scale( tween, tween )
	love.graphics.setColor(1,1,1,tween)
	for i = 1, #self.polygonTriangulated do
		love.graphics.polygon( 'fill', self.polygonTriangulated[i] )
	end
	love.graphics.setColor(0,0,0,tween*255)
	love.graphics.setLineWidth(2/5*Camera.scale)
	love.graphics.polygon( 'line', self.polygon )
	love.graphics.setColor(1,1,1)
	love.graphics.pop()
	-- draw visualizers
	object.draw(self)
	
	if mode == 'editor' then
		thisWidth = self.sensorW * Camera.scale*8
		thisHeight = self.sensorH * Camera.scale*8
		x = (self.x + self.offsetX) * Camera.scale*8 - 0.5*thisWidth
		y = (self.y + self.offsetY) * Camera.scale*8 - 0.5*thisHeight
		love.graphics.setColor(0,1,0,0.2)
			love.graphics.rectangle('fill',x,y,thisWidth,thisHeight)
		love.graphics.setColor(1,1,1)
	end
end

function Text:postStep(dt)
	self.vis[1].active = (mode == 'editor')
	local dx = p.x - self.x
	local dy = p.y - self.y

	if dx > self.offsetX-0.5*self.sensorW and dx < self.offsetX + 0.5*self.sensorW and
	   dy > self.offsetY-0.5*self.sensorH and dy < self.offsetY + 0.5*self.sensorH then
	  if self.status == 0 then
			self:playSound('textAppear')
	  end
		self.status = math.min(self.status + self.speed * dt,1)
	else
		if self.status == 1 then
			self:playSound('textDisappear')
		end
		self.status = math.max(self.status - self.speed * dt,0)
	end
	self.vis[2].active = (self.status > 0.9)
	self.vis[3].active = self.vis[2].active and (mode ~= 'editor') and self.hasPointer
end

return Text
