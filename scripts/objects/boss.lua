local Boss = object:New({
	tag = 'Boss',
	layout = 'center',
	category = 'Enemies',
	marginx = 0.4,
	marginy = 0.4,
	isInEditor = true,
	animTimer = 0,
	shotTimer = 0,
	shotInterval = 3,
	hitAnimState = 0,
	hitTimer = 0,
	destructionTimer = 0,
	explosionCount = 0,
	explosionCount2 = 0,
	appearTimer = 1,
	phase = 0,
	state = "appear",
	vis = {
		Visualizer:New('enemyprewalker',{relX = -11.75,relY = -3.75,sx = 0, sy = 0}),
	},
})


function Boss:draw()
	local applyShader = (self.state == "hit") or (self.state == "appear")

	if applyShader then
		love.graphics.setShader( shaders.lightup )
	end

	-- body and legs
	if self.state == "hit" then
		local percentage = math.max(1+(self.destructionTimer-1.5)*3,0)
		shaders.lightup:send( "percentage", percentage)
	elseif self.state == "appear" then
		shaders.lightup:send( "percentage", self.appearTimer+0.1)
	end
	
	love.graphics.draw(AnimationDB.image.bossLeg2,(self.x-1)*8*Camera.scale,(self.y-5.5)*8*Camera.scale) -- back leg
	love.graphics.draw(self.mesh,(self.x-12.7)*8*Camera.scale,(self.y-11)*8*Camera.scale) -- body
	love.graphics.draw(AnimationDB.image.bossLeg1,(self.x+4)*8*Camera.scale,(self.y-5.5)*8*Camera.scale) -- front leg
	
	-- head
	if self.state == "hit" then
		local percentage = math.max(1+(self.destructionTimer-2)*3,0)
		shaders.lightup:send( "percentage", percentage)
	elseif self.state == "appear" then
		shaders.lightup:send( "percentage", self.appearTimer)
	end
	love.graphics.draw(AnimationDB.image.bossHead,(self.x-9.75)*8*Camera.scale+self.headX,(self.y-4.75) *8*Camera.scale+self.headY,self.headR,1,1,70*Camera.scale,50*Camera.scale)
	
	if applyShader then
		love.graphics.setShader()
	end
	
	object.draw(self)
end

function Boss:applyOptions()
	local W,H = AnimationDB.image.bossBody:getDimensions()
	local steps = {0,0.35,0.75,1}
	local vertices = {}
	for i = 1,#steps do
		local newV
		local thisStep = steps[i]
		newV = {thisStep*W,H,thisStep,1,255,255,255}
		table.insert(vertices,newV)
		newV = {thisStep*W,0,thisStep,0,255,255,255}
		table.insert(vertices,newV)
	end
	self.mesh = love.graphics.newMesh( vertices ,'strip')
	self.mesh:setTexture(AnimationDB.image.bossBody)
	
	self.headX = 0
	self.headY = 0
	self.headR = 0
end

function Boss:setAcceleration(dt)
	if love.keyboard.isDown("i") and self.state == "waiting" then
		self:hit()
	end
end

function Boss:hit()
	self:playSound('bossHit')
	self.hitTimer = 1
	self.destructionTimer = 0
	self.state = "hit"
end

function Boss:shootBall()
	local nBalls = 5
	local angle = love.math.random() * 2 * 3.1415
	for i=1,nBalls do
		local thisAngle = angle + i * 2 * 3.1415 /nBalls
		local thisvx = 8 * math.cos(thisAngle)
		local thisvy = 8 * math.sin(thisAngle)
		local newBall = spriteFactory('Dragonball',{x = self.x+self.ballX, y = self.y+self.ballY,vx = thisvx, vy = thisvy, tx = p.x, ty = p.y})
		
		spriteEngine:insert(newBall,2)
	end
	local thisPoff = spriteFactory('Poff',{x = self.x+self.ballX, y = self.y+self.ballY,vis = {Visualizer:New('largepoff',{angle=love.math.random()*10})}})
	spriteEngine:insert(thisPoff,2)
end

