require 'camera'
require 'game'
require 'player'
require 'menu'
require 'map'

function love.load()
  mode = 'game'
   
  -- Load Map
  --myMap = Map:LoadFromFile('testmap.dat')  
  myMap = Map:LoadFromFile('ruinlevel2.dat')  
  
  
  --myMap = Map:New('mytiles.png',32)
	--myMap:updateSpritebatch() -- done in load-function anyway  
  --myMap:save('testmap.dat')

  
  -- Creating Player
  --p = Player:New({x=3,y=10})
  p = Player:New({x=50,y=18})
  Camera:jumpTo(p.x,p.y)
  spriteEngine:insert(p)

  gravity = 40
	  
  --love.graphics.toggleFullscreen()
  --love.graphics.setBackgroundColor(150,150,255)  
  love.graphics.setBackgroundColor(30,30,60)  
end

function love.update(dt)
  if mode == 'game' then
    game.update(dt)
  else
    menu.update(dt)
  end
end

function love.draw()
  if mode == 'game' then
    game.draw()
  else
    menu.draw()
  end
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
  
  if mode == 'game' then
    game.keypressed(key)
  else
    menu.keypressed(key)
  end
end

function love.keyreleased(key)  
  if mode == 'game' then
    game.keyreleased(key)
  else
    menu.keyreleased(key)
  end
end

function love.joystickpressed(joystick, button)
if mode == 'game' then
    game.joystickpressed(joystick, button)
  else
    menu.joystickpressed(joystick, button)
  end
end

function love.joystickreleased(joystick, button)
if mode == 'game' then
    game.joystickreleased(joystick, button)
  else
    menu.joystickreleased(joystick, button)
  end
end
