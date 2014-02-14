local Panel = {}
Panel.__index = Panel
local backgroundColor = {44,90,160,150} -- color of box content
local PADDING = 3

local ALLOWED_CHARS = "[0-9a-zA-Z\n ?!%.]"

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
	o.inputBoxes = {}

	o.visible = true

	if o.width > 0 and o.height > 0 then
		o.box = menu:generateBox( 0, 0, o.width, o.height, boxFactor)
	end

	return o
end

function Panel:addLabel( x, y, text )
	local l = {
		x = x+self.x,
		y = y+self.y,
		text = string.lower(text),
	}
	table.insert( self.labels, l )
end

function Panel:addClickableLabel( x, y, event, width, text, page )
	local c = Clickable:newLabel( x+self.x, y+self.y, event, width, text )
	page = page or 0
	if not self.pages[page] then
		self.pages[page] = {}
	end
	table.insert( self.pages[page], c )
end

function Panel:addClickable( x, y, event, imgOff, imgOn, imgHover, toolTip, page, centered, shortcut, useMesh)
	local c = Clickable:new( x+self.x, y+self.y, event,
						imgOff, imgOn, imgHover, toolTip, centered, shortcut, useMesh )
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

function Panel:clearAll()
	self.pages = {}
	self.pages[0] = {}
	self.selectedPage = 1

	self.labels = {}
	self.properties = {}

	self.inputBoxes = {}
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
		love.graphics.print( label.text, label.x*Camera.scale, label.y*Camera.scale )
	end
	for k, p in pairs( self.properties ) do

		love.graphics.setColor(255,255,255,20)
		love.graphics.rectangle("fill", (p.x+3)*Camera.scale, (p.y+5)*Camera.scale,
						25*Camera.scale, 4*Camera.scale)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print( k  .. ':', p.x*Camera.scale, p.y*Camera.scale )
		local displayName = p.names[p.obj[k]] or p.obj[k]
		love.graphics.print( displayName, (p.x+6)*Camera.scale, (p.y+5)*Camera.scale )
	end

	for k, input in ipairs( self.inputBoxes ) do
		if input == self.activeInput then
			love.graphics.setColor(255,255,255,50)
		else
			love.graphics.setColor(255,255,255,20)
		end
		love.graphics.rectangle("fill", input.x*Camera.scale, input.y*Camera.scale,
									input.width*Camera.scale, input.height*Camera.scale )
		love.graphics.setColor(255,255,255,255)
		--love.graphics.printf( input.front .. input.back, input.x*Camera.scale, input.y*Camera.scale,
		--							input.width*Camera.scale )
		for k2, l in ipairs( input.wrappedText ) do
			if k2 > input.lines then break end

			love.graphics.print(l, input.x*Camera.scale,
								input.y*Camera.scale + (k2-1)*fontSmall:getHeight() )
		end
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

function Panel:click( mouseX, mouseY, clicked, msgBoxActive )

	-- this gets set to true if the click hit a clickable on this panel:
	local hitButton = false
	local hit
	for k,button in ipairs( self.pages[0] ) do
		hit = button:click( mouseX, mouseY, clicked, msgBoxActive )
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
			hit = button:click( mouseX, mouseY, clicked, msgBoxActive )
			if hit then
				if self.highlightSelected then
					self:disselectAll()
					button:setSelected(true)
				end
				hitButton = true
			end
		end
	end

	if not hitButton and clicked then
		self.activeInput = nil
		editor.activeInputPanel = nil
		local x, y = mouseX/Camera.scale, mouseY/Camera.scale
		for k, input in ipairs( self.inputBoxes ) do
			if input.x < x and input.y < y and
				input.x + input.width > x and input.y + input.height > y then
				self.activeInput = input
				editor.activeInputPanel = self
				hitButton = true
				break
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

	self:addClickable( x + 1, y + 7, decrease,
		'LEUpOff',
		'LEUpOn',
		'LEUpHover',
		"Choose next value", nil,nil, nil, true)

	self:addClickable( x + 30, y + 7, increase,
		'LEDownOff',
		'LEDownOn',
		'LEDownHover',
		"Choose next value", nil,nil, nil, true)
	
	property.x = x + self.x
	property.y = y + self.y
	property.obj = obj
	self.properties[ name ] = property
end

function Panel:addInputBox( x, y, width, lines, txt, returnEvent, maxLetters )
	local new = {
		x = x + self.x,
		y = y + self.y,
		width = width,
		pixelWidth = width*Camera.scale,
		height = lines*fontSmall:getHeight()/Camera.scale,
		txt = txt or "",
		front = txt or "",
		back = "",
		wrappedText = wrap( txt or "", width*Camera.scale ),
		lines = lines,
		maxLetters = maxLetters or math.huge,
		returnEvent = returnEvent,
	}
	table.insert( self.inputBoxes, new )
end

