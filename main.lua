-- main menu test

loading = require("scripts/loading")
config = require("scripts/config")
settings = require("scripts/settings")
profiler = require("scripts/profiler")
require 'scripts/camera'
require 'scripts/font'

threadInterface = require("scripts/threadInterface")

mode = 'menu'	-- must be global
paused = false
fullscreenCanvas = nil		-- initialized and maintained in settings:setWindowSize()
DEBUG = false

-- The version of the game. Should be updated on every game update.
GAME_VERSION = "0.1"
-- The level file version. Should be changed whenever there's an incompability
-- introduced in level file reading/writing level files:
MAPFILE_VERSION = "1"

--USE_SHADERS = true
--USE_SHADOWS = true

function love.load(args)
	-- prepare loading screen
	loading.preload()

	for k, v in pairs(arg) do
		if v == "--debug" or v == "-d" then
			DEBUG = true
		end
		if v == "--no-shaders" or v == "-n" then
			--USE_SHADERS = false
			settings:setShadowsEnabled( false )
			print("Manually disabled shaders.")
		end
		if v == "--no-shadows" or v == "-s" then
			settings:setShadersEnabled( false )
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
		elseif mode == 'editor' then
			editor:update( dt )
		end
		
		if fader.active then
			fader:update(dt)
		end
	
		if menu.transitionActive then
			menu:transition( dt )
		end
		if menu.curLevelName then
			menu:updateLevelName( dt )
		end

		if mode == 'levelEnd' and not menu.transitionActive then
			levelEnd:update( dt )
		end

		-- Must be called every frame, otherwise gamepad buttons
		-- are not recognized!
		keys.handleGamepad()
		
		shaders:update( dt )
	end

	threadInterface.update( dt )
	--print(love.joystick.getHat(1,1), love.joystick.getHat(1,2), love.joystick.getHat(1,3))
end

local a = 0

function love.draw()
	love.graphics.setShader()
	
	if mode == 'loading' then
		loading.draw()
	else
	
		shaders.draw()
	
		if mode == 'game' or mode == 'levelEnd' or mode == 'upgrade' or (mode == 'menu' and (menu.state == 'pause' or menu.state == 'rating')) then
			game:draw()
		elseif mode == 'menu' and menu.state ~= 'pause' then
			menu:draw()
		elseif mode == 'bridge' then
			bridge:draw()
		elseif mode == 'editor' then
			editor:draw()
		end

	
		if menu.transitionActive then
			menu:drawTransition()
		end

		shaders:stop()
		
		if not menu.transitionActive then
			if mode == 'levelEnd' then
				levelEnd:draw()
			elseif mode == 'menu' and (menu.state == 'pause' or menu.state == 'rating') then	-- draw AFTER grey shader!
				menu:draw()
			elseif mode == 'upgrade' then
				upgrade:draw()				
			--elseif mode == 'game' and game.isDead() then
				--controlKeys:draw("death")
			end
		end
		if menu.curLevelName then
			menu:drawLevelName()
		end
		if DEBUG then
			love.graphics.setFont(fontSmall)
			love.graphics.print("fps: " .. love.timer.getFPS(), 10, 20)
			love.graphics.print("cam scale: " .. Camera.scale, 10, 55 )
		end
				
		if fader.active then
			fader:draw()
		end
	end
end

