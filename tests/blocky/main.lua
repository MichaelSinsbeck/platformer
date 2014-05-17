function love.load()
	--[[nBlocks = 30
	dx = 800/nBlocks
	scale = 200
	height = {}
	maxHeight = 0
	for i=1,nBlocks do
		local h = love.math.noise(i*dx/scale)*300+50
		height[i] = math.floor(h/dx)*dx
		maxHeight = math.max(maxHeight,height[i])
	end
	polygon = {0,0,0,-height[1]}
	for i = 2,nBlocks do
		local idx = #polygon
			polygon[idx+1] = (i-1)*dx
			polygon[idx+2] = -height[i-1]
		if height[i-1] ~=height[i] then			
			polygon[idx+3] = (i-1)*dx
			polygon[idx+4] = -height[i]
		end
	end
	polygon[#polygon+1] = nBlocks*dx
	polygon[#polygon+1] = -height[nBlocks]	
	polygon[#polygon+1] = nBlocks*dx
	polygon[#polygon+1] = 0	

	local sigma = 1
	for i=1,#polygon do
		polygon[i] = polygon[i] + love.math.randomNormal()*sigma
	end

	for i = 2,#polygon,2 do
	polygon[i] = polygon[i] + 600
	end
	triangles = love.math.triangulate(polygon)

	color = {54, 88,111,255}

	vertices = {}
	for _,t in ipairs(triangles) do
		local x1,y1,x2,y2,x3,y3 = t[1], t[2], t[3], t[4], t[5], t[6]
		local f1,f2,f3 = (600-y1)/maxHeight,(600-y2)/maxHeight,(600-y3)/maxHeight
		local v1 = {x1,y1,0,0,color[1]*f1,color[2]*f1,color[3]*f1,255}
		local v2 = {x2,y2,0,0,color[1]*f2,color[2]*f2,color[3]*f2,255}
		local v3 = {x3,y3,0,0,color[1]*f3,color[2]*f3,color[3]*f3,255}
		
		vertices[#vertices+1] = v1
		vertices[#vertices+1] = v2
		vertices[#vertices+1] = v3		
	end
	
	mesh = love.graphics.newMesh(vertices,nil,'triangles')--]]
	polygon = {}
	mesh = {}
	polygon[1],mesh[1] = generateLayer(.9,40,20,15,800,600)
	polygon[2],mesh[2] = generateLayer(.5,40,20,15,800,600)
	polygon[3],mesh[3] = generateLayer(.25,40,20,15,800,600)		
	--polygon = generateLayer(.5,40,32,20,800,800)
		
	colorBG = {66,109,170}
	love.graphics.setBackgroundColor(colorBG)
	love.graphics.setLineStyle('smooth')
end

function love.draw()

		--love.graphics.setColor(100,100,100)

		love.graphics.setColor(255,255,255)
		for i = 3,1,-1 do
			local c = (i/3)*255
			love.graphics.setColor(c,c,c)
			love.graphics.draw(mesh[i])
			love.graphics.polygon('line',polygon[i])
		end



end

function generateLayer(scale,tileSize,wLevel,hLevel,wScreen,hScreen)
	-- Input:
	-- scale: Factor by which the layer is scaled down in comparison to the tileSize
	-- tileSize: size of an unscaled tile
	-- wLevel,hLevel: size of the level (in tiles)
	-- wScreen, hScreen: size of the screen in pixels
	
	-- account for very small levels (with black frame)
	wScreen = math.min(wScreen,wLevel*tileSize)
	hScreen = math.min(hScreen,hLevel*tileSize)
	print('wScreen, hScreen: ' .. wScreen ..', ' .. hScreen)
	local dx = tileSize * scale
	local w = math.ceil(wScreen/dx + (wScreen/tileSize-wLevel))
	local h = math.ceil(hScreen/dx + (hScreen/tileSize-hLevel))
	print('w, h: ' .. w .. ', ' .. h)
	
	local height = {}
	local xFactor,yFactor = .14,5
	
	for i=1,w do
		height[i] = math.floor((2*love.math.noise(i*xFactor)-1)*yFactor+0.25*h)
		height[i] = math.max(1,height[i])
	end
	

	
	local polygon = {0,0,0,height[1]}
	for i = 2,w do
		local idx = #polygon
			polygon[idx+1] = (i-1)
			polygon[idx+2] = height[i-1]
		if height[i-1] ~= height[i] then			
			polygon[idx+3] = i-1
			polygon[idx+4] = height[i]
		end
	end
	polygon[#polygon+1] = w
	polygon[#polygon+1] = height[w]	
	polygon[#polygon+1] = w
	polygon[#polygon+1] = 0	
	
	local sigma = .03
	for i=1,#polygon do
		polygon[i] = polygon[i] + love.math.randomNormal()*sigma
		polygon[i] = polygon[i]*dx
	end	
	for i = 2,#polygon,2 do
		polygon[i] = hScreen - polygon[i]
	end
	
	local triangles = love.math.triangulate(polygon)

	--color = {54, 88,111,255}

	local vertices = {}
	for _,t in ipairs(triangles) do
		local x1,y1,x2,y2,x3,y3 = t[1], t[2], t[3], t[4], t[5], t[6]
		--local f1,f2,f3 = (600-y1)/maxHeight,(600-y2)/maxHeight,(600-y3)/maxHeight
		local v1 = {x1,y1,0,0,255,255,255,255}
		local v2 = {x2,y2,0,0,255,255,255,255}
		local v3 = {x3,y3,0,0,255,255,255,255}
		
		vertices[#vertices+1] = v1
		vertices[#vertices+1] = v2
		vertices[#vertices+1] = v3		
	end
	
	local mesh = love.graphics.newMesh(vertices,nil,'triangles')		
			
	return polygon,mesh
end
