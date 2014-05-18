function love.load()
	tileSize = 40
	wLevel = 40
	hLevel = 40
	wScreen = 800
	hScreen = 600
	
	nLayers = 5
	
	colorFront = {54,88,111}
	colorBack = {170,190,210}
	colorSky = {66,109,170}
	
		
	layer = {}
	for i = nLayers,1,-1 do
		layer[#layer+1] = generateLayer(i+1, tileSize, wLevel,hLevel, wScreen,hScreen, colorFront,colorBack)
	end
		


	love.graphics.setBackgroundColor(colorSky)
	love.graphics.setLineStyle('smooth')
	love.graphics.setLineWidth(2)
	xCam, yCam = 0,0
	xCamMax = wLevel - (wScreen/tileSize) 
	yCamMax = hLevel - (hScreen/tileSize) 
end

function love.update(dt)
	local speed = 20
	if love.keyboard.isDown('left') then
		xCam = math.max(xCam - speed * dt,0)
	end
	if love.keyboard.isDown('right') then
		xCam = math.min(xCam + speed * dt,xCamMax)
	end
	if love.keyboard.isDown('up') then
		yCam = math.max(yCam - speed * dt,0)
	end
	if love.keyboard.isDown('down') then
		yCam = math.min(yCam + speed * dt,yCamMax)
	end			
end

function love.draw()
		love.graphics.setColor(255,255,255)
		for i,thisLayer in ipairs(layer) do
			local distance = thisLayer.distance
			
			love.graphics.push()
			love.graphics.translate(-xCam/distance*tileSize,-yCam/distance*tileSize)

			love.graphics.draw(thisLayer.mesh)
			love.graphics.setColor(thisLayer.color)			
			love.graphics.polygon('line',thisLayer.polygon)
			love.graphics.pop()
		end
end

function generateLayer(distance,tileSize,wLevel,hLevel,wScreen,hScreen,colorFront,colorBack)
	-- Input:
	-- scale: Factor by which the layer is scaled down in comparison to the tileSize
	-- tileSize: size of an unscaled tile
	-- wLevel,hLevel: size of the level (in tiles)
	-- wScreen, hScreen: size of the screen in pixels
	
	local scale = 1/distance
	-- account for very small levels (with black frame)
	wScreen = math.min(wScreen,wLevel*tileSize)
	hScreen = math.min(hScreen,hLevel*tileSize)
	
	local dx = tileSize * scale
	local w = math.ceil(wScreen/dx + (wLevel-wScreen/tileSize))
	local h = math.ceil(hScreen/dx + (hLevel-hScreen/tileSize))
	
	-- color mixing
	local weight = 2/distance
	local color = {colorFront[1] * weight+colorBack[1]*(1-weight),
								 colorFront[2] * weight+colorBack[2]*(1-weight),
	 							 colorFront[3] * weight+colorBack[3]*(1-weight)	}
	 							 
	local weight = 1/(1/(weight)+2)
	local color2 = {colorFront[1] * weight+colorBack[1]*(1-weight),
								 colorFront[2] * weight+colorBack[2]*(1-weight),
	 							 colorFront[3] * weight+colorBack[3]*(1-weight)	}		 							 
	
	-- generate height profile
	local height = {}
	local xFactor,yFactor = .08,7 --5
	for i=1,w do
		height[i] = math.floor(love.math.noise(i*xFactor,distance)*yFactor+0.5*h-15)
		height[i] = math.max(0,height[i])
	end
	
	-- generate polygon line	
	local polygon = {-1,-1,-1,height[1]}
	for i = 2,w do
		local idx = #polygon
			polygon[idx+1] = (i-1)
			polygon[idx+2] = height[i-1]
		if height[i-1] ~= height[i] then			
			polygon[idx+3] = i-1
			polygon[idx+4] = height[i]
		end
	end
	polygon[#polygon+1] = w+1
	polygon[#polygon+1] = height[w]	
	polygon[#polygon+1] = w+1
	polygon[#polygon+1] = -1	
	
	local sigma = .15
	for i=1,#polygon do
		polygon[i] = polygon[i] + (love.math.random() - love.math.random())*sigma
		polygon[i] = polygon[i]*dx
	end	
	
	-- find min y value
	minY = math.huge
	maxY = -math.huge
	for i = 2,#polygon,2 do
		polygon[i] = dx * h - polygon[i]
		minY = math.min(polygon[i],minY)
		maxY = math.max(polygon[i],maxY)		
	end

	local triangles = love.math.triangulate(polygon)

	-- generate mesh
	local vertices = {}
	for _,t in ipairs(triangles) do
		local x,y = {},{}
		x[1],y[1],x[2],y[2],x[3],y[3] = t[1], t[2], t[3], t[4], t[5], t[6]
		for i = 1,3 do
			local w = (y[i]-minY)/(maxY-minY)
			local r = (1-w)*color[1] + w*color2[1]
			local g = (1-w)*color[2] + w*color2[2]
			local b = (1-w)*color[3] + w*color2[3]						
			local v = {x[i],y[i],0,0,r,g,b,255}
			vertices[#vertices+1] = v
		end	
	end
	
	local mesh = love.graphics.newMesh(vertices,nil,'triangles')		

	return {polygon = polygon, mesh = mesh, distance = distance,color = color}
end