function love.keypressed( key, repeated )

	if repeated then
		-- only let the menu receive multiple keypresses
		if mode == 'menu' then
			menu:keypressed( key, repeated )
		end
		return
	end

	if key == 'f1' then
		love.filesystem.load('scripts/sounddb.lua')()
		--Sound = require 'scripts/sound'
		Sound:loadAll()
	end
	
	if key == 'r' then
		profiler:report()
	elseif key == 't' then
		profiler:clear()
	elseif key == 'z' then
		print('Curr:' .. Campaign.current)
		print('Last:' .. Campaign.last)
	end
	
	if key == 'f6' then -- print all global variables
		for k,v in pairs(_G) do
			print(k .. ': ' .. type(v))
		end
	end
	
	--if menu.transitionActive and menu.transitionPercentage < 50 then return end
	
	if keys.currentlyAssigning then
		if menu.state == 'keyboard' then
			keys.assign( key )
		else
			keys.abortAssigning()
		end
		return
	elseif mode == 'editor' then
		editor.keypressed( key, repeated )
	else
	
		--if key == keys.FULLSCREEN then
		--	settings:toggleFullScreen()
		--end

		if mode == 'menu' then
			menu:keypressed( key, repeated )
		elseif mode == 'game' then
			game.keypressed( key )
		elseif mode == 'levelEnd' then
			levelEnd:keypressed( key, repeated )
		elseif mode == 'upgrade' then
			upgrade.keypressed(key, repeated)
		elseif mode == 'loading' then
			loading.keypressed()
		end

		-- always works, independently of game state:
		if key == keys.SCREENSHOT then
			love.graphics.newScreenshot():encode('screenshot.png')
			print('Saved screenshot')
		end
		if key == keys.RESTARTMAP then
			if myMap then myMap:start(p) end
		end
		if key == keys.RESTARTGAME then
			if Campaign and myMap then
				Campaign:reset()
				myMap:start(p)
			end
		end
	end
end


function love.keyreleased(key)
	if mode == 'game' then
		game.keyreleased(key)
	--elseif mode == 'editor' then
	--	editor.keyreleased(key)
	end
end

function love.joystickpressed(joystick, button)
	if keys.currentlyAssigning then
		if menu.state == 'gamepad' then
			keys.assign( tostring(button) )
		end
		return	
	end
	keys.pressGamepadKey( joystick, button )

	if mode == 'menu' then
		menu:gamepadpressed( button )
	elseif mode == 'loading' then
		loading.keypressed()
	end

	--[[
	if mode == 'game' then
		game.joystickpressed(joystick, button)
	end
	--if button == 9 then Campaign:reset() myMap:start(p) end
	]]--
	if mode == 'upgrade' then
		upgrade.joystickpressed(joystick, button)
	end	
end

function love.joystickreleased(joystick, button)
	if keys then keys.releaseGamepadKey( joystick, button ) end
	--[[if mode == 'game' then
		game.joystickreleased(joystick, button)
	end]]--
end

function love.joystickhat( joystick, hat, direction )
	keys.releaseGamepadKey( joystick, "l" )
	keys.releaseGamepadKey( joystick, "u" )
	keys.releaseGamepadKey( joystick, "d" )
	keys.releaseGamepadKey( joystick, "r" )
	if direction ~= "c" then
		-- don't allow diagonal:
		if direction == "lu" or direction == "ld" then
			direction = "l"
		elseif direction == "ru" or direction == "rd" then
			direction = "r"
		end
		keys.pressGamepadKey( joystick, direction )

		-- Treat joystick hat like a button:
		if mode == 'menu' then
			menu:gamepadpressed( direction )
		end
	end
end

function love.joystickadded( j )
	print( "New gamepad found:", j:getName() )
	if keys then keys.joystickadded( j ) end
	if love.joystick.getJoystickCount() == 1 then
		if menu then
			menu:connectedGamepad()
		end
	end
end

function love.joystickremoved( j )
	print( "Disconnected gamepad:", j:getName() )
	if keys then keys.joystickremoved( j ) end
	if love.joystick.getJoystickCount() == 0 then
		if menu then
			menu:disconnectedGamepad()
		end
	end
end

function love.textinput( letter )
	if mode == 'editor' then
		editor.textinput( letter )
	elseif mode == 'menu' then
		menu:textinput( letter )
	end
end

function love.mousepressed( x, y, button )
	if mode == 'editor' then
		editor:mousepressed( button, x, y )
	elseif mode == 'loading' then
		loading.keypressed()
	end
end

function love.mousereleased( x, y, button )
	if mode == 'editor' then
		editor:mousereleased( button, x, y )
	end
end

