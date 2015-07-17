-- A Submenu is made up of one or more layers, each layer can have any number of panels.
-- Buttons are usually displayed on the panels.

local Panel = require( "scripts/menu/menuPanel" )
local Button = require( "scripts/menu/button" )
local Slider = require( "scripts/menu/slider" )
local ToggleButton = require( "scripts/menu/toggleButton" )
local Transition = require( "scripts/menu/transition" )
local HotkeyDisplay = require( "scripts/menu/hotkeyDisplay" )

local Submenu = {}
Submenu.__index = Submenu

function Submenu:new( x, y )
	local o = {}
	o.layers = {}
	o.activeLayer = 1
	o.x = x or 0
	o.y = y or 0

	setmetatable( o, self )

	o:addLayer( "MainLayer" )

	--o:startIntroTransition()

	return o
end

function Submenu:draw()

	love.graphics.push()
	love.graphics.translate( self.x*Camera.scale, self.y*Camera.scale )

	for k,l in ipairs( self.layers ) do
		if l.visible then

			--if self.imageTransition then
				--self.imageTransition:push()
			--end

			-- Draw all images on this layer:
			for j, i in ipairs( l.images ) do
				love.graphics.draw( AnimationDB.image[i.image], i.x*Camera.scale, i.y*Camera.scale )
			end

			--if self.imageTransition then
				--self.imageTransition:pop()
			--end

			--if self.transition then
				--self.transition:push()
			--end
			-- Draw the panels on this layer:
			for j, p in ipairs( l.panels ) do
				p:draw()
			end

			-- Draw the buttons on this layer:
			for j, b in ipairs( l.buttons ) do
				b:draw()
			end
			-- Draw the hotkey displays on this layer:
			if self.activeLayer == k then
				for j, h in ipairs( l.hotkeys ) do
					h:draw()
				end
			end

			for j, t in ipairs( l.texts ) do
				if t.color then
					love.graphics.setColor(t.color)
				end
				love.graphics.printf( t.text, t.x*Camera.scale, t.y*Camera.scale,
						t.width*Camera.scale, t.align )
			end
			love.graphics.setColor(255,255,255)

			--if self.transition then
				--self.transition:pop()
			--end

			if l.customDrawFunction then
				l.customDrawFunction()
			end
		end
	end

	love.graphics.pop()
end

-- An activation function is called every time the submen is set to visible
function Submenu:activate()
	if self.activateFunction then
		self.activateFunction()
	end
end
function Submenu:setActivateFunction( fnc )
	self.activateFunction = fnc
end
function Submenu:setDeactivateFunction( fnc )
	self.deactivateFunction = fnc
end
function Submenu:deactivate()
	if self.deactivateFunction then
		self.deactivateFunction()
	end
end


function Submenu:update( dt )
	for k,l in ipairs( self.layers ) do
		if l.visible then
			for j, b in ipairs( l.buttons ) do
				b:update( dt )
			end
		end
	end

	--[[if self.transition then
		self.transition:update( dt )
	end
	if self.imageTransition then
		self.imageTransition:update( dt )
	end]]
	if self.customUpdateFunction then
		self.customUpdateFunction( dt )
	end
end

----------------------------------------------------------------------
-- Handling layers:
----------------------------------------------------------------------

function Submenu:addLayer( layerName )
	local layer = {
		name = layerName,
		visible = true,
		panels = {},
		images = {},
		buttons = {},
		texts = {},
		hotkeys = {},
		selectedButton = nil,
	}

	table.insert( self.layers, layer )
	self:setHighestLayerActive()
end

function Submenu:addCustomDrawFunction( fnc, layerName )
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			l.customDrawFunction = fnc
		end
	end
end
function Submenu:addCustomUpdateFunction( fnc )
	self.customUpdateFunction = fnc
end

function Submenu:setLayerVisible( layerName, bool )

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			l.visible = bool
		end
	end

	self:setHighestLayerActive()
end
function Submenu:getLayerVisible( layerName )
	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			return l.visible
		end
	end
	return false
end

function Submenu:setHighestLayerActive()
	-- Set the highest layer to "active"
	for k = #self.layers, 1, -1 do
		if self.layers[k].visible then
			self.activeLayer = k
			return
		end
	end
end

function Submenu:clearLayer( layerName )
	-- Per default, use the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			--l.panels = {}
			l.images = {}
			l.buttons = {}
			l.texts = {}
			--l.hotkeys = {}
			l.selectedButton = nil
		end
	end
end

----------------------------------------------------------------------
-- Adding things to draw on this menu:
----------------------------------------------------------------------

function Submenu:addPanel( x, y, w, h, layerName )

	-- Per default, add panels to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local p = Panel:new( x, y, w, h )
			table.insert( l.panels, p )
			return p
		end
	end
end

function Submenu:addButton( imgOff, imgOn, x, y, event, eventHover, layerName, text, bottomText )
	
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local b = Button:new( imgOff, imgOn, x, y, event, eventHover, text, bottomText )
			table.insert( l.buttons, b )
			self:linkButtons( layerName )
			return b
		end
	end
