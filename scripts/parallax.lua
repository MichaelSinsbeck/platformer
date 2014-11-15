local Parallax

Parallax = {layers = {}}


local nLayers = 5
local nMountainLayers = 3
local velocity = 50
--local colorFront = {54,88,111}
local colorFront = {22,45,80}
local colorBack = {170,190,210}	
local colorSky = {80,150,205}
local baseLevel = 0.9


function Parallax:update(dt)
	local w,h = love.window.getDimensions()
	local dx = -velocity * dt
	if mode == 'game' or mode == 'levelEnd' then
		dx = Camera.dx
	end
	-- move layers horizontally (left/right)
	for i, layer in ipairs(self.layers) do
		local x = layer.x + dx/layer.z
		layer.x = x%w
	end
end

function Parallax:setPosition( posX )
	local w,h = love.window.getDimensions()
	-- move layers horizontally (left/right)
	for i, layer in ipairs(self.layers) do
		local x = posX/layer.z
		layer.x = x%w
	end
end

local function z2y(h,z)
	local dh
	if mode == "menu" then
		dh = (baseLevel*Camera.scale*8 + menu.yCamera) - 0.6*h
	else
		dh = (baseLevel*Camera.scale*8 + Camera.yWorld) - 0.6*h
	end
	
	return math.floor(0.6*h + dh / z)
end

local function mix2color(factor)
	local r = colorFront[1] * factor + colorBack[1]*(1-factor)
	local g = colorFront[2] * factor + colorBack[2]*(1-factor)
	local b = colorFront[3] * factor + colorBack[3]*(1-factor)
	return r,g,b
end

function Parallax:draw()
	local w,h = love.window.getDimensions()
	
	-- sky-color
	love.graphics.setColor(colorBack[1],colorBack[2],colorBack[3])
	love.graphics.rectangle('fill',0,0,w,h)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.mesh)

	-- draw layers
	for i = #self.layers,1,-1 do
		local layer = self.layers[i]
		local z = layer.z
		local x = layer.x
		local y = z2y(h,z)
		local factor = 1-(i-1)/(nLayers+nMountainLayers)
		local r,g,b = mix2color(factor)		
		love.graphics.setColor(r,g,b)

		love.graphics.draw(layer.batch,x,y)
		
		if y < h then
			love.graphics.rectangle('fill',0,y,w,h-y)
		end
	end
	love.graphics.setColor(255,255,255)	
end

function Parallax:clear()
	self.layers = {}
end


local function index2z(i)
	return math.exp((i-1)/5)
end

function Parallax:init(location,color,yLevel,frontlayers,backlayers,offset)
	self:clear()
	local w,h = love.window.getDimensions()
	
	location = location or 'town'
	color = color or blue
	baseLevel = yLevel or 18
	nLayers = frontlayers or 5
	nMountainLayers = backlayers or 3
	offset = offset or 0 -- offset in z-direction. 0 - first layer is at scale 1, 1 - first layer is one unit further back
	
	-- generate sky-mesh
	local vertices = {}
	vertices[1] = {0,0,0,0,colorSky[1],colorSky[2],colorSky[3],255}
	vertices[2] = {w,0,0,0,colorSky[1],colorSky[2],colorSky[3],255}
	vertices[3] = {w,.65*h,0,0,colorBack[1],colorBack[2],colorBack[3],255}
	vertices[4] = {0,.65*h,0,0,colorBack[1],colorBack[2],colorBack[3],255}
	self.mesh = love.graphics.newMesh(vertices)
	
	local img = AnimationDB.image.silhouettes
	-- generate layers
	for i = 1,nLayers do
		self.layers[i]={}
		
		self.layers[i].z = index2z(i+offset)
		self.layers[i].x = 0
		self.layers[i].batch = love.graphics.newSpriteBatch(img)
		local x = 0
		local objects = {}
		while x < w do
			x = x + love.math.random()*250/self.layers[i].z
			local nQuads = #AnimationDB.silhouette.town
			local number = love.math.random(nQuads)
			local quad = AnimationDB.silhouette.town[number]
			local _, _, wq, hq = quad:getViewport( )--- hier
			local ox = wq/2
			local oy = hq
			local s = 1/self.layers[i].z-- either -1 or 1
			
			self.layers[i].batch:add(quad,x-w,0,0,s,s,ox,oy)
			self.layers[i].batch:add(quad,x,0,0,s,s,ox,oy)
			if x-ox < 0 then
				self.layers[i].batch:add(quad,x+w,0,0,s,s,ox,oy)
			end
			if x+ox > w then
				self.layers[i].batch:add(quad,x-2*w,0,0,s,s,ox,oy)
			end
			x = math.floor(x + ox/self.layers[i].z)
		end
	end
	-- generate mountain layer
	local zRef = 2*index2z(nLayers+1)
	for i=nLayers+1,nLayers+nMountainLayers do
		self.layers[i] = {}
		self.layers[i].x = 0
		self.layers[i]. z = 2*index2z(i+offset)
		self.layers[i].batch = love.graphics.newSpriteBatch(img)
		local x = 0
		local objects = {}
		while x < w do
			local nQuads = #AnimationDB.silhouette.mountain
			local number = love.math.random(nQuads)
			local quad = AnimationDB.silhouette.mountain[number]
			local _, _, wq, hq = quad:getViewport( )--- hier
			local ox = wq/2
			local oy = hq
		
			local s = zRef/self.layers[i].z
			self.layers[i].batch:add(quad,x-w,0,0,s,s,ox,oy)
			self.layers[i].batch:add(quad,x,0,0,s,s,ox,oy)
			if x-ox < 0 then
				self.layers[i].batch:add(quad,x+w,0,0,s,s,ox,oy)
			end
			if x+ox > w then
				self.layers[i].batch:add(quad,x-2*w,0,0,s,s,ox,oy)
			end	
			x = math.floor(x + ox)
			x = x + love.math.random()*100
		end	
	
	end
end



return Parallax
