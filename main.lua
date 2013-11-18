-- main menu test


loading = require("scripts/loading")
config = require("scripts/config")
settings = require("scripts/settings")
require 'scripts/camera'
require 'scripts/font'

mode = 'menu'	-- must be global
fullscreenCanvas = nil		-- initialized and maintained in settings:setWindowSize()
DEBUG = false
USE_SHADERS = true
USE_SHADOWS = true

function love.load(args)
	-- prepare loading screen
	loading.preload()

	for k, v in pairs(arg) do
		if v == "--debug" or v == "-d" then
			DEBUG = true
		end
		if v == "--no-shaders" or v == "-n" then
			USE_SHADERS = false
			print("Manually disabled shaders.")
		end
		if v == "--no-shadows" or v == "-s" then
			USE_SHADOWS = false
			print("Enabled shadows")
		end
	end
end

function love.update( dt )
	if mode == 'loading' then
		loading.update( dt )
	else

		if mode == 'game' then
			game:update(dt)
		elseif mode == 'menu' then
			menu:update(dt)
		elseif mode == 'bridge' then
			bridge:update(dt)
		end
	
		if menu.transitionActive then
			menu:transition( dt )
		end

		keys.catchGamepadEvents()
		
		shaders:update( dt )
	end
	--print(love.joystick.getHat(1,1), love.joystick.getHat(1,2), love.joystick.getHat(1,3))
	--vis:update(dt)
end

local a = 0

function love.draw()
	love.graphics.setPixelEffect()
	
	if mode == 'loading' then
		loading.draw()
	else
	
		shaders.draw()
	
		if mode == 'game' or mode == 'levelEnd' then
			game:draw()
		elseif mode == 'menu' then
			menu:draw()
		elseif mode == 'bridge' then
			bridge:draw()
		end
	
		if menu.transitionActive and menu.transitionPercentage < 50 then	
			local sx = (menu.transitionPercentage/15)^3
		
		end
	
		shaders:stop()
		
		if mode == 'levelEnd' then
			levelEnd:draw()
		end
		
		if DEBUG then
			love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 20)
		end
	end
	
	--vis:draw(100,100)
end

function love.keypressed( key, unicode )
	if key == 'z' then
		print('Curr:' .. Campaign.current)
		print('Last:' .. Campaign.last)
	end
	if menu.transitionActive then return end
	
	if keys.currentlyAssigning then
		if menu.state == 'keyboard' then
			print("new", key)
			keys.assign( key )
		end
		return
	else
	
		if key == keys.FULLSCREEN then
			settings:toggleFullScreen()
		end

		if mode == 'menu' then
			menu:keypressed( key, unicode )
		elseif mode == 'game' then
			game.keypressed( key )
		elseif mode == 'levelEnd' then
			levelEnd:keypressed( key, unicode )
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
	if keys.currentlyAssigning then	
		if menu.state == 'gamepad' then
			keys.assign( tostring(button) )
		end
		return	
	end

	if mode == 'game' then
		game.joystickpressed(joystick, button)
	end
	--if button == 9 then Campaign:reset() myMap:start(p) end
end

function love.joystickreleased(joystick, button)
	if mode == 'game' then
		game.joystickreleased(joystick, button)
	end
end
