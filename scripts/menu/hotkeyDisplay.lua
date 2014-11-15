local HotkeyDisplay = {}
HotkeyDisplay.__index = HotkeyDisplay

function HotkeyDisplay:new( key, gamepadKey, caption, x, y, event )
	local o = {}
	setmetatable( o, self )
	o.x = x
	o.y = y
	o.keyName = nameForKey( key )
	o.key = key
	o.caption = caption
	o.event = event
	if caption then	-- Add display
		o.vis = Visualizer:New( getAnimationForKey( key ) )
		o.vis:init()
		o.textVis = Visualizer:New( nil, nil, nameForKey(key) )
		o.textVis:init()
		o.captionVis = Visualizer:New( nil, nil, caption )
		o.captionVis:init()
	end
	return o
end

function HotkeyDisplay:draw()
	if self.vis then
		self.vis:draw( self.x*Camera.scale, self.y*Camera.scale )
		self.textVis:draw( self.x*Camera.scale, self.y*Camera.scale )
		self.captionVis:draw( self.x*Camera.scale, (self.y + 6)*Camera.scale )
	end
end

function HotkeyDisplay:getKey()
	return self.key
end

function HotkeyDisplay:event()
	if self.event then
		self.event()
	end
end

return HotkeyDisplay
