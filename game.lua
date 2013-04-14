require 'spriteengine'

game = {}

function game:draw()
  love.graphics.push()
  Camera:apply()

  spriteEngine:draw()  
  myMap:draw()

  love.graphics.pop()
	love.graphics.print(timer,10,10)
	
  if p:wincheck() then
    love.graphics.print('Gewonnen',10,30)
  else
    love.graphics.print('Noch nicht Gewonnen',10,30)
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
	self.isJump = love.keyboard.isDown('a') 
			or love.joystick.isDown(1,3)
	self.isGlide = love.keyboard.isDown('s')
			or love.joystick.isDown(1,8)
end

function game:update(dt)
  timer = timer + dt
  spriteEngine:update(dt)
  Camera:setTarget()
  Camera:update(dt)
  
  if p:wincheck() then
    Campaign:proceed()
  --else
    -- ausfuellen
  end
  
end

function game.keypressed(key)
  if key == "a" then
    p:jump()
  end
end

function game.keyreleased(key)
  if key == "a" then
    p:unjump()
  end
end

function game.joystickpressed(joystick, button)
  if button == 3 then
    p:jump()
  end
end

function game.joystickreleased(joystick, button)
  if button == 3 then
    p:unjump()
  end
end