function Boss:postStep(dt)
	-- restrict camera movement (to not reveal tail)
	Camera:registerUpperXBound(self.x+9.5)
	
	-- update all timers
	if self.state == 'waiting' then
		self.animTimer = self.animTimer + dt
		self.shotTimer = self.shotTimer + dt
		if self.shotTimer > self.shotInterval then
			self.shotTimer = self.shotTimer - self.shotInterval
			self:shootBall()
		end
	end
	self.hitTimer = math.max(self.hitTimer - 2 * dt,0)
	if self.state == "hit" then
		self.destructionTimer = self.destructionTimer + dt
	end
	if self.state == 'appear' then
		self.appearTimer = math.max(self.appearTimer - 2*dt,0)
		if self.appearTimer == 0 then
			self.state = 'waiting'
		end
	end
	
		-- check for collision with missile
	for k,v in pairs(spriteEngine.objects) do
		if (v.tag == 'Missile') then
			local dx = v.x - self.x + 11
			local dy = v.y - self.y + 5
			if dx^2+dy^2 < 5^2 then
				self:hit()
				v:detonate()
			end
			break
		end
	end
	
	-- update animation
	self.animState = math.sin(1.5*self.animTimer) -- breath
	self.hitAnimState = self.hitTimer * (1-self.hitTimer) * 2 -- hit
	
	-- deform mesh according to animState
	local x,y,u,v,r,g,b,a, thisV,idx
	local W,H = AnimationDB.image.bossBody:getDimensions()
	local shift = Camera.scale * self.animState - self.hitAnimState * Camera.scale
	idx = 1
	x,y,u,v,r,g,b,a = self.mesh:getVertex(idx)
	thisV = {-2*shift,H+shift,u,v,r,g,b,a}
	self.mesh:setVertex(idx, thisV)

	idx = 2
	x,y,u,v,r,g,b,a = self.mesh:getVertex(idx)
	thisV = {-2*shift,shift,u,v,r,g,b,a}
	self.mesh:setVertex(idx, thisV)

	idx = 3
	x,y,u,v,r,g,b,a = self.mesh:getVertex(idx)
	thisV = {x,H+2*shift,u,v,r,g,b,a}
	self.mesh:setVertex(idx, thisV)

	idx = 4
	x,y,u,v,r,g,b,a = self.mesh:getVertex(idx)
	thisV = {x,2*shift,u,v,r,g,b,a}
	self.mesh:setVertex(idx, thisV)

	idx = 8
	x,y,u,v,r,g,b,a = self.mesh:getVertex(idx)
	thisV = {x,4*shift,u,v,r,g,b,a}
	self.mesh:setVertex(idx, thisV)

	-- set position and rotation of dragons head
	self.headX = -2 * shift
	self.headY = shift
	self.headR = self.animState * 0.02 + 0.1 * self.hitAnimState
	
	if self.state == "waiting" then -- calculate position of ball (in mouth)
		local neckX = -9.75 + self.headX / (8*Camera.scale)
		local neckY = -4.75 + self.headY / (8*Camera.scale)
		local thisSin = math.sin(self.headR)
		local thisCos = math.cos(self.headR)
		self.ballX = neckX + thisCos * (-3.4) + thisSin * (-4.1)
		self.ballY = neckY + thisSin * (-3.4) - thisCos * (-4.1)
		
		local s = (self.shotTimer / self.shotInterval)^2
		self.vis[1].sx = s
		self.vis[1].sy = s
		self.vis[1].r = self.headR
		self.vis[1].relX = self.ballX + 0.2*(love.math.random()-0.5)*s
		self.vis[1].relY = self.ballY + 0.2*(love.math.random()-0.5)*s
	else
		self.vis[1].sx = 0
		self.vis[1].sy = 0
	end
	
	-- generate explosion animation, if destructing
	local explosionStart = 0.25
	local explosionsPerSecond = 50
	-- exploding body
	if self.destructionTimer > explosionStart and self.destructionTimer < 1.5 then
		local totalExplosionNumber = math.floor((self.destructionTimer - explosionStart) * explosionsPerSecond)
		local thisExplosionNumber = totalExplosionNumber - self.explosionCount
		if thisExplosionNumber > 0 then
			for i =1,thisExplosionNumber do
				local x,y = self.x - 9 + love.math.random() * 18, self.y - 10 + love.math.random() * 9
				local angle = math.random()*math.pi*2
				local thisPoff = spriteFactory('Poff',{x = x, y = y,vis = {Visualizer:New('largepoff',{angle=angle})}})
				spriteEngine:insert(thisPoff,2)
			end
			self.explosionCount = totalExplosionNumber
		end
	end
	-- exploding head
	local explosionsPerSecond = 22
	if self.destructionTimer >= 1 then
		local totalExplosionNumber = math.floor((self.destructionTimer - 1) * explosionsPerSecond)
		local thisExplosionNumber = totalExplosionNumber - self.explosionCount2
		if thisExplosionNumber > 0 then
			for i =1,thisExplosionNumber do
				local x,y = self.x - 16 + love.math.random() * 8, self.y - 8 + love.math.random() * 9
				local angle = math.random()*math.pi*2
				local thisPoff
				if math.random() < 0.7 then
					local thisPoff = spriteFactory('Poff',{x = x, y = y,vis = {Visualizer:New('largepoff',{angle=angle})}})
					spriteEngine:insert(thisPoff,2)
				else
					local thisPoff = spriteFactory('Poff',{x = x, y = y,vis = {Visualizer:New('poff',{angle=angle})}})
					spriteEngine:insert(thisPoff,2)
				end
			end
			self.explosionCount2 = totalExplosionNumber
		end
	end
	if self.destructionTimer > 2 then
		local thisMini = spriteFactory('Minidragon',{x = self.x-11.75, y = self.y-3.75, state = "waiting", phase = self.phase+1, speed = 0})
		spriteEngine:insert(thisMini,2)
		self:kill()
	end
end

return Boss
