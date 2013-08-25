intro = {
duration=.25}

function intro:draw ()
	self.height = love.graphics.getHeight()
	self.width = love.graphics.getWidth()
  local done = timer/self.duration;  
  love.graphics.setBackgroundColor(0,0,0)  
  game.draw()
  love.graphics.setColor(0,0,0,255*(1-done))
  love.graphics.rectangle('fill',0,0,self.width,self.height)
  love.graphics.setColor(255,255,255)
end

function intro:update(dt)
  Camera:setTarget()
	Camera:update(dt)
  timer = timer + dt
  if timer > self.duration then
    mode = 'game'
    timer = 0
    love.graphics.setBackgroundColor(0,0,0)
  end
end
