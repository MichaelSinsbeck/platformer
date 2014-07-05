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

function Clickable:new( x, y, event, imgOff, imgOn, imgHover, toolTip, shortcut, useMesh )
	local o = {}
	setmetatable(o, self)

	o.imgOff = imgOff
	o.imgOn = imgOn
	o.imgHover = imgHover or imgOn
	o.centered = centered
	o.toolTip = toolTip  or ""
	o.shortcut = shortcut
	o.shortcutText = nameForKey(shortcut)
	o.hasHighligh = true

	-- Add visualizer
	o.vis = {}
	o.vis[1] = Visualizer:New(imgOff)
	o.vis[1]:init()
	if useMesh then
		o.vis[1]:useMesh()
	end
	o.width, o.height = o.vis[1]:getSize()

	o.x = x or 0
	o.y = y or 0

	-- for collision checking:
	o.minX = x*Camera.scale - 0.5 * o.width
	o.minY = y*Camera.scale - 0.5 * o.height
	o.maxX = o.minX + o.width
	o.maxY = o.minY + o.height

	if o.shortcut then
		local sizeX = fontSmall:getWidth( o.shortcutText:sub(1,3) ) + 6
		local sizeY = fontSmall:getHeight() + 2
		local offsetX = o.width*0.5 - sizeX
		local offsetY = o.height*0.5 - sizeY
		o.offsetX = offsetX + 3
		o.offsetY = offsetY + 5

		o.shortcutBox = {
			offsetX -1 + math.random()*2, offsetY + math.random()*2,
			offsetX -1 + math.random()*2 + sizeX, offsetY + math.random()*2,
			offsetX -1 + math.random()*2 + sizeX, offsetY + math.random()*2 + sizeY,
			offsetX -1 + math.random()*2, offsetY + math.random()*2 + sizeY,
		}
	end

	o.event = event

	o.active = false
	o.highlighted = false

	return o
end

function Clickable:newFromObject( x, y, event, obj, toolTip, centered )
	local o = {}
	setmetatable(o, self)
	
	o.centered = centered
	o.toolTip = toolTip  or ""
	o.hasHighligh = false

	-- Add visualizer
	o.vis = {}
	if obj.preview then
		o.vis[1] = obj.preview:copy()
	else
		for k,v in ipairs(obj.vis) do
			o.vis[k] = v:copy()
		end	
	end
	
	o.obj = obj
	o.width, o.height = obj:getPreviewSize()

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

	o.active = false
	o.highlighted = false

	return o
end

function Clickable:newLabel( x, y, event, width, text, font )
	local o = {}
	o.__index = Clickable
	setmetatable( o, Clickable )

	o.font = font or fontSmall
	o.width = width and width*Camera.scale or o.font:getWidth( text ) + PADDING*2
	o.height = o.font:getHeight() + PADDING*2
	o.text = text

	o.x = x or 0
	o.y = y or 0
	o.textX = o.x*Camera.scale + PADDING
	o.textY = o.y*Camera.scale + PADDING

	o.minX = x*Camera.scale
	o.minY = y*Camera.scale
	o.maxX = o.minX + o.width
	o.maxY = o.minY + o.height

	o.event = event

	o.active = false
	o.highlighted = false

	return o
end

function Clickable:newBatch( x, y, event, obj, width, height, toolTip )
	local o = {}
	setmetatable(o, self)

	o.obj = obj

	o.batch = obj.batch

	o.toolTip = toolTip  or ""

	-- react when mouse is in the area:
	o.width, o.height = width*Camera.scale, height*Camera.scale
	
	o.x = x or 0
	o.y = y or 0

	-- for collision checking:
	o.minX = x*Camera.scale
	o.minY = y*Camera.scale
	o.maxX = o.minX + o.width
	o.maxY = o.minY + o.height

 	o.event = event

	o.active = false
	o.highlighted = false

	return o
end

