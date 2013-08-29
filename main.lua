-- main menu test

menu = require("scripts/menu")
config = require("scripts/config")
settings = require("scripts/settings")
keys = require("scripts/keys")
require("scripts/misc")
shaders = require("scripts/shaders")

require 'scripts/utility'
require 'scripts/camera'
require 'scripts/game'
require 'scripts/spritefactory'
require 'scripts/map'
require 'scripts/intro'
require 'scripts/campaign'

mode = 'menu'	-- must be global
fullscreenCanvas = nil		-- initialized and maintained in settings:setWindowSize()
DEBUG = false

function love.load(args)

	for k, v in pairs(arg) do
		if v == "--debug" or v == "-d" then
			DEBUG = true
		end
	end

	-- hide mouse
	love.mouse.setVisible(false)

	-- set screen resolution (and fullscreen)
	Camera:init()
	
	menu:init()
	-- load all images
	AnimationDB:loadAll()
	
	keys.load()
	
	shaders.load()
	
	-- load and set font
	fontSmall = love.graphics.newImageFont("images/font/40fontSmall.png",
    " abcdefghijklmnopqrstuvwxyz0123456789.,?+&")
	fontLarge = love.graphics.newImageFont("images/font/40fontLarge.png",
    " abcdefghijklmnopqrstuvwxyz0123456789.,?+&")    
	love.graphics.setFont(fontSmall)

	recorder = false
	screenshots = {}
	recorderTimer = 0

	timer = 0

	Campaign:reset()

	mode = 'menu'
	menu.initMain()
end

function love.update( dt )
	if mode == 'game' then
		game:update(dt)
	elseif mode == 'menu' then
		menu:update(dt)
	elseif mode == 'intro' then
		intro:update(dt)
	end
	
	if menu.transitionActive then
		menu.transitionPercentage = menu.transitionPercentage + dt*100	-- 1 second
		shaders.fadeToBlack:send("percentage", menu.transitionPercentage)
		if menu.transitionPercentage >= 50 and menu.transitionEvent then
			menu.transitionEvent()
			menu.transitionEvent = nil		
		end
		if menu.transitionPercentage >= 100 then
			menu.transitionActive = false		
		end
	end
end

function love.draw()

	if menu.transitionActive then
		love.graphics.setCanvas(fullscreenCanvas)
		fullscreenCanvas:clear()
		love.graphics.setColor(love.graphics.getBackgroundColor())
		love.graphics.rectangle('fill', 0, 0, fullscreenCanvas:getWidth(), fullscreenCanvas:getHeight())
		love.graphics.setColor(255,255,255,255)
	end

	if mode == 'game' then
		game:draw()
	elseif mode == 'menu' then
		menu:draw()
	elseif mode == 'intro' then
		intro:draw()
	end
	
	if menu.transitionActive then
		love.graphics.setCanvas()
		love.graphics.setPixelEffect( shaders.fadeToBlack )
		love.graphics.draw(fullscreenCanvas, 0, 0)
		love.graphics.setPixelEffect()
	end
end

function love.keypressed( key, unicode )
	
	if keys.currentlyAssigning then
		keys.assign( key )
	else
	
		if key == keys.FULLSCREEN then
			settings:toggleFullScreen()
		end

		if mode == 'menu' then
			menu:keypressed( key, unicode )
		elseif mode == 'game' then
			game.keypressed( key )
		end

		-- always works, independently of game state:
		if key == keys.SCREENSHOT then
			love.graphics.newScreenshot():encode('screenshot.png')
			print('Saved screenshot')
		end
		if key == keys.RESTARTMAP then
			myMap:start(p)
		end
		if key == keys.RESTARTGAME then
			Campaign:reset()
			myMap:start(p)
		end
	end
end


function love.keyreleased(key)
	if mode == 'game' then
		game.keyreleased(key)
	end
end

function love.joystickpressed(joystick, button)
	if mode == 'game' then
		game.joystickpressed(joystick, button)
	end
	if button == 9 then Campaign:reset() myMap:start(p) end
end

function love.joystickreleased(joystick, button)
	if mode == 'game' then
		game.joystickreleased(joystick, button)
	end
end
