Line = object:New({	
	x = 0,
	y = 0,
	x2 = 10,
	y2 = 10,
	distanceOld = 0,
})

function Line:draw()
	love.graphics.setLineWidth(Camera.scale*0.4)
	local r, g, b, a = love.graphics.getColor()	
	love.graphics.setColor(0,0,0)
	love.graphics.line(
		math.floor(self.x*myMap.tileSize),
		math.floor(self.y*myMap.tileSize),
		math.floor(self.x2*myMap.tileSize),
		math.floor(self.y2*myMap.tileSize))
	--if self.sonx and self.sony then
	--  love.graphics.circle('fill',
	--		math.floor(self.sonx*myMap.tileSize),
	--		math.floor(self.sony*myMap.tileSize),
	--		self.radius,10)
	--end	
	
	love.graphics.setColor(r,g,b,a)
end

function Line:init()
	-- calculate direction vector and normal vector
	local dx = self.x2-self.x
	local dy = self.y2-self.y
	self.length = math.sqrt(dx*dx+dy*dy)
	self.ex = dx/self.length
	self.ey = dy/self.length
	self.nx = -self.ey
	self.ny = self.ex
	if self.ny > 0 then
	  self.nx,self.ny = -self.nx,-self.ny
	end
end

function Line:update(dt)
	-- check distance to player an make him 'online', if necessary
	local dx,dy = p.x+p.linePointx-self.x,p.y+p.linePointy-self.y
	local distance = (self.nx * dx + self.ny * dy)
	local position = self.ex * dx + self.ey*dy

	
	if p.line and p.line == self then
	  distance = 0
	end
	
	if position > 0 
	   and position < self.length 
	   --and math.abs(distance) < math.abs(self.distanceOld)
	   and distance*self.distanceOld < 0 then
	  if p.vy < 0 and not game.isUp then
			p.status = 'online'
			p.line = self
		elseif p.vy > 0 and not game.isDown then
			p.status = 'online'
			p.line = self
		end
	end
	self.distanceOld = distance
end
