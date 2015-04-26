local upgrade = {color = 'none'}

local width = 128
local height = 80
local minTime = .5 -- minimum time, the player has to wait, before continue is possible
local box = BambooBox:new( "", width, height )
local color
local thisTitle
local thisExplanation
local startTime
local vis

local title ={
	none   = 'Nothing',
	white  = 'White Bandana',
	yellow = 'Yellow Bandana',
	green = 'Green Bandana',
	blue = 'Blue Bandana',
	red = 'Red Bandana',
}

local explanation = {
	none   = '\n\n\n\n\n\n\n\nYou already have this bandana.\nEnjoy a bowl of rice instead',
	white  = '\n\n\n\n\n\n\n\nBe a ninja, jump higher, run faster!',
	yellow = '\n\n\n\n\n\n\n\nLearn the wall-jump.',
	green = '\n\n\n\n\n\n\n\nUse it as a parachute.',
	blue = '\n\n\n\n\n\n\n\nLearn the woosh.',
	red = '\n\n\n\n\n\n\n\nUse it as grappling hook.',
}

local visNames = {
	none   = 'upgradeRice',
	white  = 'upgradeWhite',
	yellow = 'upgradeYellow',
	green = 'upgradeGreen',
	blue = 'upgradeBlue',
	red = 'Red Bandana',
}

function upgrade:newBandana(color)
	mode = 'upgrade'
	shaders:setDeathEffect( .8 )
	color = Campaign:upgradeBandana(color)
	thisTitle = title[color]
	print(thisTitle)
	thisExplanation = explanation[color]
	print(visNames[color])
	vis = Visualizer:New(visNames[color])
	vis:init()
	startTime = love.timer.getTime()

	gui.addBandana( color );
end			

function upgrade.draw()
	--game:draw()
	local x = 0.5*love.graphics.getWidth()/Camera.scale - 0.5*box.width
	local y = 0.5*love.graphics.getHeight()/Camera.scale - 0.5*box.height
	box:draw(x,y)
	local boundary = Camera.scale * 10
	x = 0.5*love.graphics.getWidth() - 0.5*box.pixelWidth + boundary
	y = 0.5*love.graphics.getHeight() - 0.5*box.pixelHeight + boundary
	
	love.graphics.setColor(colors.text) -- title
	love.graphics.setFont(fontLarge)
	love.graphics.printf(thisTitle, x, y, box.pixelWidth-2*boundary, 'center' )
	
	y = y + fontLarge:getHeight() -- explanation
	love.graphics.setColor(colors.text)
	love.graphics.setFont(fontSmall)
	love.graphics.printf(thisExplanation, x, y, box.pixelWidth-2*boundary, 'center' )
	
	if love.timer.getTime() > startTime + minTime then -- press key to continue
		love.graphics.setColor(colors.text2)
		y = 0.5*love.graphics.getHeight() + 0.5*box.pixelHeight - boundary - fontSmall:getHeight()
		love.graphics.printf('Press any key to continue', x, y, box.pixelWidth-2*boundary, 'center' )
	end
	
	-- Draw image
	x = 0.5 * love.graphics.getWidth()
	y = 0.5*love.graphics.getHeight() - 0.05*box.pixelHeight
	vis:draw(x,y)	
end

function upgrade.keypressed()
	if love.timer.getTime() > startTime + minTime then
		mode = 'game'
		shaders:resetDeathEffect()
	end
end

function upgrade.joystickpressed(joystick, button)
	if love.timer.getTime() > startTime + minTime then
		mode = 'game'
		shaders:resetDeathEffect()
	end
end

return upgrade
