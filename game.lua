require 'spriteengine'

game = {}

function game:draw()
  love.graphics.push()
  Camera:apply()

	myMap:draw()
  spriteEngine:draw()  
  

  love.graphics.pop()
	--love.graphics.print(timer,10,10)
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
	self.isAction = love.keyboard.isDown('s')
			or love.joystick.isDown(1,8)
end

function game:update(dt)
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
  
  if p.y > myMap.height+2 or p.dead then
    p:setAnim('whiteStand')
		p:resetAnimation()
		p:update(0)
    myMap:start(p)
    p.dead = nil
  end
end

function game.keypressed(key)
  if key == "a" then
    p:jump()
  end
  if key == "q" then
    Campaign:proceed()
  end
  if key == "u" then
		for k,v in pairs(_G) do
			print(k)
		end
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
