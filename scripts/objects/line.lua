local Line = object:New({	
	tag = 'Line',
	x = 0,
	y = 0,
	x2 = 10,
	y2 = 10,
	distanceOld = 0,
})

function Line:draw()
	-- store and cancel the current shader:
	local effect = love.graphics.getShader()
	love.graphics.setShader()
	
	love.graphics.setLineWidth(Camera.scale*0.4)
	local r, g, b, a = love.graphics.getColor()	
	love.graphics.setColor(0,0,0)
	local size = myMap and myMap.tileSize or 8*Camera.scale
	love.graphics.line(
		math.floor(self.x*size),
		math.floor(self.y*size),
		math.floor(self.x2*size),
		math.floor(self.y2*size))
	love.graphics.setColor(r,g,b,a)
	
	-- restore pixel effect:
	love.graphics.setShader(effect)
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
	   and distance*self.distanceOld < 0 
	   and p.status ~= 'online' then
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

return Line
