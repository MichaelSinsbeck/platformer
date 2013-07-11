function love.load()
	img = love.graphics.newImage('foto.png')
	nImages = 100
	x = {}
	y = {}
	angle = {}
	sounds = {}
	for i=1,nImages-1 do
		x[i] = math.random(1,love.graphics.getWidth()-img:getWidth())
		y[i] = math.random(1,love.graphics.getHeight()-img:getHeight())
		angle[i] = (1-2*math.random()) * math.pi/6
		sounds[i] = love.audio.newSource('pistachio1_click.wav','static')
	end
	x[nImages] = math.floor(0.5*(love.graphics.getWidth()-img:getWidth()))
	y[nImages] = math.floor(0.5*(love.graphics.getHeight()-img:getHeight()))
	angle[nImages] = 0
	sounds[nImages] = love.audio.newSource('pistachio1_click.wav','static')
	timer = 0
	lastImage = 0
end

function love.draw()
	for i = 1,lastImage do
		love.graphics.draw(img,x[i],y[i],angle[i])
	end
end

function love.update(dt)
	timer = timer + dt
	local newLastImage = math.min(nImages,math.floor(math.exp(timer)))
	if newLastImage > lastImage then
		lastImage = newLastImage
		love.audio.play(sounds[newLastImage])
	end

end
