local Boss = object:New({
	tag = 'Boss',
	layout = 'center',
	marginx = 0.4,
	marginy = 0.4,
	isInEditor = true,
	animTimer = 0,
	hitAnim = 0,
	hitTimer = 0,
	vis = {
		},
})


function Boss:draw()
	-- leg in the back
	love.graphics.draw(AnimationDB.image.bossLeg2,(self.x-1)   *8*Camera.scale,(self.y-5.5)*8*Camera.scale)
	
	-- body
	love.graphics.draw(self.mesh,(self.x-12.7)*8*Camera.scale,(self.y-11) *8*Camera.scale)
	
	-- leg in the front
	love.graphics.draw(AnimationDB.image.bossLeg1,(self.x+4)   *8*Camera.scale,(self.y-5.5)*8*Camera.scale)
	
	-- head
	love.graphics.draw(AnimationDB.image.bossHead,(self.x-9.75)*8*Camera.scale+self.headX,(self.y-4.75) *8*Camera.scale+self.headY,self.headR + 0.1 * self.hitAnim,1,1,70*Camera.scale,50*Camera.scale)
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
end

function Boss:postStep(dt)	
	self.animTimer = self.animTimer + dt
	self.animState = math.sin(1.5*self.animTimer)
	
	
		-- check for collision with missile
	for k,v in pairs(spriteEngine.objects) do
		if (v.tag == 'Missile') then
			local dx = v.x - self.x + 11
			local dy = v.y - self.y + 5
			if dx^2+dy^2 < 5^2 then
				self:playSound('bossHit')
				self.hitTimer = 1
				v:detonate()
			end
			break
		end
	end
	
	self.hitAnim = self.hitTimer * (1-self.hitTimer) * 4
	
	-- deform mesh according to animState
	local x,y,u,v,r,g,b,a, thisV,idx
	local W,H = AnimationDB.image.bossBody:getDimensions()
	local shift = Camera.scale * self.animState - self.hitAnim * Camera.scale
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

	self.headX = -2 * shift
	self.headY = shift
	self.headR = self.animState * 0.02
	
	

	self.hitTimer = math.max(self.hitTimer - 2 * dt,0)
end

return Boss
