require 'camera'
require 'game'
require 'player'
require 'menu'
require 'map'
require 'intro'
require 'campaign'

function love.load()
  mode = 'game'
  timer = 0
    
  Campaign:reset()

  -- Creating Player
  p = Player:New()
  spriteEngine:insert(p)
  
  myMap:start(p)
  gravity = 40
  --love.graphics.toggleFullscreen()
end

function love.update(dt)
  if mode == 'game' then
    game:update(dt)
  elseif mode == 'menu' then
    menu:update(dt)
  elseif mode == 'intro' then
    intro:update(dt)
  end
end

function love.draw()
  --love.graphics.scale(0.75,0.75)
  if mode == 'game' then
    game:draw()
  elseif mode == 'menu' then
    menu:draw()
  elseif mode == 'intro' then
    intro:draw()
  end
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
  
  if key == 'p' then
    myMap:start(p)
  end
  
  if mode == 'game' then
    game.keypressed(key)
  elseif mode == 'menu' then
    menu.keypressed(key)
  end
end

function love.keyreleased(key)  
  if mode == 'game' then
    game.keyreleased(key)
  elseif mode == 'menu' then
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
