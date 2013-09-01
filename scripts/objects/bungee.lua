Bungee = object:New({	
	tag = 'Bungee',
	animation = 'bungee',
	marginx = 0.1,
  marginy = 0.1,
  speed = 50,
  maxLength = 10,
  minLength = 0.5,
  status = 'fly',
  nNodes = 20,
  friction = 5,
})

function Bungee:setAcceleration(dt)
end

function Bungee:draw()
	object.draw(self)
	love.graphics.setLineWidth(Camera.scale*0.4)
	local r, g, b, a = love.graphics.getColor()	
	love.graphics.setColor(212,0,0)
	if self.status == 'fly' then
	love.graphics.line(
		math.floor(self.x*myMap.tileSize),
		math.floor(self.y*myMap.tileSize),
		math.floor(p.x*myMap.tileSize),
		math.floor(p.y*myMap.tileSize))
	else
		love.graphics.line(self.nodes)
	end
	
	love.graphics.setColor(r,g,b,a)
end

function Bungee:postStep(dt)
	if self.status == 'fly' then
		local dx,dy = self.x-p.x, self.y-p.y
		local length = math.sqrt(dx*dx+dy*dy)
		if length > self.maxLength then
			self:kill()
			return
		end
	end
	
	-- if hook is flying in colliding, then build connection
  if self.collisionResult > 0 then
		self.vx = 0
		self.vy = 0	
		p:connect(self)
		self.status = 'fix'
		self.nodesX = {}
		self.nodesY = {}
		self.nodesNewX = {}
		self.nodesNewY = {}		
		self.nodesVx = {}
		self.nodesVy = {}
		self.nodes = {}
		for i = 0,self.nNodes do
			self.nodesX[i] = p.x + (self.x-p.x)*i/self.nNodes
			self.nodesY[i] = p.y + (self.y-p.y)*i/self.nNodes
			self.nodesVx[i] = 0
			self.nodesVy[i] = 0
			self.nodes[2*i+1] = self.nodesX[i]*myMap.tileSize
			self.nodes[2*i+2] = self.nodesY[i]*myMap.tileSize
		end
  end
 
	if self.nodesX and self.nodesY then
		-- advance according to velocity
		--local factor = 1-math.min(dt,1)
		for i=1,self.nNodes-1 do
			--gravity
			self.nodesVy[i] = self.nodesVy[i] + gravity * dt
			--damping
			local velocity = utility.pyth(self.nodesVy[i],self.nodesVx[i])
			local factor = math.max((velocity - self.friction * dt)/velocity,0)
			
			
			self.nodesVy[i] = self.nodesVy[i]*factor
			self.nodesVx[i] = self.nodesVx[i]*factor
			--apply velocity
			self.nodesNewX[i] = self.nodesX[i] + self.nodesVx[i] * dt
			self.nodesNewY[i] = self.nodesY[i] + self.nodesVy[i] * dt
		end
		
		-- run iteration for line-wobble
		local nx = self.nodesNewX
		local ny = self.nodesNewY		
		local segmentLength = self.length/self.nNodes
		local dx,dy = 0,0
		local dist = 0
		nx[0] ,ny[0]  = p.x,p.y
		nx[self.nNodes],ny[self.nNodes] = self.x,self.y
		for iteration = 1,10 do
			-- forth
			for i = 1,self.nNodes-1 do
				dx,dy = nx[i] - nx[i-1], ny[i] - ny[i-1]
				dist = math.sqrt(dx*dx+dy*dy)
				if dist > segmentLength then
				nx[i] = nx[i-1] + dx/dist*segmentLength
				ny[i] = ny[i-1] + dy/dist*segmentLength
				end
			end
			-- back
			for i = self.nNodes-1,1,-1 do
				dx,dy = nx[i] - nx[i+1], ny[i] - ny[i+1]
				dist = math.sqrt(dx*dx+dy*dy)
				if dist > segmentLength then
					nx[i] = nx[i+1] + dx/dist*segmentLength
					ny[i] = ny[i+1] + dy/dist*segmentLength
				end
			end			
		end


		for i = 1,self.nNodes-1 do
			-- reevaluate new velocity and accept new values
			self.nodesVx[i] = (self.nodesNewX[i] - self.nodesX[i])/dt
			self.nodesVy[i] = (self.nodesNewY[i] - self.nodesY[i])/dt
			self.nodesX[i] = self.nodesNewX[i]
			self.nodesY[i] = self.nodesNewY[i]		
		end
		self.nodesX[0] = p.x
		self.nodesY[0] = p.y

		for i = 0,#self.nodesX do
			-- insert node coordinates in list
			self.nodes[2*i+1] = self.nodesX[i]*myMap.tileSize
			self.nodes[2*i+2] = self.nodesY[i]*myMap.tileSize
		end
  end
end

function Bungee:throw()
	game:checkControls()
	local vx = self.speed * math.cos(p.sonAngle)
	local vy = self.speed * math.sin(p.sonAngle)
	local newBungee = self:New({x=p.x,y=p.y,vx=vx,vy=vy,angle=p.sonAngle})
	spriteEngine:insert(newBungee)	
end

function Bungee:disconnect()
	self:kill()
end
