-- main menu test

menu = require("scripts/menu")
config = require("scripts/config")
require("scripts/misc")

require 'utility'
require 'camera'
require 'game'
require 'spritefactory'
--require 'menu'
require 'map'
require 'intro'
require 'campaign'

mode = 'menu'	-- must be global

DEBUG = false

function love.load(args)

	for k, v in pairs(arg) do
		if v == "--debug" or v == "-d" then
			DEBUG = true
		end
	end

	love.mouse.setVisible(false)

	Camera:init()

	recorder = false
	screenshots = {}
	recorderTimer = 0

	timer = 0

	Campaign:reset()

	mode = 'menu'
	menu.init()

end

function love.update( dt )
	if mode == 'game' then
		game:update(dt)
	--elseif mode == 'menu' then
	--	menu:update(dt)
	elseif mode == 'intro' then
		intro:update(dt)
	end
end

function love.draw()
	if mode == 'game' then
		game:draw()
	elseif mode == 'menu' then
		menu:draw()
	elseif mode == 'intro' then
		intro:draw()
	end
end

function love.keypressed( key, unicode )


	if mode == 'menu' then
		menu:keypressed( key, unicode )

		if key == 'escape' then
			love.event.quit()
		end
	elseif mode == 'game' then
		game.keypressed( key )
		
		if key == 'escape' then
			mode = 'menu'
			menu:init()
		end
	end

	-- always works, independently of game state:
	if key == 't' then
		love.graphics.newScreenshot():encode('screenshot.png')
		print('Saved screenshot')
	end
	if key == 'p' then
		myMap:start(p)
	end
	if key == 'o' then
		Campaign:reset()
		myMap:start(p)
	end
end
