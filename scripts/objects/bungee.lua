Bungee = object:New({	
	tag = 'Bungee',
	marginx = 0.1,
  marginy = 0.1,
  speed = 50,
  maxLength = 10,
  minLength = 0.5,
  status = 'fly',
  nNodes = 20,
  friction = 5,
  vis = {Visualizer:New('bungee')},
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
		--love.graphics.line(self.nodes)
		for i=1,self.nNodes do
			love.graphics.line(
				self.nodesX[i-1]*myMap.tileSize,
				self.nodesY[i-1]*myMap.tileSize,
				self.nodesX[i]*myMap.tileSize,
				self.nodesY[i]*myMap.tileSize)
		end
	end
	
	love.graphics.setColor(r,g,b,a)
end

function Bungee:postStep(dt)
	if self.status == 'fly' then
		--self.vis[1].angle = math.atan2(self.vy,self.vx)
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
		local segmentLength = 0.95*self.length/self.nNodes --dirty hack for line visualization
		local dx,dy = 0,0
		local dist = 0
		nx[0] ,ny[0]  = p.x,p.y
		nx[self.nNodes],ny[self.nNodes] = self.x,self.y
		for iteration = 1,25 do
			-- forth
			for i = 1,self.nNodes do
				dx,dy = nx[i] - nx[i-1], ny[i] - ny[i-1]
				mx,my = (nx[i] + nx[i-1])/2,(ny[i] + ny[i-1])/2
				dist = math.sqrt(dx*dx+dy*dy)
				local factor = segmentLength/dist
				if factor < 1 then --or factor > 2 then
					if i == 1 then
						nx[i] = nx[i-1] + dx*factor
						ny[i] = ny[i-1] + dy*factor
					elseif i == self.nNodes then
						nx[i-1] = nx[i] - dx*factor
						ny[i-1] = ny[i] - dy*factor
					else
						nx[i] = mx + 0.5*dx*factor
						ny[i] = my + 0.5*dy*factor
						nx[i-1] = mx - 0.5*dx*factor
						ny[i-1] = my - 0.5*dy*factor
					end
				end			
			end
			
			for i = self.nNodes,1,-1 do
				dx,dy = nx[i] - nx[i-1], ny[i] - ny[i-1]
				mx,my = (nx[i] + nx[i-1])/2,(ny[i] + ny[i-1])/2
				dist = math.sqrt(dx*dx+dy*dy)
				local factor = segmentLength/dist
				if factor < 1 then --or factor > 2 then
					if i == 1 then
						nx[i] = nx[i-1] + dx*factor
						ny[i] = ny[i-1] + dy*factor
					elseif i == self.nNodes then
						nx[i-1] = nx[i] - dx*factor
						ny[i-1] = ny[i] - dy*factor
					else
						nx[i] = mx + 0.5*dx*factor
						ny[i] = my + 0.5*dy*factor
						nx[i-1] = mx - 0.5*dx*factor
						ny[i-1] = my - 0.5*dy*factor
					end
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

function Bungee:relativeLength()
	local dx,dy = p.x-self.x, p.y-self.y
	return self.length-utility.pyth(dx,dy)
end

function Bungee:throw()
	game:checkControls()
	local vx = self.speed * math.cos(p.vis[2].angle)
	local vy = self.speed * math.sin(p.vis[2].angle)
	local newBungee = self:New({x=p.x,y=p.y,vx=vx,vy=vy,vis = {Visualizer:New('bungee',{angle=p.vis[2].angle})} })
	spriteEngine:insert(newBungee)	
end

function Bungee:disconnect()
	self:kill()
end