function Clickable:draw()
	love.graphics.setColor(255,255,255,255)
	if self.vis then
		local iW, iH = AnimationDB.image.highlight:getWidth(), AnimationDB.image.highlight:getHeight()
		local dX, dY = (self.width-iW)*0.5, (self.height-iH)*0.5
		for k = 1, #self.vis do
			self.vis[k]:draw(self.x*Camera.scale,self.y*Camera.scale)
		end

	elseif self.batch then
		love.graphics.draw( self.batch, self.x*Camera.scale, self.y*Camera.scale )
		love.graphics.setColor(50,50,50)
		love.graphics.setLineWidth(1)
		love.graphics.rectangle("line", self.minX+.5, self.minY+.5, self.maxX - self.minX, self.maxY-self.minY)
		
	elseif self.text then
		if self.highlighted then
			love.graphics.setColor( 255, 255, 255, 60 )
		else
			love.graphics.setColor( 255, 255, 255, 20 )
		end
		love.graphics.rectangle( 'fill', self.x*Camera.scale, self.y*Camera.scale, self.width, self.height )
		love.graphics.setColor(255,255,255)
		love.graphics.print( self.text, self.textX, self.textY )
	end
	if self.shortcutBox then
		local shortcut = self.shortcutText
		if #shortcut > 3 then
			shortcut = shortcut:sub(1,3)
		end
		love.graphics.push()
		love.graphics.setLineWidth(2)	
		love.graphics.translate( self.x*Camera.scale, (self.y+1)*Camera.scale )
		love.graphics.setColor(180,255,180,160)
		love.graphics.polygon( 'fill', self.shortcutBox )
		love.graphics.setColor(0,0,0,255)
		love.graphics.polygon( 'line', self.shortcutBox )
		--love.graphics.setColor(255,255,255,255)
		love.graphics.print( shortcut, self.offsetX, self.offsetY )
		love.graphics.pop()
	end
	--love.graphics.rectangle( 'line', self.minX, self.minY, self.width, self.height )
end

function Clickable:drawPreviewOutline()
	if self.selectionPreview then
		love.graphics.setColor(255,255,200, 75)
		love.graphics.setLineWidth(3)	
		love.graphics.rectangle("fill", self.minX, self.minY, self.maxX - self.minX, self.maxY-self.minY)
	end
end
function Clickable:drawOutline()
	if self.selected or (self.vis and DEBUG) then
		love.graphics.setColor(140,255,140,100)
		love.graphics.setLineWidth(2)	
		love.graphics.rectangle("fill", self.minX, self.minY, self.maxX - self.minX, self.maxY-self.minY)
	end
end

function Clickable:click( mouseX, mouseY, clicked, msgBoxActive )
	if msgBoxActive then
		if self.imgOff then
			self:setAnim(self.imgOff)
		end
	else
		if self:collisionCheck( mouseX, mouseY ) then
			editor.setToolTip( self.toolTip )
			if clicked then
				-- new click?
				--if self.active ~= "click" then
					--self:setSelected( true )	-- IMPORTANT! set to selected before running event!
					-- if new click, run the event:
					if self.event then
						self.event()
					end

					--[[if self.imgOn then
						self:setAnim(self.imgOn)
					end]]
				--end
			else
				--[[self.active = "hover"
				if self.imgHover then
					self:setAnim(self.imgHover)
				end]]
			end
			return true
		else
			--[[if self.imgOff then
				self:setAnim(self.imgOff)
			end]]
		end
	end

	return false
end

function Clickable:highlight()
	if self.imgHover then
		self:setAnim(self.imgHover)
	end
	if self.toolTip then
		editor.setToolTip(self.toolTip)
	end
	self.highlighted = true
end

function Clickable:unhighlight()
	if self.active == true and self.imgOn then
		self:setAnim(self.imgOn)
	elseif self.imgOff then
		self:setAnim(self.imgOff)
	end
	self.highlighted = false
end

function Clickable:setSelected( bool )
	self.selected = bool
	if self.selected and self.imgHover then
		self:setAnim(self.imgHover)
	else
		if self.active == true and self.imgOn then
			self:setAnim(self.imgOn)
		elseif self.imgOff then
			self:setAnim(self.imgOff)
		end
	end
end

function Clickable:setSelectionPreview( bool )
	self.selectionPreview = bool
end


function Clickable:collisionCheck( x, y )
	return x > self.minX and y > self.minY and x < self.maxX and y < self.maxY
end

function Clickable:setAnim(name,continue) -- Go to specified animation and reset, if not already there
	-- this only needs to be done for the normal buttons, which only have a single visualizer:
	if self.vis and self.vis[1].animation ~= name then
		self.vis[1].animation = name
		if not continue then
			self.vis[1]:reset()
		end
	end
end

function Clickable:setActive( bool )
	if self.active ~= bool then
		self.active = bool
		if self.active then
			if self.imgOn then
				self:setAnim(self.imgOn)
			end
		else
			if self.imgOff then
				self:setAnim(self.imgOff)
			end
		end
	end
end

return Clickable
