local upgrade = {color = 'none'}

local width = 128
local height = 80
local box = BambooBox:new( "", width, height )
local color
local thisTitle
local thisExplanation

local title ={
	none   = 'Nothing',
	white  = 'White Bandana',
	yellow = 'Yellow Bandana',
	green = 'Green Bandana',
	blue = 'Blue Bandana',
	red = 'Red Bandana',
}

local explanation = {
	none   = '\n\n\nYou already have this bandana.\n\n\nEnjoy this fish instead',
	white  = '\n\n\nBe a ninja, jump higher, run faster!\n\n\n\n Press any key to continue',
	yellow = '\n\n\nLearn the wall-jump.\n\n\n\n Press any key to continue',
	green = '\n\n\nUse it as a parachute.\n\n\n\n Press any key to continue',
	blue = '\n\n\nLearn the woosh.\n\n\n\n Press any key to continue',
	red = '\n\n\nUse it as grappling hook.\n\n\n\n Press any key to continue',
}

function upgrade:newBandana(color)
	mode = 'upgrade'
	shaders:setDeathEffect( .8 )
	color = Campaign:upgradeBandana(color)
	thisTitle = title[color]
	print(thisTitle)
	thisExplanation = explanation[color]

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
	
	love.graphics.setFont(fontLarge)	
	love.graphics.printf(thisTitle, x, y, box.pixelWidth-2*boundary, 'center' )
	
	y = y + fontLarge:getHeight()
	love.graphics.setFont(fontSmall)
	love.graphics.printf(thisExplanation, x, y, box.pixelWidth-2*boundary, 'center' )
end

function upgrade.keypressed()
	mode = 'game'
	shaders:resetDeathEffect()
end

function upgrade.joystickpressed(joystick, button)
	mode = 'game'
	shaders:resetDeathEffect()
end

return upgrade
