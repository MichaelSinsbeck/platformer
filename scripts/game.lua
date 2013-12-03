require 'scripts/spriteengine'

game = {
	deathtimer = 0,
	fullDeathtimer = 5, -- time until death effect is over
}

function game:draw()

	myMap:drawParallax()
	Camera:apply()

	myMap:drawBG()

	if USE_SHADOWS and shadows:getNumLights() > 0 then
		love.graphics.push()
		love.graphics.translate( -myMap.tileSize, -myMap.tileSize )
		shadows:draw()
		love.graphics.pop()
	end
	
	myMap:drawWalls()	
	spriteEngine:draw()
	
	myMap:drawFG()

		
	--love.graphics.setColor(255,255,255) 
	
	Camera:free()

	if recorderTimer > 1/30 then
		recorderTimer = recorderTimer-1/30
		table.insert(screenshots,love.graphics.newScreenshot())
	end
	
	if p.dead then
		controlKeys:draw("death")	-- display the keys for "retry" and "exit"
	end
end

function game:checkControls()
  local joyHat = love.joystick.getHat(1,1)
  self.isLeft = love.keyboard.isDown( keys.LEFT) 
		or keys.getGamepadIsDown( "LEFT" )
	self.isRight = love.keyboard.isDown( keys.RIGHT )
		or keys.getGamepadIsDown( "RIGHT" )
	self.isDown = love.keyboard.isDown( keys.DOWN )
		or keys.getGamepadIsDown( "DOWN" )
	self.isUp = love.keyboard.isDown( keys.UP )
		or keys.getGamepadIsDown( "UP" )
	self.isJump = love.keyboard.isDown( keys.JUMP ) 
		or keys.getGamepadIsDown( "JUMP" )
	self.isAction = love.keyboard.isDown( keys.ACTION )
		or keys.getGamepadIsDown( "ACTION" )
	--print(keys.PAD_JUMP, tonumber(keys.PAD_JUMP), love.joystick.isDown(1, tonumber(keys.PAD_JUMP)))
	--print(self.isJump)
end

function game:update(dt)
	--dt = 1/60
  timer = timer + dt
  spriteEngine:update(dt)
    
  Camera:setTarget()
  Camera:update(dt)
  
  if game.won then
	game.won = nil
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
	levelEnd:addDeath("fall")
	Meat:spawn(p.x,p.y-1,0,0)
  end
  
  if recorder then
		recorderTimer = recorderTimer + dt
  end
end

function game.keypressed(key)
	if key == 'escape' then
		menu.startTransition(menu.initWorldMap, true)()
	end
	if key == "r" then
		p.status = 'stand'
	end
  if key == keys.JUMP then
		spriteEngine:DoAll('jump')
		if p.dead then
			menu.startTransition( function() myMap:start(p) end )()
		end
  end
  if key == keys.ACTION and p.bandana == "red" then
		Bungee:throw()
  end
  if key == keys.NEXTMAP then
		Campaign:proceed()
  end
  if key == "u" then -- print all global variables
		for k,v in pairs(_G) do
			print(k)
		end
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
	if button == 7 or button == 8 then
		menu.startTransition(menu.initWorldMap)()
	end
	print(keys.PAD.JUMP, button)
  if tonumber(button) == tonumber(keys.PAD.JUMP) then
  	print("\t\tfound")
    spriteEngine:DoAll('jump')
		if p.dead then
			menu.startTransition( function() myMap:start(p) end )()
		end  
  end
  
	if button == tonumber(keys.PAD.ACTION) and p.bandana == "red" then
		Bungee:throw()
  end
end

function game.joystickreleased(joystick, button)
  if button ==  tonumber(keys.PAD.JUMP) then
    spriteEngine:DoAll('unjump')
  end
	if button == tonumber(keys.PAD.ACTION) then
		spriteEngine:DoAll('disconnect')
  end  
end
