local Panel = {}
Panel.__index = Panel
local backgroundColor = {44,90,160,150} -- color of box content
local PADDING = 3

function Panel:new( x, y, width, height, highlightSelected )
	local o = {}
	setmetatable(o, self)

	o.x = x or 0
	o.y = y or 0
	o.width = width or 100
	o.height = height or 100

	-- store whether or not the selected buttons of this panel should be highlighted:
	o.highlightSelected = highlightSelected
	
	-- page[0] always gets drawn!
	-- Other pages only if selectedPage is set correctly.
	o.pages = {}
	o.pages[0] = {}
	o.selectedPage = 1

	o.labels = {}
	o.properties = {}

	o.visible = true

	if o.width > 0 and o.height > 0 then
		o.box = menu:generateBox( 0, 0, o.width, o.height, boxFactor)
	end

	return o
end

function Panel:addLabel( x, y, text )
	local l = {
		x = x,
		y = y,
		text = text,
	}
	table.insert( self.labels, l )
end

function Panel:addClickable( x, y, event, imgOff, imgOn, imgHover, toolTip, page, centered )
	local c = Clickable:new( x+self.x, y+self.y, event, imgOff, imgOn, imgHover, toolTip, centered )
	page = page or 0
	if not self.pages[page] then
		self.pages[page] = {}
	end
	table.insert( self.pages[page], c )
end

function Panel:addClickableObject( x, y, event, obj, toolTip, page, centered )
	local c = Clickable:newFromObject( x+self.x, y+self.y, event, obj, toolTip, centered )
	page = page or 0
	if not self.pages[page] then
		self.pages[page] = {}
	end
	table.insert( self.pages[page], c )
end

function Panel:addBatchClickable( x, y, event, batch, width, height, toolTip, page, centered )
	local c = Clickable:newBatch( x+self.x, y+self.y, event, batch, width, height, toolTip, centered )
	page = page or 0
	if not self.pages[page] then
		self.pages[page] = {}
	end
	table.insert( self.pages[page], c )
end

function Panel:clearClickables()
	self.pages = {}
	self.pages[0] = {}
	self.selectedPage = 1

	self.labels = {}
	self.properties = {}
end

function Panel:draw()

	if self.box then
		love.graphics.push()
		love.graphics.translate( self.x*Camera.scale, self.y*Camera.scale )
		-- draw the background box:
		-- scale box coordinates according to scale
		local scaled = {}
		for i = 1,#self.box.points do
			scaled[i] = self.box.points[i] * Camera.scale
		end
		-- draw
		love.graphics.setColor( backgroundColor )
		love.graphics.setLineWidth(Camera.scale*0.5)
		love.graphics.rectangle('fill',
		self.box.left*Camera.scale,
		self.box.top*Camera.scale,
		self.box.width*Camera.scale,
		self.box.height*Camera.scale)
		love.graphics.setColor(0,0,0)
		love.graphics.line(scaled)

		love.graphics.pop()
	end

	love.graphics.setColor(255,255,255,255)

	for k, label in ipairs( self.labels ) do
		love.graphics.print( label.name, label.x*Camera.scale, label.y*Camera.scale )
	end
	for k, p in pairs( self.properties ) do
		love.graphics.print( k  .. ':', p.x*Camera.scale, p.y*Camera.scale )
		local displayName = p.names[p.obj[k]] or p.obj[k]
		love.graphics.print( displayName, (p.x+6)*Camera.scale, (p.y+6)*Camera.scale )
	end
	for k, button in ipairs( self.pages[0] ) do
		button:draw()
	end

	if self.pages[self.selectedPage] then
		for k, button in ipairs( self.pages[self.selectedPage] ) do
			button:draw()
		end
	end
end

function Panel:moveTo( x, y )
	local ox, oy = self.x - x, self.y - y
	for i, page in pairs( self.pages ) do
		for k, button in ipairs( page ) do
			button.x = button.x - ox
			button.y = button.y - oy
			-- for collision checking:
			button.minX = button.x*Camera.scale - 0.5 * button.width
			button.minY = button.y*Camera.scale - 0.5 * button.height
			button.maxX = button.minX + button.width
			button.maxY = button.minY + button.height
		end
	end
	self.x, self.y = x,y

end

function Panel:update( dt )
	for k, page in pairs(self.pages) do
		for i, button in pairs(page) do
			if button.vis then
				for k = 1, #button.vis do
					button.vis[k]:update( dt )
				end
			end
		end
	end
end

function Panel:click( mouseX, mouseY, clicked )

	-- this gets set to true if the click hit a clickable on this panel:
	local hitButton = false
	local hit
	for k,button in ipairs( self.pages[0] ) do
		hit = button:click( mouseX, mouseY, clicked )
		if hit then
			if self.highlightSelected then
				self:disselectAll()
				button:setSelected(true)
			end
			hitButton = true
		end
	end
	
	if self.pages[self.selectedPage] then
		for k,button in ipairs( self.pages[self.selectedPage] ) do
			hit = button:click( mouseX, mouseY, clicked )
			if hit then
				if self.highlightSelected then
					self:disselectAll()
					button:setSelected(true)
				end
				hitButton = true
			end
		end
	end

	return hitButton
end

function Panel:collisionCheck( x, y )
	return x/Camera.scale > self.x and
	y/Camera.scale > self.y and
	x/Camera.scale < self.x + self.width and
					y/Camera.scale < self.y + self.height
end

function Panel:disselectAll()
	for k, p in pairs(self.pages) do
		for i,button in pairs(p) do
			button:setSelected( false )
		end
	end
end

function Panel:addProperty( name, x, y, property, obj, cycle )
	
	--self:addLabel( self.x + x, self.y + y, name .. ":" )

	-- since the properties are copied by reference,
	-- changing them here will change them for the object, too:
	function decrease()
		-- find current index
		local current = 1
		for i,v in ipairs(property.values) do
			if tostring(v) == tostring(obj[name]) then
				current = i
				break
			end
		end
		-- decrease value and cycle/clamp
		current = current -1
		if current < 1 then
			if property.cycle then
				current = #property.values
			else
				current = 1
			end
		end
		obj:setProperty( name, property.values[current] ) 
		obj:applyOptions()
	end
	function increase()
		-- find current index
		local current = 1
		for i,v in ipairs(property.values) do
			if tostring(v) == tostring(obj[name]) then
				current = i
				break
			end
		end
		current = current + 1
		if current > #property.values then
			if property.cycle then
				current = 1
			else
				current = #property.values
			end		
		end
		obj:setProperty( name, property.values[current] ) 
		obj:applyOptions()
	end

	self:addClickable( x + 1, y + 8, decrease,
		'LEUpOff',
		'LEUpOn',
		'LEUpHover',
		"Choose next value")

	self:addClickable( x + 30, y + 8, increase,
		'LEDownOff',
		'LEDownOn',
		'LEDownHover',
		"Choose next value")
	
	property.x = x + self.x
	property.y = y + self.y
	property.obj = obj
	self.properties[ name ] = property
end

return Panel
