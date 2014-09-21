local menuBG

menuBG = {layers = {}}


local nLayers = 10
local velocity = 50
--local colorFront = {54,88,111}
local colorFront = {22,45,80}
local colorBack = {170,190,210}	

function menuBG:update(dt)
	local w,h = love.window.getDimensions()
	for i, layer in ipairs(self.layers) do
		local z = layer.z
		for iobj, object in pairs(layer.objects) do
			object.x = object.x - velocity*dt/z
			if object.x < -object.ox then 
				object.x = object.x + w + 2*object.ox
			end
		end
	end
end

function menuBG:draw()
	local w,h = love.window.getDimensions()
	for i = nLayers,1,-1 do
		local layer = self.layers[i]
		local z = layer.z
		local y = math.floor(0.6*h + 0.3*h/z)
		
		local factor = 1-(i-1)/nLayers
		local r = colorFront[1] * factor + colorBack[1]*(1-factor)
		local g = colorFront[2] * factor + colorBack[2]*(1-factor)
		local b = colorFront[3] * factor + colorBack[3]*(1-factor)		
		
		love.graphics.setColor(r,g,b)

		-- draw all the objects
		for iobj,object in ipairs(layer.objects) do
			local x = object.x
			local img = AnimationDB.image[object.image]
			local ox = img:getWidth()/2
			local oy = img:getHeight()

			love.graphics.draw(img,x, y,0,1/z,1/z,ox,oy)
		end
		-- draw rectangular ground
		love.graphics.rectangle('fill',0,y-3/z,w,h)		
	end
	love.graphics.setColor(255,255,255)	
end

function menuBG:clear()
end

function menuBG:init()
	local w,h = love.window.getDimensions()
	
	for i = 1,nLayers do
	self.layers[i]={}
	self.layers[i].z = (i/4)+0.75
	local x = 0
	local objects = {}
	while x < w do
		x = x + love.math.random()*250/self.layers[i].z
		local number = love.math.random(10)
		local imgName = 'silhouette' .. number
		local img = AnimationDB.image[imgName]
		local ox = img:getWidth()/2
		local oy = img:getHeight()
		
		x = math.floor(x + ox)
		
		local newObject = {x = x, y = 0, image =imgName,ox=ox,oy=oy}
		table.insert(objects,newObject)
	end
	self.layers[i].objects = objects
	end
end


return menuBG
