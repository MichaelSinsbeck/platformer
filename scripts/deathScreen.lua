
local color = require 'scripts/colors'
local motivationalMessages = {
	"You died",
	--"No one is born a master",
}
local currentMessage = motivationalMessages[1]
local deathScreen = {}

function deathScreen:chooseMotivationalMessage()
	currentMessage = motivationalMessages[math.random(1,#motivationalMessages)]
end

function deathScreen:draw()

	-- black bars on top and bottom
	local H = love.graphics.getHeight()
	local W = love.graphics.getWidth()
	love.graphics.setColor( color.black )
	local progress = 1 - (1 - utility.clamp( (8 * game.deathtimer/game.fullDeathtime-1) , 0, 1))^2 
	love.graphics.rectangle('fill',0, H - Camera.scale * 20 * progress, W, Camera.scale * 20 * progress)
	love.graphics.rectangle('fill',0, 0, W, Camera.scale * 20 * progress)

	-- motivational text
	if game.deathtimer >= 0.25*game.fullDeathtime then
		love.graphics.setColor( color.white )
		love.graphics.setFont(fontLarge)
		love.graphics.printf( currentMessage,
			0, H - Camera.scale * 17, W, "center" )
		love.graphics.setFont(fontSmall)
		love.graphics.printf( "Press 'JUMP' to retry.",
			0, H - Camera.scale * 7, W, "center" )
	end
end
return deathScreen
