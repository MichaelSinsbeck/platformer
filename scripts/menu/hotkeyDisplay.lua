local HotkeyDisplay = {}
HotkeyDisplay.__index = HotkeyDisplay

function HotkeyDisplay:new( key, gamepadKey, caption, x, y, event )
	local o = {}
	setmetatable( o, self )
	o.x = x
	o.y = y
	o.keyName = nameForKey( key )
	o.key = key
	o.gamepadKey = gamepadKey
	o.caption = caption
	o.assignedEvent = event
	if caption then	-- Add display
		o.vis = Visualizer:New( getAnimationForKey( key ) )
		o.vis:init()
		o.textVis = Visualizer:New( nil, nil, nameForKey(key) )
		o.textVis:init()
		o.captionVis = Visualizer:New( nil, nil, caption )
		o.captionVis:init()
		o.gamepadVis = Visualizer:New( getAnimationForPad( gamepadKey ) )
		o.gamepadVis:init()
	end
	return o
end

function HotkeyDisplay:draw()
	if self.gamepad then
		self.gamepadVis:draw( self.x*Camera.scale, self.y*Camera.scale )
	else
		self.vis:draw( self.x*Camera.scale, self.y*Camera.scale )
		self.textVis:draw( self.x*Camera.scale, self.y*Camera.scale )
	end
	self.captionVis:draw( self.x*Camera.scale, (self.y + 6)*Camera.scale )
end

function HotkeyDisplay:getKey()
	return self.key
end
function HotkeyDisplay:getGamepadKey()
	return self.gamepadKey
end

function HotkeyDisplay:event()
	if self.assignedEvent then
		self.assignedEvent()
	end
end

-- Draw gamepad hotkeys only
function HotkeyDisplay:useGamepadVisualizers()
	self.gamepad = true
end

-- Draw keyboard hotkeys only
function HotkeyDisplay:useKeyboardVisualizers()
	self.gamepad = false
end

return HotkeyDisplay
