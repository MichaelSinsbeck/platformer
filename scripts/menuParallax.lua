local menuBG

menuBG = {layers = {},mountainLayers = {}}


local nLayers = 10
local nMountainLayers = 3
local velocity = 50
--local colorFront = {54,88,111}
local colorFront = {22,45,80}
local colorBack = {170,190,210}	
local colorSky = {80,150,205}


function menuBG:update(dt)
	local w,h = love.window.getDimensions()

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

	-- draw layers
	for i = #self.layers,1,-1 do
		local layer = self.layers[i]
		local z = layer.z
		local y = z2y(h,z)
		local factor = 1-(i-1)/(nLayers+nMountainLayers)
		local r,g,b = mix2color(factor)		
		love.graphics.setColor(r,g,b)

		-- draw all the objects
		for iobj,object in ipairs(layer.objects) do
			local x = object.x
			local img = AnimationDB.image[object.image]
			local ox = img:getWidth()/2
			local oy = img:getHeight()

			love.graphics.draw(img,x, y,0,object.s,object.s,ox,oy)
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
			local s = 1/self.layers[i].z-- either -1 or 1
		
			local newObject = {x = x, y = 0, image =imgName,ox=ox,oy=oy,s=s}
			table.insert(objects,newObject)
			x = math.floor(x + ox/self.layers[i].z)
		end
		self.layers[i].objects = objects
	end
	-- generate mountain layer
	local zRef = 2*index2z(nLayers+1)
	for i=nLayers+1,nLayers+nMountainLayers do
		self.layers[i] = {}
		self.layers[i]. z = 2*index2z(i)
	
		local x = 0
		local objects = {}
		while x < w do
			local number = love.math.random(5)
			local imgName = 'mountain' .. number
			local img = AnimationDB.image[imgName]
			local ox = img:getWidth()/2
			local oy = img:getHeight()
			local s = zRef/self.layers[i].z
			x = math.floor(x + ox)
			local newObject = {x = x, y = 0, image =imgName,ox=ox,oy=oy,s=s}
			table.insert(objects,newObject)
			x = x + love.math.random()*100
		end	
		self.layers[i].objects = objects
	
	end
end



return menuBG
