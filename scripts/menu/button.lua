-- Class for the buttons in the menu (keyboard/gamepad controlled)

local Button = {}
Button.__index = Button

function Button:new( imgOff, imgOn, x, y, event, eventHover, text, bottomText )
	local o = {}
	setmetatable( o, self )
	o.imgOff = imgOff
	o.imgOn = imgOn
	o.event = event
	o.eventHover = eventHover
	o.text = text
	o.bottomText = bottomText
	o.x = x + 4
	o.y = y + 4
	o.selected = false
	if #imgOff > 0 then
		o.vis = Visualizer:New( imgOff )
		o.vis:init()
	end
	return o
end

function Button:draw()
	if self.vis then
		self.vis:draw( Camera.scale*self.x, Camera.scale*self.y )
	end
	if self.text then
		if self.selected then
			love.graphics.setColor(colors.text)
		else
			love.graphics.setColor(colors.text2)
		end
		love.graphics.setFont(fontSmall)
		love.graphics.print( self.text,
		math.floor(Camera.scale*(self.x + 8)), math.floor((self.y - 2) *Camera.scale) )
		love.graphics.setColor(colors.white)
	end
end

function Button:update( dt )
	if self.vis then
		self.vis:update( dt )
	end
end

function Button:select()
	self.selected = true
	if self.vis then
		self.vis:setAni( self.imgOn )
	end
	if self.eventHover then
		self.eventHover()
	end
end

function Button:deselect()
	self.selected = false
	if self.vis then
		self.vis:setAni( self.imgOff )
	end
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
		Sound:play('menuEnter')
	end
end

return Button
