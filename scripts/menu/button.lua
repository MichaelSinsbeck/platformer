-- Class for the buttons in the menu (keyboard/gamepad controlled)

local Button = {}
Button.__index = Button

function Button:new( imgOff, imgOn, x, y, event, eventHover )
	local o = {}
	setmetatable( o, self )
	o.imgOff = imgOff
	o.imgOn = imgOn
	o.event = event
	o.eventHover = eventHover
	o.x = x
	o.y = y
	o.selected = false
	return o
end

function Button:draw()
	--print( self.imgOff, Animate
	love.graphics.draw( AnimationDB.image[self.imgOff], self.x*Camera.scale, self.y*Camera.scale )
end

function Button:update( dt )
	--self.vis:update( dt )
end

return Button