end

function Submenu:addToggleButton( imgOffOff, imgOffOn, imgOnOff, imgOnOn,
		x, y, event, eventHover, captions, name, layerName )
	
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local b = ToggleButton:new( imgOffOff, imgOffOn, imgOnOff, imgOnOn,
						x, y, event, eventHover, captions, name )
			table.insert( l.buttons, b )
			self:linkButtons( layerName )
			return b
		end
	end
end

function Submenu:addSlider( imgOff, imgOn, x, y, width, segments, eventHover,
		eventChange, captions, name, layerName )
	
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local b = Slider:new( imgOff, imgOn, x, y, width, segments, eventHover, eventChange, captions, name )
			table.insert( l.buttons, b )
			self:linkButtons( layerName )
			return b
		end
	end

end

function Submenu:addImage( image, x, y, layerName )
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local i = {
				image = image,
				x = x,
				y = y,
			}
			table.insert( l.images, i )
		end
	end
end

function Submenu:addText( text, x, y, width, layerName, align )
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"
	align = align or "center"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local t = {
				text = text,
				x = x,
				y = y,
				width = width,
				align = align,
			}
			table.insert( l.texts, t )
			return t
		end
	end
end

function Submenu:addHotkey( func, caption, x, y, event, layerName )
	
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local h = HotkeyDisplay:new( func, caption, x, y, event )
			table.insert( l.hotkeys, h )
		end
	end
end

function Submenu:addHiddenHotkey( func, event, layerName )
	
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local h = HotkeyDisplay:new( func, nil, nil, nil, event )
			table.insert( l.hotkeys, h )
		end
	end
end

----------------------------------------------------------------------
-- Handle button selection:
----------------------------------------------------------------------

function Submenu:linkButtons( layerName )
	-- Find the layer:
	local layer = nil
	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			layer = l
			break
		end
	end

	if layer then
		local vecA = {x=0, y=1}
		-- for each button...
		for i, b1 in pairs( layer.buttons ) do

			-- sort all other buttons into list depending on their angle to this button:
			local left = {}
			local right = {}
			local up = {}
			local down = {}
			for j, b2 in pairs( layer.buttons ) do
				if b1 ~= b2 then
					local vecB = {x=b2.x-b1.x, y=b2.y-b1.y}

					-- cos(theta) = (vecA*vecB)/(|vecA|*|vecB|), which simplifies to:
					local ang = math.acos( vecB.y/math.sqrt(vecB.x*vecB.x + vecB.y*vecB.y) )
					ang = ang*360/2/math.pi
					if vecB.x < 0 then
						ang = 360 - ang
					end
					if ang >= 45 and ang < 135 then
						table.insert( right, b2 )
					elseif ang >= 135 and ang < 225 then
						table.insert( up, b2 )
					elseif ang >= 225 and ang < 315 then
						table.insert( left, b2 )
					else
						table.insert( down, b2 )
					end
				end
			end

			-- The button closest to the right is this button's right neighbour etc.:
			b1:setNextLeft(nil)
			b1:setNextRight(nil)
			b1:setNextUp(nil)
			b1:setNextDown(nil)
			local dist = math.huge
			for i, b in pairs( left ) do
				local x = b.x - b1.x
				local y = b.y - b1.y
				-- Don't take sqrt of distance, not needed since we only use it for 
				-- sorting
				local d = x*x + y*y
				if d < dist then
					dist = d
					b1:setNextLeft( b )
				end
			end
			local dist = math.huge
			for i, b in pairs( right ) do
				local x = b.x - b1.x
				local y = b.y - b1.y
				-- Don't take sqrt of distance, not needed since we only use it for 
				-- sorting
				local d = x*x + y*y
				if d < dist then
					dist = d
					b1:setNextRight( b )
				end
			end
			local dist = math.huge
			for i, b in pairs( up ) do
				local x = b.x - b1.x
				local y = b.y - b1.y
				-- Don't take sqrt of distance, not needed since we only use it for 
				-- sorting
				local d = x*x + y*y
				if d < dist then
					dist = d
					b1:setNextUp( b )
				end
			end
			local dist = math.huge
			for i, b in pairs( down ) do
				local x = b.x - b1.x
				local y = b.y - b1.y
				-- Don't take sqrt of distance, not needed since we only use it for 
				-- sorting
				local d = x*x + y*y
				if d < dist then
					dist = d
					b1:setNextDown( b )
				end
			end
		end
	end
end

function Submenu:setSelectedButton( b, layerName )
	-- Per default, choose the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			if l.selectedButton then
				l.selectedButton:deselect()
			end
			l.selectedButton = b
			b:select()
		end
	end
end

function Submenu:reselectButton()
	-- Per default, choose the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			if l.selectedButton then
				self:setSelectedButton( l.selectedButton, layerName )
				return
			end
			-- If none found, select the first found button:
			if #l.buttons > 0 then
				self:setSelectedButton( l.buttons[1], layerName )
				return
			end
		end
	end
end

