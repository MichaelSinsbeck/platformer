
levelEnd = {}

local deathList = {}
local boxes = {}

function levelEnd:reset()
	deathList["fall"] = 0
	deathList["shuriken"] = 0
	deathList["goalie"] = 0
	deathList["imitator"] = 0
	deathList["missile"] = 0
	deathList["spikey"] = 0
	deathList["runner"] = 0
	deathList["walker"] = 0
end

function levelEnd:addDeath( deathType )
	deathList[deathType] = deathList[deathType] + 1
end

function levelEnd:draw()
	shaders:setDeathEffect( .8 )
	--shaders.grayScale:send( "amount", .8 )
	--love.graphics.setPixelEffect( shaders.grayScale )
	--game:draw()
	--love.graphics.setPixelEffect()
	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
	-- for now, just show a simple list:
	
	-- draw boxes:	
	for k,element in pairs(boxes) do
		-- scale box coordinates according to scale
		local scaled = {}
		for i = 1,#element.points do
			scaled[i] = element.points[i] * Camera.scale
		end
		-- draw
		love.graphics.setColor(44,90,160)
		love.graphics.setLineWidth(Camera.scale*0.5)
		love.graphics.rectangle('fill',
			element.left*Camera.scale,
			element.top*Camera.scale,
			element.width*Camera.scale,
			element.height*Camera.scale)
		love.graphics.setColor(0,0,10)
		love.graphics.line(scaled)
	end
	
	
	local font = love.graphics.getFont()
	local i = 0
	for k, v in pairs(deathList) do
		love.graphics.setColor(110,168,213)
		love.graphics.print(k, - font:getWidth(k) - 5, - font:getHeight()*(4 -i))
		love.graphics.setColor(255,255,255)
		love.graphics.print(v, 5, - font:getHeight()*(4-i))
		i = i+1
	end
	love.graphics.pop()
	
	controlKeys:draw("win")
end

function levelEnd:display( )	-- called when level is won:
	mode = 'levelEnd'
	love.graphics.setBackgroundColor(40,40,40)
	boxes = {}
	self:addBox(-30,-20,60,40)
end

function levelEnd:keypressed( key, unicode )
	if key == 'escape' then
		Campaign:setLevel(Campaign.current+1)
		Campaign:saveState()
		menu.startTransition(menu.initWorldMap)()	-- start the transition and fade into world map
		
	else
	  menu.startTransition(function () Campaign:proceed() end)()
	end
end

function levelEnd:addBox(left,top,width,height)
	local new = {}
	new.points = {}
	new.left = left
	new.top = top
	new.width = width
	new.height = height
	local index = 1
	local stepsize = 0
	table.insert(new.points, left)
	table.insert(new.points, top)
	for i = 1,math.floor(.2*width) do
		stepsize = width/math.floor(.2*width)
		table.insert(new.points, left + i*stepsize)
		table.insert(new.points, top)
	end
	
	for i = 1,math.floor(.2*height) do
		stepsize = height/math.floor(.2*height)
		table.insert(new.points, left+width)
		table.insert(new.points, top + i*stepsize)
	end
	
	for i = 1,math.floor(.2*width) do
		stepsize = width/math.floor(.2*width)
		table.insert(new.points, left + width - i*stepsize)
		table.insert(new.points, top + height)
	end
		
	for i = 1,math.floor(.2*height) do
		stepsize = height/math.floor(.2*height)
		table.insert(new.points, left)
		table.insert(new.points, top + height - i*stepsize)
	end
	
	for i = 1,#new.points-2 do
		new.points[i] = new.points[i] + 0.4*math.random() - 0.4*math.random()
	end
	new.points[#new.points-1] = new.points[1]
	new.points[#new.points] = new.points[2]

	table.insert(boxes, new)
end
