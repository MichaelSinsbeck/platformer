local Cam = {}

Cam.__index = Cam

function Cam:new( x, y )
	local o = {}
	setmetatable(o, Cam)

	o.x = x or love.graphics.getWidth()/2
	o.y = y or love.graphics.getHeight()/2

	o.zoom = 1
	return o
end

function Cam:apply()
	love.graphics.push()
	love.graphics.scale(self.zoom)
	love.graphics.translate(self.x, self.y)
end

function Cam:free()
	love.graphics.pop()
end

function Cam:move( dx, dy )
	self.x = self.x + dx
	self.y = self.y + dy
end

function Cam:zoomIn()
	self.zoom = math.min(self.zoom*2, 1)
end

function Cam:zoomOut()
	self.zoom = math.max(self.zoom/2, 0.25)
end

function Cam:screenToWorld( screenX, screenY )
	return screenX*self.zoom - self.x, screenY*self.zoom - self.y
end

return Cam
