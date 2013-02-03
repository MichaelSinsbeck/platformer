game = {}

function game.draw()
  --love.graphics.scale(2)
  --love.graphics.translate(math.floor(-Camera.x*myMap.tileSize),math.floor(-Camera.y*myMap.tileSize))
  love.graphics.push()
  Camera:apply()
  
  myMap:updateSpritebatch()  
  myMap:draw()
  p:draw()
  love.graphics.pop()
  --love.graphics.print(math.floor(p.x) .. ', ' .. math.floor(p.y),10,10)
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
