intro = {
duration=.25}

function intro:draw ()
  local done = timer/self.duration;
  love.graphics.setBackgroundColor(20,120,170)        
  game.draw()
  love.graphics.setColor(0,0,0,255*(1-done))
  love.graphics.rectangle('fill',0,0,800,600)
  love.graphics.setColor(255,255,255)
end

function intro:update(dt)
  Camera:setTarget()
	Camera:update(dt)
  timer = timer + dt
  if timer > self.duration then
    mode = 'game'
    timer = 0
    love.graphics.setBackgroundColor(20,120,170)        
  end
end
