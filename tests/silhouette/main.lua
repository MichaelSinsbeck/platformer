function love.load()
nLayers = 3
scrollX = 0
scrollY = 1
yFactor = 20
-- define colors and interpolate
color = {}
color[1] = { 54, 88,111,255}
color[nLayers] = { 83,130,170,255}
for i = 2,nLayers-1 do
	local factor = (i-1)/(nLayers-1)
	local r = color[1][1]*(1-factor) + color[nLayers][1]*factor
	local g = color[1][2]*(1-factor) + color[nLayers][2]*factor
	local b = color[1][3]*(1-factor) + color[nLayers][3]*factor		
	color[i] = {r,g,b,255}
end
colorBG = {66,109,170}
love.graphics.setBackgroundColor(colorBG)

-- generate landscape
mesh = {}
for i = 1,nLayers do
	mesh[i] = love.graphics.newMesh( createVertices(i,0), nil, 'strip' )
end

-- place silhouettes
end

function love.update(dt)
	if love.keyboard.isDown('right') then
		scrollX = scrollX + .5 * dt
	end
	if love.keyboard.isDown('left') then
		scrollX = scrollX - .5 * dt
	end
	if love.keyboard.isDown('up') then
		scrollY = scrollY + 1 * dt
	end
	if love.keyboard.isDown('down') then
		scrollY = scrollY - 1 * dt
	end
	for i=1,nLayers do
		mesh[i]:setVertices(createVertices(i,scrollX));
	end
end

function love.draw()
	for i = 1,nLayers do
		love.graphics.setColor(color[i])

		love.graphics.draw(mesh[i])
	end
end

function createVertices(i,scrollX)
	local vertices = {}
	local yBase = 200+yFactor*2^i*scrollY
	for x = 0,800,20 do
		local count = #vertices+1 
		vertices[count] = {x,yBase-yFactor*i*love.math.noise(x/200/i+scrollX*i,i+.2),0,0,color[i][1],color[i][2],color[i][3],255};
		vertices[count+1] = {x,600,0,0,color[i][1],color[i][2],color[i][3],255};
	end
return vertices
end
