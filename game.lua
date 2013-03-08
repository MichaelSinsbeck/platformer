game = {}

function game.draw()
  --love.graphics.scale(2)
  --love.graphics.translate(math.floor(-Camera.x*myMap.tileSize),math.floor(-Camera.y*myMap.tileSize))
  love.graphics.push()
  Camera:apply()
  
  --myMap:updateSpritebatch()  
  myMap:draw()
  p:draw()
  love.graphics.pop()
  --love.graphics.print(math.floor(p.x) .. ', ' .. math.floor(p.y),10,10)
	love.graphics.print(p.status,10,10)

--	love.graphics.print(p.status,10,40)
  
end

function game.checkControls()
  local joyHat = love.joystick.getHat(1,1)
  local isLeft = love.keyboard.isDown('left') 
		or joyHat == 'l' 
		or joyHat == 'ld' 
		or joyHat == 'lu'
	local isRight = love.keyboard.isDown('right')
		or joyHat == 'r'
		or joyHat == 'rd' 
		or joyHat == 'ru'
	local isJump = love.keyboard.isDown('a') 
			or love.joystick.isDown(1,3)
	local isGlide = love.keyboard.isDown('s')
			or love.joystick.isDown(1,8)
			
	return isLeft,isRight,isJump,isGlide
	
end

function game.update(dt)
  p:update(dt)
  Camera:setTarget()
  Camera:update(dt)

  local camSpeed = 500
  --[[if love.keyboard.isDown('up') then
    camY = camY - camSpeed*dt
  end
  if love.keyboard.isDown('down') then
    camY = camY + camSpeed*dt
  end
  if love.keyboard.isDown('left') then
    camX = camX - camSpeed*dt
  end
  if love.keyboard.isDown('right') then
    camX = camX + camSpeed*dt
  end]]
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
