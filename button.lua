Button = object:New({
	tag = 'button',
  --img = love.graphics.newImage('images/button.png'),
  marginx = 0.3,
  marginy = 0.3,
  animation = 'button',
  lifetime = 2,
  timer2 = 0,
  sonImg = love.graphics.newImage('images/waitbar.png'),
  sonY = -0.6,
})

function Button:setAcceleration(dt)
	
	if self:touchPlayer() and self.animation == 'button' then
	  self.animation = 'buttonPressed'
	  self.timer2 = self.lifetime
		spriteEngine:DoAll('buttonPress')
	end

	if self.timer2 > 0 then
		self.timer2 = self.timer2-dt
	end
	
	if self.timer2 < 0 then
		self.timer2 = 0 
		self.animation = 'button'
		spriteEngine:DoAll('buttonPress')
	end
	self.sonSx = self.timer2/self.lifetime
end

