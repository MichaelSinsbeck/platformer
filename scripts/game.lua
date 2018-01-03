require 'scripts/spriteengine'
require 'scripts/visualizer'
local deathScreen = require 'scripts/deathScreen'

game = {
	deathtimer = 0,
	fullDeathtime = 5, -- time until death effect is over
}

function game:draw()

	--myMap:drawParallax()
	Camera:setPureScissor()
	parallax:draw()
	Camera:apply()

	-- background tiles
	myMap:drawBackground()
	
	if settings:getShadowsEnabled() and shadows:getNumLights() > 0 then
		love.graphics.push()
		love.graphics.translate( -myMap.tileSize, -myMap.tileSize )
		shadows:draw()
		love.graphics.pop()
	end
	
	myMap:drawGround()
	myMap:drawForeground()
	
	spriteEngine:draw()
	
	

	--love.graphics.setColor(255,255,255) 
	
	Camera:free()

	gui.draw()


	if recorderTimer > 1/30 then
		recorderTimer = recorderTimer-1/30
		table.insert(screenshots,love.graphics.newScreenshot())
	end
end

function game:checkControls()
 -- local joyHat = love.joystick.getHat(1,1)
  self.isLeft = love.keyboard.isDown( keys.LEFT ) 
		or keys.getGamepadIsDown( nil, keys.PAD.LEFT )
	self.isRight = love.keyboard.isDown( keys.RIGHT )
		or keys.getGamepadIsDown( nil, keys.PAD.RIGHT )
	self.isDown = love.keyboard.isDown( keys.DOWN )
		or keys.getGamepadIsDown( nil, keys.PAD.DOWN )
	self.isUp = love.keyboard.isDown( keys.UP )
		or keys.getGamepadIsDown( nil, keys.PAD.UP )
	self.isJump = love.keyboard.isDown( keys.JUMP ) 
		or keys.getGamepadIsDown( nil, keys.PAD.JUMP )
	self.isAction = love.keyboard.isDown( keys.ACTION )
		or keys.getGamepadIsDown( nil, keys.PAD.ACTION )
	self.isDash = love.keyboard.isDown( keys.DASH )
	  or keys.getGamepadIsDown( nil, keys.PAD.DASH )
	--print(keys.PAD_JUMP, tonumber(keys.PAD_JUMP), love.joystick.isDown(1, tonumber(keys.PAD_JUMP)))
	--print(self.isJump)
end

function game:update(dt)
	--dt = 1/60
	timer = timer + dt
	Camera:resetGuide()
	spriteEngine:update(dt)

	--  Camera:setTarget()
	Camera:update(dt)
	parallax:update(dt)

	if game.won then
		Sound:stopAllLongSounds()
		game.won = nil
		levelEnd:registerEnd()
		levelEnd:display()
	end

	if p.dead then
		if self.deathtimer == 0 then
			deathScreen:chooseMotivationalMessage()
		end
		self.deathtimer = self.deathtimer + dt
		-- finish fade-to-black in less time than full death sequence:
		shaders:setDeathEffect(	self.deathtimer/(self.fullDeathtime*0.3) )
	end

	--[[if self.deathtimer >= self.fullDeathtime or (DEBUG and self.deathtimer > .5) then
		if not self.restartingLevel then
			myMap:start(p)
			--self.restartingLevel = true
		end
	end]]

	if p.y > myMap.height+2 and not p.dead then
		p.dead = true
		spriteEngine:DoAll('disconnect') -- release rope, if existant
		levelEnd:addDeath("death_fall")
		objectClasses.Meat:spawn(p.x,p.y-1,0,0)
	end

	if recorder then
		recorderTimer = recorderTimer + dt
	end

	gui.update( dt )
end

-- handle key presses and button presses
function game.keypressed(key)
	game.inputpressed(key,'keyboard')
end

function game.joystickpressed(joystick, button)
	game.inputpressed(button,'joystick')
end

function game.inputpressed(key,device)
	gui:levelNameGoAway()

	if (device == 'keyboard' and key == 'p') then
		Campaign:proceed()
	end

	if (device == 'keyboard' and key == keys.BACK) or 
	   (device == 'joystick' and key == keys.PAD.BACK) then
		shaders:resetDeathEffect()
		if editor.active then
			Sound:stopAllLongSounds()
			editor.resume()
			return
		end
		menu:createWorldButtons()
		menu:selectCurrentLevel()

		if menu.currentlyPlayingUserlevels then
			menu:switchToSubmenu( "Userlevels" )
		else
			menu:createWorldButtons()
			menu:selectCurrentLevel()
			menu:switchToSubmenu( "Worldmap" )
		end
		menu:show()
	else
		levelEnd:registerKeypress()
	end

	if (device == 'keyboard' and key == keys.JUMP) or
	   (device == 'joystick' and key == keys.PAD.JUMP) then
		spriteEngine:DoAll('jump')
	end
	if (device == 'keyboard' and key == keys.DASH) or 
	   (device == 'joystick' and key == keys.PAD.DASH) then
		spriteEngine:DoAll('dash')
	end
	
	if p.dead then
		if (device == 'keyboard' and key == keys.CHOOSE) or 
		   (device == 'keyboard' and key == keys.JUMP) or
		   (device == 'joystick' and key == keys.PAD.CHOOSE) or
		   (device == 'joystick' and key == keys.PAD.JUMP) then
			myMap:start(p)
		elseif (device == 'keyboard' and key == keys.BACK) or 
		       (device == 'joystick' and key == keys.PAD.BACK) then
			if menu.currentlyPlayingUserlevels then
				menu:switchToSubmenu( "Userlevels" )
			else
				menu:createWorldButtons()
				menu:selectCurrentLevel( Campaign.current )
				menu:switchToSubmenu( "Worldmap" )
			end
			menu:show()
		end
	end  

	if (device == 'keyboard' and key == keys.ACTION) or 
	   (device == 'joystick' and key == keys.PAD.ACTION) then
		p:throwBungee()
	end
end

-- handle key release and button release
function game.keyreleased(key)
	game.inputreleased(key,'keyboard')
end

function game.joystickreleased(joystick, button)
	game.inputreleased(button,'joystick')
end

function game.inputreleased(key,device)
	if (device == 'keyboard' and key == keys.JUMP) or 
	   (device == 'joystick' and key == keys.PAD.JUMP) then
		spriteEngine:DoAll('unjump')
	end
	if (device == 'keyboard' and key == keys.ACTION) or 
	   (device == 'joystick' and key == keys.PAD.ACTION) then
		spriteEngine:DoAll('disconnect')
	end
end

function game.isDead()
	return p and p.dead or false
end

function game:drawDeathScreen()
	deathScreen:draw()
end
