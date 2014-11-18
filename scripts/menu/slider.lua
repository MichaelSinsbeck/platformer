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
	for i = 1, segments do
		o.captions[i] = (captions and captions[i]) or ""
		o.vis[i] = Visualizer:New( "worldItemOff" )
		o.vis[i]:init()
	end

	Slider.setValue( o, 1 )
	return o
end

function Slider:draw()
	--print( self.imgOff, Animate
	local y = Camera.scale*self.y
	for i = 1, self.numSegments do
		self.vis[i]:draw( Camera.scale*(self.x+self.dx*(i-1)), y )
	end
	love.graphics.print( self.captions[self.value],
		Camera.scale*(self.x+self.dx*self.numSegments), y - 2*Camera.scale )
	love.graphics.printf( self.name,
		Camera.scale*(self.x - 13) - 500, y - 2*Camera.scale,  500, "right" )
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

function Slider:setValue( val )
	self.vis[self.value]:setAni( "worldItemOff" )
	self.vis[self.value]:update(0)
	self.value = val
	self.vis[self.value]:setAni( "worldItemOn" )
	self.vis[self.value]:update(0)
	if self.eventChange then
		self.eventChange( self.value )
	end
end

return Slider
