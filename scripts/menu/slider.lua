-- Class for the buttons in the menu (keyboard/gamepad controlled)

local Slider = {}
Slider.__index = Slider

function Slider:new( x, y, width, segments, eventHover, eventChange, captions, name )
	local o = {}
	setmetatable( o, self )
	o.x = x + 4
	o.y = y + 4
	o.selected = false
	o.isSlider = true	-- The outside world handles a slider just like a button. So make sure they can know I'm a slider!
	o.eventChange = eventChange
	o.eventHover = eventHover
	o.numSegments = segments
	o.width = width
	o.name = name or ""
	o.value = 1
	o.vis = {}
	o.dx = o.width/o.numSegments
	o.captions = {}
	-- For every possible choise, generate a segment:
	for i = 1, segments do
		o.captions[i] = (captions and captions[i]) or ""
		o.vis[i] = Visualizer:New( "sliderSegmentOff" )
		o.vis[i]:init()
	end
	-- This must be in an extra loop, because the chooseImage depends on the 
	-- number of captions, so _all_ captions must be set before the chooseImage
	-- function is first called:
	for i = 1, segments do
		-- make sure the right image is chosen for this visualizer:
		Slider.chooseImage( o, i, "off" )
	end

	o.text = ""

	Slider.setValue( o, 1, true )
	return o
end

function Slider:draw()
	local y = Camera.scale*self.y
	for i = 1, self.numSegments do
		self.vis[i]:draw( Camera.scale*(self.x+self.dx*(i-1)), y )
	end
	love.graphics.print( self.text,
		Camera.scale*(self.x+self.dx*self.numSegments), y - 2*Camera.scale )
	--love.graphics.printf( self.name,
	--	Camera.scale*(self.x - 13) - 500, y - 2*Camera.scale,  500, "right" )
end

function Slider:update( dt )
	if self.selected then
		for i = 1, self.numSegments do
			self.vis[i]:update( dt )
		end
	end
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
	self:setValue( math.min( self.value +1, self.numSegments ) )
end

function Slider:decreaseValue()
	self:setValue( math.max( self.value -1, 1 ) )
end

-- This function chooses the appropriate visualizer depending on the state of the 
-- slider segment at "value"
function Slider:chooseImage( value, active )
	if active == "on" then
		if value == 1 then
			self.vis[value]:setAni( "sliderSegmentOnEnd" )
			self.vis[value].sx = -1
		elseif value == #self.captions then
			self.vis[value]:setAni( "sliderSegmentOnEnd" )
			self.vis[value].sx = 1
		else 
			self.vis[value]:setAni( "sliderSegmentOn" )
			self.vis[value].sx = 1
		end
	else
		if value == 1 then
			self.vis[value]:setAni( "sliderSegmentOffEnd" )
			self.vis[value].sx = -1
		elseif value == #self.captions then
			self.vis[value]:setAni( "sliderSegmentOffEnd" )
			self.vis[value].sx = 1
		else
			self.vis[value]:setAni( "sliderSegmentOff" )
			self.vis[value].sx = 1
		end
	end
	-- Update, to actually set the new image:
	self.vis[value]:update(0)
end

function Slider:setValue( val, dontCallEvent )

	-- Deactivate the current segemnt:
	self:chooseImage( self.value, "off" )

	self.value = val

	-- Activate the new segemnt:
	self:chooseImage( self.value, "on" )

	self.text = self.name .. self.captions[self.value]
	if self.eventChange and not dontCallEvent then
		self.eventChange( self.value )
	end
end

return Slider
