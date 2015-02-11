local Bungee = object:New({	
	tag = 'Bungee',
	marginx = 0.1,
  marginy = 0.1,
  maxLength = 10,
  minLength = 0.5,
	speed = 50, -- speed of rope shooting
  lifetime = 5,
  status = 'fly',
  nNodes = 20,
  friction = 2, --5
  vis = {Visualizer:New('bungee')},
  tx = 0,
  ty = 0,
})

function Bungee:setAcceleration(dt)
end

--[[function Bungee:collision()
	local dist = utility.pyth(self.newX-self.x,self.newY-self.y)
	local air, tx, ty = myMap:raycast(self.x,self.y, self.vx, self.vy, dist)
	if not air then
		self.newX = tx
		self.newY = ty
		self.collisionResult = true
	else
		self.collisionResult = false
	end
end]]

function Bungee:draw()
	local r, g, b, a = love.graphics.getColor()	
	
	local thisAlpha = math.min(5*255*self.lifetime/Bungee.lifetime,255)
	if self.status == 'dangle' then
		thisAlpha = math.min(thisAlpha,127)
	end
	self.vis[1].alpha = thisAlpha
	object.draw(self) -- draw hook at the end
	
	love.graphics.setLineWidth(Camera.scale*0.4)
	
	local color = utility.bandana2color[p.bandana]
	
	love.graphics.setColor(color[1],color[2],color[3],thisAlpha)
	if self.status == 'fly' then
	love.graphics.line(
		math.floor(self.x*myMap.tileSize),
		math.floor(self.y*myMap.tileSize),
		math.floor(p.x*myMap.tileSize),
		math.floor(p.y*myMap.tileSize))
	else
		local curve = love.math.newBezierCurve(self.nodes)
		local nodesToDraw = curve:render()
		love.graphics.line(nodesToDraw)
	end
	
	love.graphics.setColor(r,g,b,a)
end

function Bungee:postStep(dt)
	if self.status == 'fly' then
		local dx,dy = self.target.x-self.x,self.target.y-self.y
		local dist = math.sqrt(dx^2+dy^2)
		local ratio = self.speed*dt/dist
		local radius = .6
		if not self.dead then
			if self.speed*dt + radius >= dist then
				if dist > radius then
					self.x = self.x + dx *(dist-radius)/dist
					self.y = self.y + dy *(dist-radius)/dist
				end
				-- make connection
				p:connect(self)
				self.status = 'fix'
				self.nodesX = {}
				self.nodesY = {}
				self.nodesNewX = {}
				self.nodesNewY = {}		
				self.nodesVx = {}
				self.nodesVy = {}
				self.nodes = {}
				-- create nodes (linear)
				for i = 0,self.nNodes do
					self.nodesX[i] = p.x + (self.x-p.x)*i/self.nNodes
					self.nodesY[i] = p.y + (self.y-p.y)*i/self.nNodes
					self.nodesVx[i] = 0
					self.nodesVy[i] = 0
					self.nodes[2*i+1] = self.nodesX[i]*myMap.tileSize
					self.nodes[2*i+2] = self.nodesY[i]*myMap.tileSize
				end	
			else
			  -- move
				self.x = self.x + dx*ratio
				self.y = self.y + dy*ratio
				-- check for distance to player
				local dx,dy = self.x-p.x, self.y-p.y
				local length = math.sqrt(dx*dx+dy*dy)
				if length > self.maxLength then
					self:kill()
					return
				end
			end
		end
	end
 
	if self.nodesX and self.nodesY then
		-- advance according to velocity
		--local factor = 1-math.min(dt,1)
		for i=0,self.nNodes-1 do
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
		if self.status == 'fix' then
			nx[0] ,ny[0]  = p.x,p.y
		end
		if self.status ~= 'fall' then
			nx[self.nNodes],ny[self.nNodes] = self.x,self.y
		end
		for iteration = 1,25 do
			-- forth
			for i = 1,self.nNodes do
				dx,dy = nx[i] - nx[i-1], ny[i] - ny[i-1]
				mx,my = (nx[i] + nx[i-1])/2,(ny[i] + ny[i-1])/2
				dist = math.sqrt(dx*dx+dy*dy)
				local factor = segmentLength/dist
				if factor < 1 then --or factor > 2 then
					if i == 1 and self.status == 'fix' then
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
			-- back
			for i = self.nNodes,1,-1 do
				dx,dy = nx[i] - nx[i-1], ny[i] - ny[i-1]
				mx,my = (nx[i] + nx[i-1])/2,(ny[i] + ny[i-1])/2
				dist = math.sqrt(dx*dx+dy*dy)
				local factor = segmentLength/dist
				if factor < 1 then --or factor > 2 then
					if i == 1 and self.status == 'fix' then
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

		for i = 0,self.nNodes-1 do
			-- reevaluate new velocity and accept new values
			self.nodesVx[i] = (self.nodesNewX[i] - self.nodesX[i])/dt
			self.nodesVy[i] = (self.nodesNewY[i] - self.nodesY[i])/dt
			self.nodesX[i] = self.nodesNewX[i]
			self.nodesY[i] = self.nodesNewY[i]		
		end
		if self.status == 'fix' then
			self.nodesX[0] = p.x
			self.nodesY[0] = p.y
			self.nodesVx[0] = p.vx
			self.nodesVy[0] = p.vy
		end
		

		for i = 0,#self.nodesX do
			-- insert node coordinates in list
			self.nodes[2*i+1] = self.nodesX[i]*myMap.tileSize
			self.nodes[2*i+2] = self.nodesY[i]*myMap.tileSize
		end
  end
  
  if self.status == 'dangle' then
		self.lifetime = self.lifetime - dt
		if self.lifetime < 0 then
			self:kill()
		end
  end
end

function Bungee:relativeLength()
	local dx,dy = p.x-self.x, p.y-self.y
	return self.length-utility.pyth(dx,dy)
end

function Bungee:throw()
	--game:checkControls()
	local vx = self.speed * math.cos(p.vis[2].angle)
	local vy = self.speed * math.sin(p.vis[2].angle)
	local newBungee = self:New({x=p.x, y=p.y, vx=vx, vy=vy, vis = {Visualizer:New('bungee',{angle=p.vis[2].angle})} })
	spriteEngine:insert(newBungee)	
end

function Bungee:disconnect()
	if self.status == 'fly' then
		self:kill()
		--[[self.status = 'fall'
		self.length = utility.pyth(self.x-p.x,self.y-p.y)+0.1
		self.nodesX = {}
		self.nodesY = {}
		self.nodesNewX = {}
		self.nodesNewY = {}		
		self.nodesVx = {}
		self.nodesVy = {}
		self.nodes = {}
		-- create nodes (linear)
		for i = 0,self.nNodes do
			self.nodesX[i] = p.x + (self.x-p.x)*i/self.nNodes
			self.nodesY[i] = p.y + (self.y-p.y)*i/self.nNodes
			self.nodesVx[i] = self.vx
			self.nodesVy[i] = self.vy
			self.nodes[2*i+1] = self.nodesX[i]*myMap.tileSize
			self.nodes[2*i+2] = self.nodesY[i]*myMap.tileSize
		end	--]]
	else
		self.status = 'dangle'
	end
end

return Bungee
