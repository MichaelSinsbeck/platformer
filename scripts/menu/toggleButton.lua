-- Class for the buttons in the menu (keyboard/gamepad controlled)

local TButton = {}
TButton.__index = TButton

function TButton:new( imgOffOff, imgOffOn, imgOnOff, imgOnOn,
		x, y, event, eventHover, captions, name )
	local o = {}
	setmetatable( o, self )
	o.imgOffOff = imgOffOff
	o.imgOffOn = imgOffOn
	o.imgOnOff = imgOnOff or imgOffOff
	o.imgOnOn = imgOnOn or imgOffOn
	o.event = event
	o.eventHover = eventHover
	o.x = x + 4
	o.y = y + 4
	o.selected = false
	o.captions = captions
	o.value = true
	o.name = name or ""
	o.isToggleButton = true		-- Let outside world know I'm a toggle button, not a normal button
	if #o.imgOffOff > 0 then
		o.vis = Visualizer:New( o.imgOffOff )
		o.vis:init()
	end
	o.text = ""
	TButton.toggle( o )
	return o
end

function TButton:draw()
	local y = Camera.scale*self.y
	if self.vis then
		self.vis:draw( Camera.scale*self.x, y )
	end
	love.graphics.print( self.text,
		Camera.scale*(self.x + 8), y - 2*Camera.scale )
	--love.graphics.printf( self.name,
	--	Camera.scale*(self.x - 13) - 500, y - 2*Camera.scale,  500, "right" )
end

function TButton:update( dt )
	if self.vis then
		self.vis:update( dt )
	end
end

function TButton:select()
	self.selected = true
	self:setImage()
	if self.eventHover then
		self.eventHover()
	end
end

function TButton:deselect()
	self.selected = false
	self:setImage()
end

function TButton:setNextLeft( b )
	self.nextLeft = b
end
function TButton:setNextRight( b )
	self.nextRight = b
end
function TButton:setNextUp( b )
	self.nextUp = b
end
function TButton:setNextDown( b )
	self.nextDown = b
end
function TButton:getNextLeft( b )
	return self.nextLeft
end
function TButton:getNextRight( b )
	return self.nextRight
end
function TButton:getNextUp( b )
	return self.nextUp
end
function TButton:getNextDown( b )
	return self.nextDown
end

function TButton:toggle()
	self.value = not self.value
	self.text = self.name .. self.captions[self.value]
	self:setImage()
end

function TButton:setValue( bool )
	self.value = bool
	self.text = self.name .. self.captions[self.value]
	self:setImage()
end


function TButton:setImage()
	if self.vis then
		if self.value == true then
			if self.selected then
				self.vis:setAni( self.imgOnOn )
			else
				self.vis:setAni( self.imgOnOff )
			end
		else
			if self.selected then
				self.vis:setAni( self.imgOffOn )
			else
				self.vis:setAni( self.imgOffOff )
			end
		end
		self.vis:update(0)
	end
end

function TButton:startEvent()
	self:toggle()
	if self.event then
		self.event( self.value )
	end
end

return TButton
