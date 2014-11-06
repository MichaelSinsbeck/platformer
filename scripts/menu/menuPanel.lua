
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

function Panel:addButton( x, y, vis )

end

function Panel:draw()
	self.box:draw( self.x, self.y )
end

return Panel
