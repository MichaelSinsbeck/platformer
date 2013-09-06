Button = object:New({
	tag = 'button',
  marginx = 0.5,
  marginy = 0.3,
  lifetime = 2,
  timer2 = 0,
  vis = {
		Visualizer:New('button'),
		Visualizer:New('waitbar',{relY = -0.6})
  },
})

function Button:postStep(dt)
	
	-- find out if button is touched by a player or an imitator
	local touched = false
	if self:touchPlayer() then 
		touched = true
	else
		for k,v in pairs(spriteEngine.objects) do
			local dx,dy = v.x-self.x,v.y-self.y
			if v.tag == 'Imitator' and
				 math.abs(dx) < self.semiheight+v.semiheight and
				 math.abs(dy) < self.semiwidth +v.semiwidth then
				touched = true
			end
		end
	end
	
	if self.timer2 > 0 then
		self.timer2 = self.timer2-dt
		if touched then
			self.timer2 = self.lifetime
		end
	end
	
	if self.timer2 < 0 then
		self.timer2 = 0 
		spriteEngine:DoAll('buttonPress')		
	end
	
	if self.timer2 == 0 and touched then
		self.timer2 = self.lifetime
		spriteEngine:DoAll('buttonPress')
	end

	if touched then
		self:setAnim('buttonPressed')
	elseif self.timer2 > 0 then
		self:setAnim('buttonReleased')
	else
		self:setAnim('button')
	end

	self.vis[2].sx = self.timer2/self.lifetime
end

