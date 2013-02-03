require 'camera'
require 'player'
require 'game'
require 'menu'
require 'map'

function love.load()
  mode = 'game'
  
  -- Initialize Camera
  camX = 0
  camY = 0
  camWidth = love.graphics.getWidth()
	camHeight = love.graphics.getHeight()
  
   -- Create Map
  myMap = Map:New('mytiles.png',32)
  
  -- Creating Player
  p = Player:New()
  p:setImage('block.png')
  p.x = 3
  p.y = 10
  
  gravity = 40

  
  --love.graphics.toggleFullscreen()
  love.graphics.setBackgroundColor(150,150,255)
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
