local Blockblock = object:New({
	tag = 'Blockblock',
	category = "Interactive",
  marginx = 0.8,
  marginy = 0.8,
  isInEditor = true,
  state = 'open',
  scaleTime = 0.2,
  scaling = 0.2,
  vis = {Visualizer:New('blockblock')},
	properties = {
		height = utility.newIntegerProperty(1,1,30),
		width  = utility.newIntegerProperty(1,1,30),
	},  
})

function Blockblock:addVertice(x,y,dx,dy,t)
	local mean,std = 0, 1/64
	local s = 0.3
	local thisX = (x + love.math.randomNormal(std,mean))*8*Camera.scale
	local thisY = (y + love.math.randomNormal(std,mean))*8*Camera.scale
	local thisDx = dx * 8 * Camera.scale * s
	local thisDy = dy * 8 * Camera.scale * s
	local newVert = {x=thisX,y=thisY,dx=thisDx,dy=thisDy,t=t}
	table.insert(self.vertsRef,newVert)
end

function Blockblock:applyOptions()
	self.vertsRef = {}

	local thisX,thisY,thisDx,thisDy,t
	-- top left corner
	self:addVertice(self.x-0.5,self.y-0.5,1,1,1)
	-- top 
	for i = 1,2*self.width-1 do
		thisX = self.x-0.5+0.5*i
		thisY = self.y-0.5
		self:addVertice(thisX,thisY,0,1,1)
	end
	-- top right corner
	self:addVertice(self.x-0.5+self.width,self.y-0.5,-1,1,1)
	-- right
	for i = 1,2*self.height-1 do
		thisX = self.x-0.5+self.width
		thisY = self.y-0.5 + 0.5*i
		self:addVertice(thisX,thisY,-1,0,1)
	end
	-- bottom right corner
	self:addVertice(self.x-0.5+self.width,self.y-0.5+self.height,-1,-1,1)
	-- bottom
	for i = 1,2*self.width-1 do
		thisX = self.x-0.5 +self.width-0.5*i
		thisY = self.y-0.5 + self.height
		self:addVertice(thisX,thisY,0,-1,1)
	end
	-- bottom left corner
	self:addVertice(self.x-0.5,self.y-0.5+self.height,1,-1,1)
	-- left
	for i = 1,2*self.height-1 do
		thisX = self.x-0.5
		thisY = self.y-0.5 + self.height - 0.5*i
		self:addVertice(thisX,thisY,1,0,1)
	end	

	self:makeOutline()
end

function Blockblock:tween(t)
	local thisT = t/self.scaleTime -- normalize
	return 1-utility.easingOvershoot(1-thisT)
	--if thisT > 1 then return 1 end
	--if thisT < 0 then return 0 end
	
	--return 0.5*(1-math.cos(thisT * math.pi))
	
end

function Blockblock:makeOutline()
	local newVerts = {}
	for i,v in ipairs(self.vertsRef) do
		local newX,newY
		local tween = Blockblock:tween(v.t)
		newX = v.x + v.dx * tween
		newY = v.y + v.dy * tween
		table.insert(newVerts,newX)
		table.insert(newVerts,newY)
	end
	self.vertices = newVerts
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
			--love.graphics.rectangle('fill',x,y,thisWidth,thisHeight)
			love.graphics.polygon('fill',self.vertices)
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
		-- find minimum distance
		local distMin = math.huge
		for i,v in ipairs(self.vertsRef) do
			local s = 8 * Camera.scale
			local dx,dy = p.x-v.x/s,p.y-v.y/s
			local dist = utility.pyth(dx,dy)
			distMin = math.min(distMin,dist)
		end
		-- set easing parameters
		for i,v in ipairs(self.vertsRef) do
			local s = 8 * Camera.scale
			local dx,dy = p.x-v.x/s,p.y-v.y/s
			local dist = utility.pyth(dx,dy)
			--v.t = self.scaleTime + (dist-distMin) * 0.1
			v.t = self.scaleTime + math.log(dist-distMin+1) * 0.1
		end
		
	elseif self.state == 'solid' then
		for i,v in ipairs(self.vertsRef) do
			v.t = math.max(v.t-dt,0)
		end
		self.scaling = math.max(self.scaling - dt,0)
		self:makeOutline()
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
return Blockblock
