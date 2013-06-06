menu = {}

function menu:draw()
  love.graphics.print('Menu',10,10)
  love.graphics.print('Congratulations. You finished the demo.',10,30)
  love.graphics.print('Restart the game with "o"',10,50)
end

function menu:update(dt)
end

function menu.keypressed(key)
end

function menu.keyreleased(key)
end

function menu.joystickpressed(joystick, button)
end

function menu.joystickreleased(joystick, button)
end
