local Button = object:New({
	tag = 'Button',
	category = 'Interactive',
  marginx = 0.5,
  marginy = 0.3,
  isInEditor = true,
  timer2 = 0,
  state = 'waiting',
  vis = {
		Visualizer:New('button'),
		Visualizer:New('redButton'),
		--Visualizer:New('waitbar',{relY = -0.6})
  },
	properties = {
		color = utility.newCycleProperty({'red','blue','green','yellow'}),
		lifetime = utility.newProperty({0,1,2,3,4,5,6,7,8,9,10}),
	},    
})


function Button:draw()
	-- draw visualizers
	object.draw(self)
	
	-- draw wait-bar/clock
	if self.timer2 > 0 then
		local tileSize = Camera.scale * 8
		love.graphics.setColor(0,0,0)
		local angle = -(self.timer2/self.lifetime)*2*math.pi-0.5*math.pi
		local nSegments = (self.timer2/self.lifetime)*20+1
		love.graphics.arc('fill',self.x*tileSize,(self.y-1)*tileSize,0.2*tileSize,-.5*math.pi,angle)
		love.graphics.setLineJoin( 'none')
		love.graphics.arc('line',self.x*tileSize,(self.y-1)*tileSize,0.2*tileSize,-.5*math.pi,angle,nSegments)
		love.graphics.setColor(255,255,255)
	end
end

function Button:applyOptions()
	self:setAnim(self.color .. 'Button',false,2)
end

function Button:postStep(dt)
	
	-- find out if button is touched by a player, walker or imitator
	local touched = false
	if self:touchPlayer() then 
		touched = true
	else
		for k,v in pairs(spriteEngine.objects) do
			local dx,dy = v.x-self.x,v.y-self.y
			if (v.tag == 'Imitator' or v.tag == 'Walker' or v.tag == 'Rock' or v.tag == 'Follower') and
				 math.abs(dx) < self.semiheight+v.semiheight and
				 math.abs(dy) < self.semiwidth +v.semiwidth then
				touched = true
				break
			end
		end
	end
	
	if self.state == 'waiting' and touched then

		self.timer2 = self.lifetime
		self.state = 'pressed'
		spriteEngine:DoAll('buttonPress',self.color)
		self:playSound('buttonPress')
		
	elseif self.state == 'pressed' and not touched then

		self.state = 'released'
		self:playSound('buttonRelease')
		
	elseif self.state == 'released' then

		if touched then
			self.timer2 = self.lifetime
			self.state = 'pressed'
			self:playSound('buttonPress')
		else
			self.timer2 = self.timer2-dt
			if self.timer2 < 0 then
				self.state = 'waiting'
				spriteEngine:DoAll('buttonPress',self.color)
				self.timer2 = 0
				self:playSound('buttonUnPress')
			end
		end

	end
	
	if self.state == 'pressed' then
		self:setAnim('buttonPressed')
	elseif self.state == 'released' then
		self:setAnim('buttonReleased')
	else
		self:setAnim('button')
	end
	
end

return Button
