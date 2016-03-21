
local TimedText = object:New({
	tag = 'TimedText',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  radius = 4,
  status = 0, -- determines the visibility - 0 invisible, 1 visible
  speed = 5,
  timer = 0,
  vis = {
		Visualizer:New('speechbubbleTimer'),
		Visualizer:New( nil, {active = false,relY = 0}, '' ),
		Visualizer:New('speechbubblepointer', {active=false}),
  },
	properties = {
		text = utility.newTextProperty(),
		location = utility.newCycleProperty( {"here", "player"},
				{"here", "player"} , 1 ),
		startTime = utility.newNumericTextProperty (0, 0, math.huge),
		duration = utility.newNumericTextProperty (0, 0, math.huge),
		hasPointer = utility.newCycleProperty({true,false},{'true','false'}),
	}, 
})

function TimedText:applyOptions()
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

function TimedText:setAcceleration(dt)
end

function TimedText:draw()

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
	love.graphics.setColor(255,255,255,tween*255)
	for i = 1, #self.polygonTriangulated do
		love.graphics.polygon( 'fill', self.polygonTriangulated[i] )
	end
	love.graphics.setColor(0,0,0,tween*255)
	love.graphics.setLineWidth(2/5*Camera.scale)
	love.graphics.polygon( 'line', self.polygon )
	love.graphics.setColor(255,255,255)
	love.graphics.pop()
	
	-- draw visualizers
	object.draw(self)
	
end

function TimedText:postStep(dt)
	self.timer = self.timer + dt
	self.vis[1].active = (mode == 'editor')

	if self.timer > self.startTime and self.timer < self.startTime + self.duration then
		self.status = math.min(self.status + self.speed * dt,1)
	else
		self.status = math.max(self.status - self.speed * dt,0)
	end
	self.vis[2].active = (self.status > 0.9)
	self.vis[3].active = self.vis[2].active and (mode ~= 'editor') and self.hasPointer
end

return TimedText
