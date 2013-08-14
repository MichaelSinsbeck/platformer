require 'spriteengine'

game = {deathtimer = 0}

function game:draw()
  love.graphics.push()
  Camera:apply()

	myMap:draw()
  spriteEngine:draw()  
  

  love.graphics.pop()
	--love.graphics.print(timer,10,10)
	if recorderTimer > 1/30 then
		recorderTimer = recorderTimer-1/30
		table.insert(screenshots,love.graphics.newScreenshot())
	end
end

function game:checkControls()
  local joyHat = love.joystick.getHat(1,1)
  self.isLeft = love.keyboard.isDown('left') 
		or joyHat == 'l' 
		or joyHat == 'ld' 
		or joyHat == 'lu'
	self.isRight = love.keyboard.isDown('right')
		or joyHat == 'r'
		or joyHat == 'rd' 
		or joyHat == 'ru'
	self.isDown = love.keyboard.isDown('down')
	  or joyHat == 'd'
	  or joyHat == 'ld'
	  or joyHat == 'rd'
	self.isUp = love.keyboard.isDown('up')
	  or joyHat == 'u'
	  or joyHat == 'lu'
	  or joyHat == 'ru'
	self.isJump = love.keyboard.isDown('a') 
			or love.joystick.isDown(1,3)
	self.isAction = love.keyboard.isDown('s')
			or love.joystick.isDown(1,8)
end

function game:update(dt)
	--dt = 1/60
  timer = timer + dt
  spriteEngine:update(dt)
  
	if love.keyboard.isDown('b') then
	  Camera.scale = Camera.scale * 1.01
	end
	if love.keyboard.isDown('g') then
		Camera.scale = Camera.scale / 1.01
	end
  
  Camera:setTarget()
  Camera:update(dt)
  
  if p:wincheck() then
    Campaign:proceed()
  end
  
  if p.dead then
		self.deathtimer = self.deathtimer + dt
  end
  
  if self.deathtimer > 5 then
    myMap:start(p)
  end
  
  if p.y > myMap.height+2 and not p.dead then
    p.dead = true
    Meat:spawn(p.x,p.y-1,0,0)
  end
  
  if recorder then
		recorderTimer = recorderTimer + dt
  end
end

function game.keypressed(key)
	if key == "r" then
		p.status = 'stand'
	end
  if key == "a" then
		spriteEngine:DoAll('jump')
		if p.dead then
			myMap:start(p)
		end
  end
  if key == "q" then
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
  if key == "a" then
		spriteEngine:DoAll('unjump')
  end
end

function game.joystickpressed(joystick, button)
  if button == 3 then
    spriteEngine:DoAll('jump')
		if p.dead then
			myMap:start(p)
		end  

  end
end

function game.joystickreleased(joystick, button)
  if button == 3 then
    spriteEngine:DoAll('unjump')
  end
end
