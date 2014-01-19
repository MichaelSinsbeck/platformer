local Cam = {}

Cam.__index = Cam

--[[
Reminder for the future:
Formula for the relation between 
z - zoom (scalar)
s - screen coordinates (vector)
w - world coordinates (vector)
c - camera position (vector)

w * z = s - c

--]]

function Cam:new( x, y )
	local o = {}
	setmetatable(o, Cam)

	o.x = x or love.graphics.getWidth()/2
	o.y = y or love.graphics.getHeight()/2

	o.zoom = 1
	return o
end

function Cam:apply()
	-- center camera to mouse, if right mouse button is pressed
	if self.panning then
		local x, y = love.mouse.getPosition()
		self:alignTo(self.anchorX,self.anchorY,x,y)
	end
	
	-- apply transform
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	love.graphics.scale(self.zoom)
end

function Cam:free()
	love.graphics.pop()
end

function Cam:move( dx, dy )
	self.x = self.x + dx
	self.y = self.y + dy
end

function Cam:zoomIn()
	local x, y = love.mouse.getPosition()
	local wX, wY = self:screenToWorld( x, y )
	self.zoom = math.min(self.zoom*2, 1)
	self:alignTo(wX,wY,x,y)
end

function Cam:zoomOut()
	local x, y = love.mouse.getPosition()
	local wX, wY = self:screenToWorld( x, y )
	self.zoom = math.max(self.zoom/2, 0.25)
	wX = math.floor(wX*self.zoom)/self.zoom
	wY = math.floor(wY*self.zoom)/self.zoom
	self:alignTo(wX,wY,x,y)
end

function Cam:screenToWorld( screenX, screenY ) -- solve formula for w
	return (screenX-self.x)/self.zoom, (screenY-self.y)/self.zoom
end

function Cam:alignTo( worldX, worldY, screenX, screenY)
	-- sets Cam.x and Cam.y such that specified world point lies at specified
	-- screen position
	-- solve formula for c
	self.x = screenX - worldX * self.zoom
	self.y = screenY - worldY * self.zoom
end

function	Cam:setMouseAnchor()  -- saves world-coordinates of mouse
	local x, y = love.mouse.getPosition()
	self.anchorX, self.anchorY = self:screenToWorld( x, y )
	self.panning = true
end

function Cam:releaseMouseAnchor()
	self.panning = false
end

return Cam
