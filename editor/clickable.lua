-------------------------------------------
-- Button library for the editor.
-- As opposed to the buttons in the menu scripts, these
-- ones react to the mouse only.
--
-- Clickable:new:
-- The buttons can have images for "off" (no mouse),
-- "on" (clicked) and "hovering" (mouse is over the
-- object, but not clicked). If no "hovering" images is
-- given, then the "on" image is used for it as well.
--
-- Clickable:newLabel:
-- Creates clickable label. The clickable area
-- automatically fits the size of the image (plus a
-- small padding).

-- Mouse interaction:
-- The clickable needs to be updated every frame.
-- it will react when the mouse is within the 
-- dimensions of imgOff.
--
-- If "centered" is set to true, it will draw the button
-- centered at the x and y position.
-- Images for off, on and hover ideally have the same
-- dimensions.
--
-- TODO:
-- allow visualizers to be used instead of plain images.
-- edit: done by Micha

local Clickable = {}
Clickable.__index = Clickable
local PADDING = 5	-- padding around labeled buttons

function Clickable:new( x, y, event, imgOff, imgOn, imgHover, toolTip, centered, useMesh )
	local o = {}
	setmetatable(o, self)

	o.imgOff = imgOff
	o.imgOn = imgOn
	o.imgHover = imgHover or imgOn
	o.centered = centered
	o.toolTip = toolTip  or ""

	-- Add visualizer
	o.vis = {}
	o.vis[1] = Visualizer:New(imgOff)
	o.vis[1]:init()
	if useMesh then
		o.vis[1]:useMesh()
	end
	o.width, o.height = o.vis[1]:getSize()
	
	--o.width = imgOff:getWidth()
	--o.height = imgOff:getHeight()

	o.x = x or 0
	o.y = y or 0
	if centered then
		o.x = o.x - o.width/2
		o.y = o.y - o.height/2
	end

	-- for collision checking:
	o.minX = x*Camera.scale - 0.5 * o.width
	o.minY = y*Camera.scale - 0.5 * o.height
	o.maxX = o.minX + o.width
	o.maxY = o.minY + o.height

	o.event = event

	self.active = "off"

	return o
end

function Clickable:newFromObject( x, y, event, obj, toolTip, centered )
	local o = {}
	setmetatable(o, self)
	
	o.centered = centered
	o.toolTip = toolTip  or ""


	-- Add visualizer
	o.vis = obj.vis
	o.width, o.height = -math.huge, -math.huge
	for k = 1, #o.vis do
		o.vis[k]:init()
		local w, h = o.vis[k]:getSize()
		o.width, o.height = math.max(o.width, w), math.max(o.height, h)
	end
	
	--o.width = imgOff:getWidth()
	--o.height = imgOff:getHeight()

	o.x = (x or 0) + o.width*0.5/Camera.scale
	o.y = (y or 0) + o.height*0.5/Camera.scale
	if centered then
		o.x = o.x - o.width/2
		o.y = o.y - o.height/2
	end

	-- for collision checking:
	o.minX = x*Camera.scale
	o.minY = y*Camera.scale
	o.maxX = o.minX + o.width
	o.maxY = o.minY + o.height

	o.event = event

	self.active = "off"

	return o
end

function Clickable:newLabel( x, y, event, text, font )
	local o = {}
	o.__index = Clickable
	setmetatable( o, Clickable )

	o.font = font or fontSmall
	o.wdith = o.font:getWidth( text ) + PADDING*2
	o.height = o.font:getHeight() + PADDING*2
	o.text = text

	o.x = x or 0
	o.y = y or 0
	o.textX = o.x + PADDING
	o.textY = o.y + PADDING

	o.minX = x*Camera.scale
	o.minY = y*Camera.scale
	o.maxX = o.minX + o.width
	o.maxY = o.minY + o.height

	o.event = event

	self.active = "off"
end

function Clickable:newBatch( x, y, event, batch, width, height, toolTip, centered )
	local o = {}
	setmetatable(o, self)

	o.batch = batch
	o.toolTip = toolTip  or ""

	-- react when mouse is in the area:
	o.width, o.height = width*Camera.scale, height*Camera.scale
	
	o.x = x or 0
	o.y = y or 0
	if centered then
		o.x = o.x - o.width/2
		o.y = o.y - o.height/2
	end

	-- for collision checking:
	o.minX = x*Camera.scale
	o.minY = y*Camera.scale
	o.maxX = o.minX + o.width
	o.maxY = o.minY + o.height

 	o.event = event

	o.active = "off"

	return o

end

function Clickable:draw()
	if self.vis then
		local iW, iH = editor.images.highlight:getWidth(), editor.images.highlight:getHeight()
		local dX, dY = (self.width-iW)*0.5, (self.height-iH)*0.5
		if self.selected then
			love.graphics.draw( editor.images.highlight,
				(self.x)*Camera.scale-self.width/2+dX,
				(self.y)*Camera.scale-self.height/2+dY)
		end
		for k = 1, #self.vis do
			self.vis[k]:draw(self.x*Camera.scale,self.y*Camera.scale)
		end
	else
		love.graphics.draw( self.batch, self.x*Camera.scale, self.y*Camera.scale )
	end
	if self.text then
		if self.active == "off" then
			love.graphics.setColor( 120, 120, 160 )
		elseif self.active == "hover" then
			love.graphics.setColor( 120, 120, 200 )
		else
			love.graphics.setColor( 150, 150, 220 )
		end
		love.graphics.rectangle( 'fill', self.x*Camera.scale, self.y*Camera.scale, self.width, self.height )
		love.graphics.setColor(255,255,255)
		love.graphics.print( self.textX, self.textY, self.text )
	end
	--love.graphics.rectangle( 'line', self.minX, self.minY, self.width, self.height )
end

function Clickable:click( mouseX, mouseY, clicked, msgBoxActive )
	if msgBoxActive then
		self.active = "off"
		if self.imgOff then
			self:setAnim(self.imgOff)
		end
	else
		if self:collisionCheck( mouseX, mouseY ) then
			editor.setToolTip( self.toolTip )
			if clicked then
				-- new click?
				if self.active ~= "click" then
					-- if new click, run the event:
					if self.event then
						self.event()
					end
					self.active = "click"
					self:setAnim(self.imgOn)
					return true
				end
			else
				self.active = "hover"
				if self.imgHover then
					self:setAnim(self.imgHover)
				end
			end
		else
			self.active = "off"
			if self.imgOff then
				self:setAnim(self.imgOff)
			end
		end
	end

	return false
end

function Clickable:setSelected( bool )
	self.selected = bool
	--[[if self.selected then
	self:setAnim(self.imgOn)
	else
	self:setAnim(self.imgOff)
	end]]--
end

function Clickable:collisionCheck( x, y )
	return x > self.minX and y > self.minY and x < self.maxX and y < self.maxY
end

function Clickable:setAnim(name,continue) -- Go to specified animation and reset, if not already there
	-- this only needs to be done for the normal buttons, which only have a single visualizer:
	if self.vis and #self.vis == 1 and self.vis[1].animation ~= name then
		self.vis[1].animation = name
		if not continue then
			self.vis[1]:reset()
		end
	end
end


return Clickable
