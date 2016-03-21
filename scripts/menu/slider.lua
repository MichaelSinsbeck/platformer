-- Class for the buttons in the menu (keyboard/gamepad controlled)

local Slider = {}
Slider.__index = Slider

function Slider:new( images, x, y, width, eventHover, eventChange, name)
	local o = {}
	setmetatable( o, self )
	o.x = x + 4
	o.y = y + 4
	o.images = images
	o.selected = false
	o.isSlider = true	-- The outside world handles a slider just like a button. So make sure they can know I'm a slider!
	o.eventChange = eventChange
	o.eventHover = eventHover
	o.numSegments = #images
	o.width = width
	o.name = name or ""
	o.value = 1
	o.vis = Visualizer:New( images[1] )
	o.vis:init()

	--[[o.captions = {}
	for i = 1, #images do
		o.captions[i] = (captions and captions[i]) or ""
	end]]

	o.text = ""

	-- Set initial value
	Slider.setValue( o, 1, true )
	return o
end

-- Allow setting an event which will be fired when the "CHOOSE" button (i.e. return, enter) is pressed while
-- this slider is selected.
function Slider:setEventChoose( eventChoose )
	self.event = eventChoose
end

function Slider:draw()
	
	self.vis:draw( Camera.scale*(self.x + 36), Camera.scale*(self.y + 2) )
	
	if self.text then
		if self.selected then
			love.graphics.setColor(colors.text)
		else
			love.graphics.setColor(colors.text2)
		end
		love.graphics.print( self.text,
			Camera.scale*self.x, self.y*Camera.scale )
		love.graphics.setColor(255,255,255)
	end
end

function Slider:update( dt )
	self.vis:update( dt )
end

function Slider:select()
	self.selected = true
	if self.eventHover then
		self.eventHover()
	end
end

function Slider:deselect()
	self.selected = false
end

function Slider:setNextLeft( b )
	self.nextLeft = b
end
function Slider:setNextRight( b )
	self.nextRight = b
end
function Slider:setNextUp( b )
	self.nextUp = b
end
function Slider:setNextDown( b )
	self.nextDown = b
end
function Slider:getNextLeft( b )
	return self.nextLeft
end
function Slider:getNextRight( b )
	return self.nextRight
end
function Slider:getNextUp( b )
	return self.nextUp
end
function Slider:getNextDown( b )
	return self.nextDown
end

function Slider:increaseValue()
	if self.value < self.numSegments then
		Sound:play('menuMove')
	end
	self:setValue( math.min( self.value +1, self.numSegments ) )
end

function Slider:decreaseValue()
	if self.value > 1 then
		Sound:play('menuMove')
	end
	self:setValue( math.max( self.value -1, 1 ) )
end

function Slider:setValue( val, dontCallEvent )

	self.value = val

	-- Activate the new segemnt:
	self.vis:setAni( self.images[val] )
	self.vis:update(0)

	self.text = self.name --.. self.captions[self.value]
	if self.eventChange and not dontCallEvent then
		self.eventChange( self.value )
	end
end

function Slider:startEvent()
	if self.event then
		self.event()
		Sound:play('menuEnter')
	end
end

return Slider
