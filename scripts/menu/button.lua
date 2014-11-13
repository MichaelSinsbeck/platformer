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
	o.x = x + 4
	o.y = y + 4
	o.selected = false
	o.vis = Visualizer:New( imgOff )
	o.vis:init()
	return o
end

function Button:draw()
	--print( self.imgOff, Animate
	self.vis:draw( Camera.scale*self.x, Camera.scale*self.y )
end

function Button:update( dt )
	self.vis:update( dt )
end

function Button:select()
	self.selected = true
	self.vis:setAni( self.imgOn )
	if self.eventHover then
		self.eventHover()
	end
end

function Button:deselect()
	self.selected = false
	self.vis:setAni( self.imgOff )
end

function Button:setNextLeft( b )
	self.nextLeft = b
end
function Button:setNextRight( b )
	self.nextRight = b
end
function Button:setNextUp( b )
	self.nextUp = b
end
function Button:setNextDown( b )
	self.nextDown = b
end
function Button:getNextLeft( b )
	return self.nextLeft
end
function Button:getNextRight( b )
	return self.nextRight
end
function Button:getNextUp( b )
	return self.nextUp
end
function Button:getNextDown( b )
	return self.nextDown
end

function Button:startEvent()
	if self.event then
		self.event()
	end
end

return Button
