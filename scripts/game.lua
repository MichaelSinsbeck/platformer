require 'scripts/spriteengine'

game = {deathtimer = 0}

function game:draw()
	Camera:apply()

	myMap:drawBG()
	spriteEngine:draw()
	myMap:drawFG()
	
	if USE_SHADOWS then
		love.graphics.setBlendMode('multiplicative')
		love.graphics.draw(shadows.canvas, -shadows.tileSize, -shadows.tileSize)
	end
	love.graphics.setBlendMode('alpha')
	myMap:drawWalls()
	
	love.graphics.setColor(255,255,255) 

	Camera:free()

	if recorderTimer > 1/30 then
		recorderTimer = recorderTimer-1/30
		table.insert(screenshots,love.graphics.newScreenshot())
	end
end

function game:checkControls()
  local joyHat = love.joystick.getHat(1,1)
  self.isLeft = love.keyboard.isDown( keys.LEFT) 
		or joyHat == 'l' 
		or joyHat == 'ld' 
		or joyHat == 'lu'
	self.isRight = love.keyboard.isDown( keys.RIGHT )
		or joyHat == 'r'
		or joyHat == 'rd' 
		or joyHat == 'ru'
	self.isDown = love.keyboard.isDown( keys.DOWN )
	  or joyHat == 'd'
	  or joyHat == 'ld'
	  or joyHat == 'rd'
	self.isUp = love.keyboard.isDown( keys.UP )
	  or joyHat == 'u'
	  or joyHat == 'lu'
	  or joyHat == 'ru'
	self.isJump = love.keyboard.isDown( keys.JUMP ) 
			or love.joystick.isDown(1,3)
	self.isAction = love.keyboard.isDown( keys.ACTION )
			or love.joystick.isDown(1,8)
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
  end
  
  if self.deathtimer > 5 or (DEBUG and self.deathtimer > .5) then
    myMap:start(p)
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
	if key == 'b' then
		local list = {}
		spriteEngine:DoAll('collectLights',list)
		for k,v in ipairs(list) do
			print('k = ' .. k .. ', coordinates: ('.. v.x .. ', ' .. v.y.. ')')
		end
	end

	if key == 'escape' then
		menu.startTransition(menu.initWorldMap)()
	end
	if key == "r" then
		p.status = 'stand'
	end
  if key == keys.JUMP then
		spriteEngine:DoAll('jump')
		if p.dead then
			myMap:start(p)
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
  if button == 3 then
    spriteEngine:DoAll('jump')
		if p.dead then
			myMap:start(p)
		end  
  end
	if button == 8 and p.bandana == "red" then
		Bungee:throw()
  end
end

function game.joystickreleased(joystick, button)
  if button == 3 then
    spriteEngine:DoAll('unjump')
  end
	if button == 8 then
		spriteEngine:DoAll('disconnect')
  end  
end