function Submenu:getSelectedButton( layerName )
	-- Per default, choose the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			if l.selectedButton then
				return l.selectedButton
			end
		end
	end
end

function Submenu:goLeft()
	if self.activeLayer then
		local l = self.layers[self.activeLayer]
		if l.selectedButton then
			if l.selectedButton.isSlider then
				l.selectedButton:decreaseValue()
			else
				if l.selectedButton:getNextLeft() then
					-- If there is a button left of the selected button,
					-- select that new button:
					self:setSelectedButton(
						l.selectedButton:getNextLeft(),
						l.layerName
					)
					menu:setPlayerDirection( "left" )
				end
			end
		end
	end
end
function Submenu:goRight()
	if self.activeLayer then
		local l = self.layers[self.activeLayer]
		if l.selectedButton then
			if l.selectedButton.isSlider then
				l.selectedButton:increaseValue()
			else
				if l.selectedButton:getNextRight() then
					-- If there is a button left of the selected button,
					-- select that new button:
					self:setSelectedButton(
						l.selectedButton:getNextRight(),
						l.layerName
					)
					menu:setPlayerDirection( "right" )
				end
			end
		end
	end
end
function Submenu:goUp()
	if self.activeLayer then
		local l = self.layers[self.activeLayer]
		if l.selectedButton then
			if l.selectedButton:getNextUp() then
				-- If there is a button left of the selected button,
				-- select that new button:
				self:setSelectedButton(
				l.selectedButton:getNextUp(),
				l.layerName
				)
			end
		end
	end
end
function Submenu:goDown()
	if self.activeLayer then
		local l = self.layers[self.activeLayer]
		if l.selectedButton then
			if l.selectedButton:getNextDown() then
				-- If there is a button left of the selected button,
				-- select that new button:
				self:setSelectedButton(
					l.selectedButton:getNextDown(),
					l.layerName
				)
			end
		end
	end
end

----------------------------------------------------------------------
-- Button events:
----------------------------------------------------------------------

-- Called when user hit's "enter" or similar
function Submenu:startButtonEvent()
	if self.activeLayer then
		local l = self.layers[self.activeLayer]
		if l.selectedButton then
			if not l.selectedButton.isSlider then
				l.selectedButton:startEvent()
			end
		end
	end
end

----------------------------------------------------------------------
-- Hotkey events:
----------------------------------------------------------------------

-- Called when user hit's "enter" or similar
function Submenu:hotkey( key )
	if self.activeLayer then
		print("active:", self.activeLayer, key)
		local l = self.layers[self.activeLayer]
		for i, h in ipairs( l.hotkeys ) do
			if h:getKey() == key then
				print("get")
				h:event()
				return true
			end
		end
	end
	return false
end
function Submenu:gamepadHotkey( key )
	if self.activeLayer then
		local l = self.layers[self.activeLayer]
		for i, h in ipairs( l.hotkeys ) do
			if h:getGamepadKey() == key then
				h:event()
				return true
			end
		end
	end
	return false
end

----------------------------------------------------------------------
-- Change hotkeys when a gamepad is connected:
----------------------------------------------------------------------

function Submenu:connectedGamepad()
	for k, l in ipairs( self.layers ) do
		for i, h in ipairs( l.hotkeys ) do
			h:useGamepadVisualizers()
		end
	end
end
function Submenu:disconnectedGamepad()
	for k, l in ipairs( self.layers ) do
		for i, h in ipairs( l.hotkeys ) do
			h:useKeyboardVisualizers()
		end
	end
end

function Submenu:updateHotkeys()
	for k, l in ipairs( self.layers ) do
		for i, h in ipairs( l.hotkeys ) do
			h:update()
		end
	end
end

----------------------------------------------------------------------
-- Add transitions:
----------------------------------------------------------------------

--[[
function Submenu:startIntroTransition( introEvent )
	self.transition = Transition:new( self, 1, 0, 1000, 0, 0, 0, 0, 0.5 )
	self.imageTransition = Transition:new( self, 1, 0, -1000, 0, 0, 0, 0, 0 )
	self.introEvent = function()
		self:reselectButton()
		if introEvent then
			introEvent()
		end
	end
end

function Submenu:startExitTransition( exitEvent )
	self.transition = Transition:new( self, 0.5, 0, 0, 0, 0, 1000, 0, 0 )
	self.imageTransition = Transition:new( self, 0.5, 0, 0, 0, 0, -1000, 0, 0 )
	self.exitEvent = exitEvent
end

-- Called when the submenu's enter or exit transition is done:
function Submenu:finishedTransition( transition )
	if transition == self.transition then
		self.transition = nil
	elseif transition == self.imageTransition then
		self.imageTransition = nil
	end
	if self.transition == nil and self.imageTransition == nil then
		if self.exitEvent then
			self.exitEvent()
			self.exitEvent = nil
		elseif self.introEvent then
			self.introEvent()
			self.introEvent = nil
		end
	end
end

function Submenu:getTransition()
	return (self.transition ~= nil or self.imageTransition ~= nil)
end
]]

return Submenu
