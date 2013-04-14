intro = {
duration=.25}

function intro:draw ()
  local done = timer/self.duration;
  love.graphics.setBackgroundColor(30*done,30*done,60*done)    
  love.graphics.setColor(255,255,255,255*done)  
  game.draw()
end

function intro:update(dt)
  Camera:setTarget()
	Camera:update(dt)
  timer = timer + dt
  if timer > self.duration then
    mode = 'game'
    timer = 0
    love.graphics.setBackgroundColor(30,30,60)        
  end
end
