Button = object:New({
	tag = 'button',
  --img = love.graphics.newImage('images/button.png'),
  marginx = 0.3,
  marginy = 0.3,
  animation = 'button',
  lifetime = 2,
  timer2 = 0,
})

function Button:setAcceleration(dt)
	if self:touchPlayer() and self.animation == 'button' then
	  self.animation = 'buttonPressed'
	  self.timer2 = self.lifetime
		spriteEngine:DoAll('buttonPress')
	end

	self.timer2 = math.max(0,self.timer2 - dt)
	if self.timer2 == 0 then
		self.animation = 'button'
	end
end

