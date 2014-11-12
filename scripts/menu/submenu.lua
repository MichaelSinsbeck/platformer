-- A Submenu is made up of one or more layers, each layer can have any number of panels.
-- Buttons are usually displayed on the panels.

local Panel = require( "scripts/menu/menuPanel" )
local Button = require( "scripts/menu/button" )

local Submenu = {}
Submenu.__index = Submenu

function Submenu:new()
	local o = {}
	o.layers = {}
	o.activeLayer = 1

	setmetatable( o, self )

	o:addLayer( "MainLayer" )

	return o
end

function Submenu:draw()
	for k,l in ipairs( self.layers ) do
		if l.visible then

			-- Draw all images on this layer:
			for j, i in ipairs( l.images ) do
				love.graphics.draw( AnimationDB.image[i.image], i.x*Camera.scale, i.y*Camera.scale )
			end

			-- Draw the panels on this layer:
			for j, p in ipairs( l.panels ) do
				p:draw()
			end

			-- Draw the buttons on this layer:
			for j, b in ipairs( l.buttons ) do
				b:draw()
			end
		end
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
end

function Submenu:addLayer( layerName )
	local layer = {
		name = layerName,
		visible = true,
		panels = {},
		images = {},
		buttons = {},
		selectedButton = nil,
	}

	table.insert( self.layers, layer )
	self:setHighestLayerActive()
end

function Submenu:setLayerVisible( layerName, bool )

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			l.visible = bool
		end
	end

	self:setHighestLayerActive()
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

function Submenu:addButton( imgOff, imgOn, x, y, event, eventHover, layerName )
	
	-- Per default, add to the main layer:
	layerName = layerName or "MainLayer"

	for k, l in ipairs( self.layers ) do
		if l.name == layerName then
			local b = Button:new( imgOff, imgOn, x, y, event, eventHover )
			table.insert( l.buttons, b )
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
					print( ang )
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
			print("tables:", #left, #right, #up, #down )

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

function Submenu:goLeft()
	if self.activeLayer then
		local l = self.layers[self.activeLayer]
		if l.selectedButton then
			if l.selectedButton:getNextLeft() then
				-- If there is a button left of the selected button,
				-- select that new button:
				self:setSelectedButton(
				l.selectedButton:getNextLeft(),
				l.layerName
				)
			end
		end
	end
end
function Submenu:goRight()
	if self.activeLayer then
		local l = self.layers[self.activeLayer]
		if l.selectedButton then
			if l.selectedButton:getNextRight() then
				-- If there is a button left of the selected button,
				-- select that new button:
				self:setSelectedButton(
				l.selectedButton:getNextRight(),
				l.layerName
				)
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

return Submenu
