local menuBG

menuBG = {layers = {}}


local nLayers = 10
local velocity = 50
--local colorFront = {54,88,111}
local colorFront = {22,45,80}
local colorBack = {170,190,210}	
local colorSky = {80,150,205}

function menuBG:update(dt)
	local w,h = love.window.getDimensions()
	-- mountains
	local z = self.mountainz
	for iobj, object in pairs(self.mountainobjects) do
		object.x = object.x - velocity*dt/z
		if object.x < -object.ox then 
			object.x = object.x + w + 2*object.ox
		end
	end
	-- move front layers
	for i, layer in ipairs(self.layers) do
		local z = layer.z
		for iobj, object in pairs(layer.objects) do
			object.x = object.x - velocity*dt/z
			if object.x < -object.ox/z then 
				object.x = object.x + w + 2*object.ox/z
			end
		end
	end
end

local function z2y(h,z)
	return math.floor(0.6*h+0.3*h/z)
end

local function mix2color(factor)
	local r = colorFront[1] * factor + colorBack[1]*(1-factor)
	local g = colorFront[2] * factor + colorBack[2]*(1-factor)
	local b = colorFront[3] * factor + colorBack[3]*(1-factor)
	return r,g,b
end

function menuBG:draw()
	local w,h = love.window.getDimensions()
	
	-- sky-color
	love.graphics.draw(self.mesh)
	-- mountains
	local y = z2y(h,self.mountainz)
	local r,g,b = mix2color(0)
	local z = self.mountainz
	love.graphics.setColor(r,g,b)
	
	for iobj,object in ipairs(self.mountainobjects) do
		local x = math.floor(object.x)
		local img = AnimationDB.image[object.image]
		local ox = img:getWidth()/2
		local oy = img:getHeight()
		love.graphics.draw(img,x, y,0,object.s,1,ox,oy)
	end
	love.graphics.rectangle('fill',0,y,w,h)	

	-- front layers
	local lastz = self.layers[nLayers].z+1
	local firstz = self.layers[1].z
	for i = nLayers,1,-1 do
		local layer = self.layers[i]
		local z = layer.z
		local y = z2y(h,z)
		
		local factor = 1-(i-1)/nLayers
		--local factor = (z-lastz)/(firstz-lastz)
		local r,g,b = mix2color(factor)
		
		love.graphics.setColor(r,g,b)

		-- draw all the objects
		for iobj,object in ipairs(layer.objects) do
			local x = object.x
			local img = AnimationDB.image[object.image]
			local ox = img:getWidth()/2
			local oy = img:getHeight()

			love.graphics.draw(img,x, y,0,object.s/z,1/z,ox,oy)
		end
		-- draw rectangular ground
		love.graphics.rectangle('fill',0,y,w,h)
	end
	love.graphics.setColor(255,255,255)	
end

function menuBG:clear()
end


local function index2z(i)
	return math.exp((i-1)/5)
end

function menuBG:init()
	local w,h = love.window.getDimensions()
	-- generate sky-mesh
	local vertices = {}
	vertices[1] = {0,0,0,0,colorSky[1],colorSky[2],colorSky[3],255}
	vertices[2] = {w,0,0,0,colorSky[1],colorSky[2],colorSky[3],255}
	vertices[3] = {w,.65*h,0,0,colorBack[1],colorBack[2],colorBack[3],255}
	vertices[4] = {0,.65*h,0,0,colorBack[1],colorBack[2],colorBack[3],255}
	self.mesh = love.graphics.newMesh(vertices)
	
	-- generate layers
	for i = 1,nLayers do
		self.layers[i]={}
		--self.layers[i].z = (i/4)+0.75
		
		self.layers[i].z = index2z(i)
		local x = 0
		local objects = {}
		while x < w do
			x = x + love.math.random()*250/self.layers[i].z
			local number = love.math.random(11)
			local imgName = 'silhouette' .. number
			local img = AnimationDB.image[imgName]
			local ox = img:getWidth()/2
			local oy = img:getHeight()
			local s = love.math.random(2)*2-3 -- either -1 or 1
		
			local newObject = {x = x, y = 0, image =imgName,ox=ox,oy=oy,s=s}
			table.insert(objects,newObject)
			x = math.floor(x + ox/self.layers[i].z)
		end
		self.layers[i].objects = objects
	end
	-- generate mountain layer
	self.mountainz = 2*index2z(nLayers+1)
	local x = 0
	local objects = {}
	while x < w do
		
		local number = love.math.random(5)
		local imgName = 'mountain' .. number
		local img = AnimationDB.image[imgName]
		local ox = img:getWidth()/2
		local oy = img:getHeight()
		local s = 1
		
		x = math.floor(x + ox)
		
		local newObject = {x = x, y = 0, image =imgName,ox=ox,oy=oy,s=s}
		table.insert(objects,newObject)
		x = x + love.math.random()*100
	end	
	self.mountainobjects = objects
end



return menuBG
