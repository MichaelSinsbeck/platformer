local Panel = {}
Panel.__index = Panel
local backgroundColor = {44,90,160,150} -- color of box content
local PADDING = 3

function Panel:new( x, y, width, height )
	local o = {}
	setmetatable(o, self)

	o.x = x or 0
	o.y = y or 0
	o.width = width or 100
	o.height = height or 100
	
	o.box = menu:generateBox( o.x, o.y, o.width, o.height, boxFactor)
	o.clickables = {}

	return o
end

function Panel:addClickable( x, y, event, imgOff, imgOn, imgHover, centered )
	local c = Clickable:new( x+self.x, y+self.y, event, imgOff, imgOn, imgHover, centered )
	table.insert( self.clickables, c )
end

function Panel:draw()

	-- draw the background box:
	-- scale box coordinates according to scale
	local scaled = {}
	for i = 1,#self.box.points do
		scaled[i] = self.box.points[i] * Camera.scale
	end
	-- draw
	love.graphics.setColor( backgroundColor )
	love.graphics.setLineWidth(Camera.scale*0.5)
	love.graphics.rectangle('fill',
	self.box.left*Camera.scale,
	self.box.top*Camera.scale,
	self.box.width*Camera.scale,
	self.box.height*Camera.scale)
	love.graphics.setColor(0,0,0)
	love.graphics.line(scaled)

	love.graphics.setColor(255,255,255,255)
	for k, button in ipairs( self.clickables ) do
		button:draw()
	end
end

function Panel:update( dt, mouseX, mouseY, clicked )

	-- this gets set to true if the click hit a clickable on this panel:
	--local clickHit = false

	for k,button in ipairs( self.clickables ) do
		button:update( dt, mouseX, mouseY, clicked )
		--if button:update( dt, mouseX, mouseY, clicked ) then
		--	clickHit = true
		--end
	end
	--return clickHit
	return self:collisionCheck(mouseX,mouseY)
end

function Panel:collisionCheck( x, y )
	return x/Camera.scale > self.x and
					y/Camera.scale > self.y and
					x/Camera.scale < self.x + self.width and
					y/Camera.scale < self.y + self.height
end


return Panel
