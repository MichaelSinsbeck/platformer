require 'utility'
require 'camera'
require 'game'
require 'spritefactory'
require 'menu'
require 'map'
require 'intro'
require 'campaign'


function love.load()
	
	-- hide mouse
	love.mouse.setVisible(false)

	-- set screen resolution
	Camera:init()
	
	-- load all images
	AnimationDB:loadAll()	

	recorder = false
	screenshots = {}
	recorderTimer = 0

  mode = 'game'
  timer = 0
    
  Campaign:reset()
  
  initAll()
  -- Creating Player
  p = spriteFactory('player')
  --p = Player:New()
  --spriteEngine:insert(p)
  
  gravity = 22  
  myMap:start(p)

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
  if key == 't' then
    love.graphics.newScreenshot():encode('screenshot.png')
    print('Saved screenshot')
  end
  if key == 'escape' then
    love.event.quit()
  end
  
  if key == 'p' then
    myMap:start(p)
  end
  
  if key == 'o' then
    Campaign:reset()
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
	if button == 9 then Campaign:reset() myMap:start(p) end
end

function love.joystickreleased(joystick, button)
if mode == 'game' then
    game.joystickreleased(joystick, button)
  else
    menu.joystickreleased(joystick, button)
  end
end
