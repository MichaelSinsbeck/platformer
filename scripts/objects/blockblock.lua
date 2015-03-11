local Blockblock = object:New({
	tag = 'Blockblock',
	category = "Interactive",
  marginx = 0.8,
  marginy = 0.8,
  isInEditor = true,
  state = 'open',
  scaleTime = 0.1,
  scaling = 0.1,
  vis = {Visualizer:New('blockblock')},
	properties = {
		height = utility.newIntegerProperty(1,1,30),
		width  = utility.newIntegerProperty(1,1,30),
	},  
})

function Blockblock:applyOptions()
	local verts = {}
	local std = 0.5/(8*Camera.scale)
	local mean = 0
	for i = 1,2*self.width do -- top to left
		table.insert(verts,(self.x-0.5 + 0.5*i+love.math.randomNormal(std,mean)) * 8 * Camera.scale)
		table.insert(verts,(self.y-0.5+love.math.randomNormal(std,mean)) * 8 * Camera.scale)
	end
	for i = 1,2*self.height do -- right downwards
		table.insert(verts,(self.x-0.5+self.width+love.math.randomNormal(std,mean))*8*Camera.scale)
		table.insert(verts,(self.y-0.5+0.5*i+love.math.randomNormal(std,mean)) * 8 * Camera.scale)
	end
	for i = 1,2*self.width do -- top to left
		table.insert(verts,(self.x-0.5 + self.width - 0.5*i+love.math.randomNormal(std,mean)) * 8 * Camera.scale)
		table.insert(verts,(self.y-0.5 + self.height+love.math.randomNormal(std,mean)) * 8 * Camera.scale)
	end
	for i = 1,2*self.height do -- right downwards
		table.insert(verts,(self.x-0.5+love.math.randomNormal(std,mean))*8*Camera.scale)
		table.insert(verts,(self.y-0.5 + self.height - 0.5*i+love.math.randomNormal(std,mean)) * 8 * Camera.scale)
	end	
	self.vertices = verts
	--self.semiheight = self.height/2
	--self.semiwidth = self.width/2
end

function Blockblock:draw()
	if mode == 'editor' then
		object.draw(self)
		love.graphics.setColor(255,0,0,50)
		
		local thisWidth = self.width * Camera.scale*8
		local thisHeight = self.height * Camera.scale*8
		local x = (self.x - 0.5) * Camera.scale*8
		local y = (self.y - 0.5) * Camera.scale*8
		love.graphics.rectangle('fill',x,y,thisWidth,thisHeight)
	else		

		
		local thisWidth = (self.width-2*self.scaling) * Camera.scale*8
		local thisHeight = (self.height-2*self.scaling) * Camera.scale*8
		local x = (self.x - 0.5+self.scaling) * Camera.scale*8
		local y = (self.y - 0.5+self.scaling) * Camera.scale*8
		love.graphics.setLineWidth(Camera.scale*0.4)
		
		local lineColor
		local fillColor
		if self.state == 'open' then
			fillColor = {70,70,70}
			lineColor = {50,50,50}
		else
			fillColor = {140,140,140}
			local a = 120 * self.scaling/self.scaleTime
			lineColor = {a,a,a}
		end
		
		if self.vertices then
			love.graphics.setColor(fillColor)
			love.graphics.rectangle('fill',x,y,thisWidth,thisHeight)
			--love.graphics.polygon('fill',self.vertices)
			love.graphics.setColor(lineColor)		
			love.graphics.polygon('line',self.vertices)
		end
				
		
	--[[	local thisWidth = self.width * Camera.scale*8
		local thisHeight = self.height * Camera.scale*8
		local x = (self.x - 0.5) * Camera.scale*8
		local y = (self.y - 0.5) * Camera.scale*8

		love.graphics.rectangle('fill',x,y,thisWidth,thisHeight)--]]
		love.graphics.setColor(255,255,255)
	end
end

function Blockblock:setAcceleration(dt)
end

function Blockblock:postStep(dt)
	local isTouching = self:touchPlayer()
	if self.state == 'open' and isTouching then
		self.state = 'hover'
	elseif self.state == 'hover' and not isTouching then
		self.state = 'solid'
		self:blockTiles()
		self.scaling = self.scaleTime
	elseif self.state == 'solid' then
		self.scaling = math.max(self.scaling - dt,0)
	end
end

function Blockblock:blockTiles()
	if not myMap then
		return
	end

	for xi = math.floor(self.x), math.floor(self.x) + self.width - 1 do
		for yi = math.floor(self.y), math.floor(self.y) + self.height - 1 do
			if myMap.collision and myMap.collision[xi] then
				myMap.collision[xi][yi] = 1
			end
		end
	end

end

function Blockblock:touchPlayer()
  local dx = self.x - 0.5 + 0.5 * self.width -p.x
  local dy = self.y - 0.5 + 0.5 * self.height -p.y
  return math.abs(dx) < p.semiwidth+0.5*self.width and
     math.abs(dy) < p.semiheight+0.5*self.height
end

--[[function Blockblock:postStep(dt)
	self.vis[1].sx = math.min(self. vis[1].sx+dt,1)
	self.vis[1].sy = self.vis[1].sx	
	
	if self.state == 'solid'
			and self.vis[1]
			and self.vis[1].animation:sub(-8) == 'Passable'
	    and not self:touchPlayer() then
		self:setAnim(self.color .. 'BlockSolid')
		self.vis[1].sx = 0.77
		self.vis[1].sy = self.vis[1].sx
	end
end

function Blockblock:buttonPress(color)
	if self.color == color then
		self:invert()
  end
end

function Blockblock:invert()
	if self.state == 'solid' then
		self:setAnim(self.color .. 'BlockPassable')
		self.state = 'passable'
		if myMap then
			if myMap.collision and myMap.collision[math.floor(self.x)] then
				myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
			end
			myMap:queueShadowUpdate()
		end
	else
		self.state = 'solid'
		if myMap then
			if myMap.collision and myMap.collision[math.floor(self.x)] then
				myMap.collision[math.floor(self.x)][math.floor(self.y)] = 1
			end
			myMap:queueShadowUpdate()
		end
		if not self:touchPlayer() then
			self:setAnim(self.color .. 'BlockSolid')
			self.vis[1].sx = 0.77
			self.vis[1].sy = self.vis[1].sx
		end
	end
end

function Blockblock:setState( newState )
	if newState == 'passable' then
		self:setAnim(self.color .. 'BlockPassable')
		self.state = 'passable'
		if myMap then
			if myMap.collision and myMap.collision[math.floor(self.x)] then
				myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
			end
			myMap:queueShadowUpdate()
		end
	else
		self.state = 'solid'
		if myMap then
			if myMap.collision and myMap.collision[math.floor(self.x)] then
				myMap.collision[math.floor(self.x)][math.floor(self.y)] = 1
			end
			myMap:queueShadowUpdate()
		end
		self:setAnim(self.color .. 'BlockSolid')
		self.vis[1].sx = 1
		self.vis[1].sy = self.vis[1].sx
	end
end--]]

return Blockblock
