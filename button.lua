Button = object:New({
	tag = 'button',
  --img = love.graphics.newImage('images/button.png'),
  marginx = 0.35,
  marginy = 0.3,
  animation = 'button',
  lifetime = 2,
  timer2 = 0,
  sonImg = love.graphics.newImage('images/waitbar.png'),
  sonY = -0.6,
})

function Button:setAcceleration(dt)
	
	
	if self.animation == 'button' then
		-- if self:touchPlayer() and p.oldy+p.semiheight < self.y-self.semiheight then
		if self:touchPlayer() then
	  self.animation = 'buttonPressed'
	  self.timer2 = self.lifetime
		spriteEngine:DoAll('buttonPress')
		else
			for k,v in pairs(spriteEngine.objects) do
				local dx,dy = v.x-self.x,v.y-self.y
				if v.tag == 'Imitator' and
				   math.abs(dx) < self.semiheight+v.semiheight and
				   math.abs(dy) < self.semiwidth +v.semiwidth then
					self.animation = 'buttonPressed'
					self.timer2 = self.lifetime
					spriteEngine:DoAll('buttonPress')
				end
			end
		end
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