-- Add the letter to the currently active text.
function Panel:textinput( letter )
	if letter:find( ALLOWED_CHARS ) then
	letter = string.lower(letter)
	if self.activeInput then
		if self.activeInput.maxLetters > #self.activeInput.txt then
			local prevFront, prevWrapped = self.activeInput.front, self.activeInput.wrappedText
			self.activeInput.front = self.activeInput.front .. letter
			self.activeInput.wrappedText =
					wrap( self.activeInput.front .. self.activeInput.back,
					self.activeInput.pixelWidth )

			-- Don't allow more than 'lines' lines. If number is greater with the newly added char,
			-- reset to previous.
			if #self.activeInput.wrappedText > self.activeInput.lines then
				self.activeInput.front = prevFront
				self.activeInput.wrappedText = prevWrapped
			end
		end
	end
	end
end

function Panel:keypressed( key )

	if self.activeInput then
		inp = self.activeInput
		-- back up text incase anything goes wrong:
		inp.oldFront, inp.oldBack = inp.front, inp.back
		local stop, jump

		if key == "backspace" then
			local len = #inp.front
			if len > 0 then
				inp.front = inp.front:sub(1, len-1)
			end
			inp.wrappedText = wrap( inp.front .. inp.back, inp.pixelWidth )
		elseif key == "escape" then
			inp.front = inp.txt
			inp.back = ""
			stop = true
			inp.wrappedText = wrap( inp.front .. inp.back, inp.pixelWidth )
		elseif key == "return" then
			inp.txt = inp.front .. inp.back
			stop = true
			if inp.returnEvent then
				inp.returnEvent( inp.txt )
			end
			inp.wrappedText = wrap( inp.front .. inp.back, inp.pixelWidth )
		elseif key == "left" then
			local len = #inp.front

			if len > 0 then
				inp.back = inp.front:sub( len,len ) .. inp.back
				inp.front = inp.front:sub(1, len-1)
			end
		elseif key == "right" then
			local len = #inp.back
			if len > 0 then
				inp.front = inp.front .. inp.back:sub(1,1)
				inp.back = inp.back:sub(2,len)
			end
		elseif key == "delete" then
			local len = #inp.back
			if len > 0 then
				inp.back = inp.back:sub(2,len)
			end
			inp.wrappedText = wrap( inp.front .. inp.back, inp.pixelWidth )
		elseif key == "home" then
			inp.back = inp.front .. inp.back
			inp.front = ""
		elseif key == "end" then
			inp.front = inp.front .. inp.back
			inp.back = ""
		elseif key == "tab" then
			inp.txt = inp.front .. inp.back
			if love.keyboard.isDown("lshift", "rshift") then
				jump = "backward"
			else
				jump = "forward"
			end
			if inp.returnEvent then
				inp.returnEvent( inp.txt )
			end
			inp.wrappedText = wrap( inp.front .. inp.back, inp.pixelWidth )
		end

		if stop then
			self.activeInputBox = nil
			editor.activeInputPanel = nil
			return "stop"
		elseif jump then
			self.activeInputBox = nil
			editor.activeInputPanel = nil
			return jump
		end
	end
end
function wrap( plain, width )
	local lines = {}
	plain = plain .. "\n"
	for line in plain:gmatch( "([^\n]-\n)" ) do
		table.insert( lines, line )
	end

	local wLines = {}	-- lines that have been wrapped
	local shortLine
	local restLine
	local word = "[^ ]* "	-- not space followed by space
	local tmpLine
	local letter = "[%z\1-\127\194-\244][\128-\191]*"

	for k, line in ipairs(lines) do
		if fontSmall:getWidth( line ) <= width then
			table.insert( wLines, line )
		else
			restLine = line .. " " -- start with full line
			while #restLine > 0 do
				local i = 1
				local breakingCondition = false
				tmpLine = nil
				shortLine = nil
				repeat		-- look for spaces!
					tmpLine = restLine:match( word:rep(i) )
					if tmpLine then
						if fontSmall:getWidth(tmpLine) > width then
							breakingCondition = true
						else
							shortLine = tmpLine
						end
					else
						breakingCondition = true
					end
					i = i + 1
				until breakingCondition
				if not shortLine then -- if there weren't enough spaces then:
					breakingCondition = false
					i = 1
					repeat			-- ... look for letters:
						tmpLine = restLine:match( letter:rep(i) )
						if tmpLine then
							if fontSmall:getWidth(tmpLine) > width then
								breakingCondition = true
							else
								shortLine = tmpLine
							end
						else
							breakingCondition = true
						end
						i = i + 1
					until breakingCondition
				end
				table.insert( wLines, shortLine )
				restLine = restLine:sub( #shortLine+1 )
			end
		end
	end

	local trueWidth = 0
	local w = 0
	for k, l in pairs( wLines ) do
		w = fontSmall:getWidth(l)
		if w > trueWidth then
			trueWidth = w
		end
	end

	return wLines, trueWidth
end
 
function getCharPos( wrappedLines, num )
	local i = 0
	local x, y = 0,0
	for k, l in ipairs( wrappedLines ) do
		if i + #l >= num then
			num = num - i
			x = fontSmall:getWidth( l:sub(1, num) )
			y = k*fontSmall:getHeight()
		else
			i = i + #l
		end
	end
	return x, y
end


return Panel
