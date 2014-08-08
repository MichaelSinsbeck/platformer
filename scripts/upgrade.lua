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
	love.graphics.printf('White Bandana', x, y, box.pixelWidth-2*boundary, 'center' )
	
	local text = "\n\n\nBe a ninja, jump higher, run faster!\n\n\n\n Press any key to continue"
	y = y + fontLarge:getHeight()
	love.graphics.setFont(fontSmall)
	love.graphics.printf(text, x, y, box.pixelWidth-2*boundary, 'center' )
end

function upgrade.keypressed()
	mode = 'game'
	shaders:resetDeathEffect()
end

return upgrade
