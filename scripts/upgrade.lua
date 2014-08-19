local upgrade = {}

local width = 128
local height = 80
local box = BambooBox:new( "", width, height )

function upgrade.draw()
	--game:draw()
	local x = 0.5*love.graphics.getWidth()/Camera.scale - 0.5*box.width
	local y = 0.5*love.graphics.getHeight()/Camera.scale - 0.5*box.height
	box:draw(x,y)
	local boundary = Camera.scale * 10
	x = 0.5*love.graphics.getWidth() - 0.5*box.pixelWidth + boundary
	y = 0.5*love.graphics.getHeight() - 0.5*box.pixelHeight + boundary
	
	love.graphics.setFont(fontLarge)
	local text1,text2
	if Campaign.bandana == 'white' then
		text1 = 'White Bandana'
		text2 = "\n\n\nBe a ninja, jump higher, run faster!\n\n\n\n Press any key to continue"
	else
		text1 = 'Yellow Bandana'
		text2 = "\n\n\nLearn the wall-jump.\n\n\n\n Press any key to continue"
	end
	
	love.graphics.printf(text1, x, y, box.pixelWidth-2*boundary, 'center' )
	
	y = y + fontLarge:getHeight()
	love.graphics.setFont(fontSmall)
	love.graphics.printf(text2, x, y, box.pixelWidth-2*boundary, 'center' )
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
