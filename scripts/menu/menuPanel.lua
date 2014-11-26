
local Panel = {}
Panel.__index = Panel

function Panel:new( x, y, width, height )
	local o = {}
	setmetatable(o, self)
	
	o.x = x
	o.y = y

	o.box = BambooBox:new( nil, width, height )
	return o
end

function Panel:draw()
	self.box:draw( self.x, self.y )
end

function Panel:turnIntoList( lineHeight, startOnLine )
	self.box:turnIntoList( lineHeight, startOnLine )
end

return Panel
