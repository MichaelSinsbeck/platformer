-- main menu test

menu = require("scripts/menu")
config = require("scripts/config")

function love.load()
	love.graphics.setBackgroundColor(40,40,40)
	menu.init()
end

function love.update()

end

function love.draw()
	if menu.active then
		menu.draw()
	end
end

function love.keypressed( key, unicode )
	if menu.active then
		menu.keypressed( key, unicode )
	end
end
