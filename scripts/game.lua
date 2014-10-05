require 'scripts/spriteengine'
local gui = require('scripts/gui')

game = {
	deathtimer = 0,
	fullDeathtimer = 5, -- time until death effect is over
}

function game:draw()

	myMap:drawParallax()
	Camera:apply()

	myMap:drawBackground()

	if settings:getShadowsEnabled() and shadows:getNumLights() > 0 then
		love.graphics.push()
		love.graphics.translate( -myMap.tileSize, -myMap.tileSize )
		shadows:draw()
		love.graphics.pop()
	end
	
	myMap:drawGround()
	spriteEngine:draw()
	
	myMap:drawForeground()

	--love.graphics.setColor(255,255,255) 
	
	Camera:free()

	gui.draw()
	if recorderTimer > 1/30 then
		recorderTimer = recorderTimer-1/30
		table.insert(screenshots,love.graphics.newScreenshot())
	end
	love.graphics.print( love.timer.getFPS(), 20, love.graphics.getHeight() - 40 )
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
  
  if game.won then
		Sound:stopAllLongSounds()
		game.won = nil
		levelEnd:registerEnd()
		levelEnd:display()
  end
  
	if p.dead then
		self.deathtimer = self.deathtimer + dt
		-- finish fade-to-black in less time than full death sequence:
		shaders:setDeathEffect(	self.deathtimer/(self.fullDeathtimer*0.3) )
	end
	
	if self.deathtimer >= self.fullDeathtimer or (DEBUG and self.deathtimer > .5) then
		if not self.restartingLevel then
			menu.startTransition( function() myMap:start(p) end )()		-- fades to black and restarts map.
			self.restartingLevel = true
		end
	end
  
  if p.y > myMap.height+2 and not p.dead then
	p.dead = true
	levelEnd:addDeath("death_fall")
	objectClasses.Meat:spawn(p.x,p.y-1,0,0)
  end
  
  if recorder then
		recorderTimer = recorderTimer + dt
  end
end

function game.keypressed(key)


	if key == keys.PAUSE then
		if editor.active then
			Sound:stopAllLongSounds()
			editor.resume()
			return
		end
		menu.initPauseMenu()
		Sound:play('menuPause')
	end
	if key == "r" then
		p.status = 'stand'
	end
	if key == keys.JUMP then
		spriteEngine:DoAll('jump')
	end
	if key == keys.DASH then
		spriteEngine:DoAll('dash')
	end
	
	if p.dead then
		if key == keys.CHOOSE then
			menu.startTransition( function() myMap:start(p) end )()
		elseif key == keys.BACK then
			if menu.currentlyPlayingUserlevels then
				menu.startTransition( menu.initUserlevels, true )()
			else
				menu.startTransition( menu.initWorldMap, true )()
			end
		end
	end  


	if key == keys.ACTION and p.canHook then
		p:throwBungee()
	end
	if key == keys.NEXTMAP then
		Campaign:proceed()
	end

	if key == "m" then	-- recorder	
		recorder = not recorder
		print('Recorder:')
		print(recorder)
	end
	if key == "n" then
		print('Saving screenshots')
		for k,v in pairs(screenshots) do
			if k < 10 then k = '0'..k end
			local filename = 'screenshot'..k..'.png'
			v:encode(filename)
		end
	end
end

function game.keyreleased(key)
	if key == keys.JUMP then
		spriteEngine:DoAll('unjump')
	end
	if key == keys.ACTION then
		spriteEngine:DoAll('disconnect')
	end
end

function game.joystickpressed(joystick, button)
	--[[if button == 7 or button == 8 then
		menu.startTransition(menu.initWorldMap)()
	end]]--
	if button == keys.PAD.PAUSE then
		if editor.active then
			Sound:stopAllLongSounds()
			editor.resume()
			return
		end
		menu.initPauseMenu()
		Sound:play('menuPause')
	end
	if button == keys.PAD.JUMP then
		spriteEngine:DoAll('jump')
	end
	if p.dead then
		if button == keys.PAD.CHOOSE then
			menu.startTransition( function() myMap:start(p) end )()
		elseif button == keys.PAD.BACK then
			--menu.startTransition( menu.initWorldMap, true )()
			if menu.currentlyPlayingUserlevels then
				menu.startTransition( menu.initUserlevels, true )()
			else
				menu.startTransition( menu.initWorldMap, true )()
			end
		end
	end  

	if button == keys.PAD.ACTION and p.bandana == "red" then
		Bungee:throw()
	end
end

function game.joystickreleased(joystick, button)
	if button == keys.PAD.JUMP then
		spriteEngine:DoAll('unjump')
	end
	if button == keys.PAD.ACTION then
		spriteEngine:DoAll('disconnect')
	end  
end

function game.isDead()
	return p and p.dead or false
end
