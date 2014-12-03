local HotkeyDisplay = {}
HotkeyDisplay.__index = HotkeyDisplay

function HotkeyDisplay:new( func, caption, x, y, event )
	local o = {}
	setmetatable( o, self )
	o.x = x
	o.y = y
	o.func = func	-- Name of the key function (JUMP, LEFT etc)
	o.key = keys[func]
	o.gamepadKey = keys.PAD[func]
	o.keyName = nameForKey( o.key )
	o.caption = caption
	o.assignedEvent = event
	if caption then	-- Add display
		o.vis = Visualizer:New( getAnimationForKey( o.key ) )
		o.vis:init()
		o.textVis = Visualizer:New( nil, nil, nameForKey( o.key ) )
		o.textVis:init()
		o.captionVis = Visualizer:New( nil, nil, caption )
		o.captionVis:init()
		o.gamepadVis = Visualizer:New( getAnimationForPad( o.gamepadKey ) )
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

function HotkeyDisplay:update()

	-- If the key I'm displaying is no longer the one for
	-- the function I should be displaying, update:
	if self.key ~= keys[self.func] then
		self.key = keys[self.func]
		self.keyName = nameForKey( self.key )
		--if self.caption then
			self.vis = Visualizer:New( getAnimationForKey( self.key ) )
			self.vis:init()
			self.textVis = Visualizer:New( nil, nil, nameForKey( self.key ) )
			self.textVis:init()
		--end
	end
	-- Same for gamepad:
	if self.gamepadKey ~= keys.PAD[self.func] then
		self.gamepadKey = keys.PAD[self.func]
		self.gamepadVis = Visualizer:New( getAnimationForPad( self.gamepadKey ) )
		self.gamepadVis:init()
	end
end

return HotkeyDisplay
