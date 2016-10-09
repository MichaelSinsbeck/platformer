local Clickable = require("editor/clickable")
local Panel = {}
Panel.__index = Panel
local backgroundColor = {44,90,160,150} -- color of box content
local PADDING = 3

-- chars which, by default, can by typed into input boxes:
local ALLOWED_CHARS = "[0-9a-zA-Z%- ?!%.,%+%%%'%_]"

function Panel:new( x, y, width, height )-- highlightSelected )
	local o = {}
	setmetatable(o, self)

	o.x = x or 0
	o.y = y or 0
	o.width = width or 32
	o.height = height or 32
	o.width = math.ceil(o.width/16)*16
	o.height = math.ceil(o.height/16)*16

	-- store whether or not the selected buttons of this panel should be highlighted:
	--o.highlightSelected = highlightSelected
	
	-- page[0] always gets drawn!
	-- Other pages only if selectedPage is set correctly.
	o.pages = {}
	o.pages[0] = {}
	o.selectedPage = 1

	o.labels = {}
	o.properties = {}
	o.inputBoxes = {}

	o.visualizers = {}

	o.visible = true

	if o.width > 0 and o.height > 0 then
		o.box = BambooBox:new( "", width, height )
	end

	o.timer = 0

	return o
end

function Panel:addLabel( x, y, text, page )
	local l = {
		x = x+self.x,
		y = y+self.y,
		--text = string.lower(text),
		text = text
	}
	page = page or 0
	if not self.labels[page] then self.labels[page] = {} end
	table.insert( self.labels[page], l )
end

function Panel:goToNextPage()
	if self.pages[self.selectedPage + 1] then
		self.selectedPage = self.selectedPage + 1
	end
end
function Panel:goToPrevPage()
	if self.selectedPage > 1 and self.pages[self.selectedPage - 1] then
		self.selectedPage = self.selectedPage - 1
	end
end
function Panel:goToPage( num )
	if self.pages[num] then
		self.selectedPage = num
	end
end

function Panel:addNextButton( pageNumber )
	local ev = function()
		self:goToPage( pageNumber + 1 )
	end
	local c = Clickable:new( self.x + self.width - 12, self.y + self.height - 9, ev,
			'LERight',
			"Go to next page", "right", true )
	table.insert( self.pages[pageNumber], c )
end

function Panel:addPrevButton( pageNumber )
	local ev = function()
		self:goToPage( pageNumber - 1 )
	end
	local c = Clickable:new( self.x + 12, self.y + self.height - 9, ev,
			'LELeft',
			"Go to previous page", "left", true )
	table.insert( self.pages[pageNumber], c )
end

function Panel:addPageButtons( page )
	if self.pages[page-1] and page > 1 then
		self:addNextButton( page-1 )
		self:addPrevButton( page )
	end
	if self.pages[page+1] then
		self:addNextButton( page )
		self:addPrevButton( page+1 )
	end
end

function Panel:addClickableLabel( x, y, event, width, text, page )
	local c = Clickable:newLabel( x+self.x, y+self.y, event, width, text )
	page = page or 0
	if not self.pages[page] then
		self.pages[page] = {}
		-- Add buttons to next and previous pages:
		self:addPageButtons( page )
	end
	table.insert( self.pages[page], c )
	return c
end

function Panel:addClickable( x, y, event, img, toolTip, page, shortcut, useMesh,
	tag )
	local c = Clickable:new( x+self.x, y+self.y, event,
					img, toolTip, shortcut, useMesh, tag )
	page = page or 0
	if not self.pages[page] then
		self.pages[page] = {}
		-- Add buttons to next and previous pages:
		self:addPageButtons( page )
	end
	table.insert( self.pages[page], c )
	return c
end

function Panel:addClickableObject( x, y, event, obj, toolTip, page )
	local c = Clickable:newFromObject( x+self.x, y+self.y, event, obj, toolTip )
	page = page or 0
	if not self.pages[page] then
		self.pages[page] = {}
		-- Add buttons to next and previous pages:
		self:addPageButtons( page )
	end
	table.insert( self.pages[page], c )
	return c
end

function Panel:addBatchClickable( x, y, event, obj, width, height, toolTip, page )
	local c = Clickable:newBatch( x+self.x, y+self.y, event, obj, width, height, toolTip )
	page = page or 0
	if not self.pages[page] then
		self.pages[page] = {}
		-- Add buttons to next and previous pages:
		self:addPageButtons( page )
	end
	table.insert( self.pages[page], c )
	return c
end

function Panel:addVisualizer( x, y, name )
	local new = Visualizer:New(name)
	new:init()
	table.insert( self.visualizers, {vis = new, x=x+self.x, y=y+self.y} )
end

function Panel:clearAll()
	self.pages = {}
	self.pages[0] = {}
	self.selectedPage = 1

	self.labels = {}
	self.properties = {}

	self.inputBoxes = {}

	self.visualizers = {}
end

function Panel:draw()

	love.graphics.setColor(255,255,255,255)
	if self.box then
		self.box:draw( self.x, self.y )
		--[[love.graphics.push()
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

		love.graphics.pop()]]--
	end

	love.graphics.setColor(255,255,255,255)

	if self.labels[0] then
		for i, label in ipairs( self.labels[0] ) do
			love.graphics.print( label.text, label.x*Camera.scale, label.y*Camera.scale )
		end
	end
	if self.labels[self.selectedPage] then
		for i, label in ipairs( self.labels[self.selectedPage] ) do
			love.graphics.print( label.text, label.x*Camera.scale, label.y*Camera.scale )
		end
	end
	for k, p in pairs( self.properties ) do
		if not p.isTextProperty and not p.isNumericTextProperty then
			love.graphics.setColor(255,255,255,20)
			love.graphics.rectangle("fill", (p.x+3)*Camera.scale, (p.y+5)*Camera.scale,
			25*Camera.scale, 4*Camera.scale)
			love.graphics.setColor(255,255,255,255)

			local displayName = p.names[p.obj[k]] or p.obj[k]
			love.graphics.print( displayName, (p.x+7)*Camera.scale, (p.y+5)*Camera.scale )
		end
		love.graphics.print( k  .. ':', p.x*Camera.scale, p.y*Camera.scale )
	end

	for k, input in ipairs( self.inputBoxes ) do
		if input == self.activeInput then
			local cX = input.x*Camera.scale + input.curX
			local cY = input.y*Camera.scale + input.curY
			love.graphics.line( cX, cY - fontSmall:getHeight(), cX, cY )
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

	for k, vis in pairs( self.visualizers ) do
		vis.vis:draw( vis.x*Camera.scale, vis.y*Camera.scale )
	end

	if self.pages[self.selectedPage] then
		for k, button in ipairs( self.pages[self.selectedPage] ) do
			button:draw()
		end
		for k, button in ipairs( self.pages[self.selectedPage] ) do
			button:drawOutline()
		end		
		-- draw preview outline ontop of already selected outline:
		for k, button in ipairs( self.pages[self.selectedPage] ) do
			button:drawPreviewOutline()
		end		
	end
	love.graphics.setColor(255,255,255,255)
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
	self.timer = self.timer + dt
	for k, page in pairs(self.pages) do
		for i, button in pairs(page) do
			if button.vis then
				for k = 1, #button.vis do
					button.vis[k]:update( dt )
				end
			end
		end
	end
	for k, vis in pairs( self.visualizers ) do
		vis.vis:update( dt )
	end
	--[[if self.box then
		self.box:update( dt )
	end]]
end

-- Removes the "selection preview" box from all buttons:
function Panel:unPreviewAll()
	for i, page in pairs( self.pages ) do
		for k, button in ipairs( page ) do
			button:setSelectionPreview(false)
		end
	end
end

function Panel:deactivateAll()
	for i, page in pairs( self.pages ) do
		for k, button in ipairs( page ) do
			button:setActive(false)
		end
	end
end

function Panel:deactivateInput()
	if self.activeInput then
		self.activeInput.txt = self.activeInput.front .. self.activeInput.back
		if self.activeInput.returnEvent then
			self.activeInput.returnEvent( self.activeInput )
		end
		self.activeInput = nil
	end
	if editor.activeInputPanel == self then
		editor.activeInputPanel = nil
	end
end
function Panel:getActiveInput()
	return self.activeInput
end

function Panel:click( mouseX, mouseY, clicked, msgBoxActive )
	if clicked then
		if self.activeInput then
			self.activeInput.txt = self.activeInput.front .. self.activeInput.back
			if self.activeInput.returnEvent then
				self.activeInput.returnEvent( self.activeInput )
			end
			self.activeInput = nil
		end
		editor.activeInputPanel = nil
	end

	-- this gets set to true if the click hit a clickable on this panel:
	local hitButton = false
	local hit
	local wasSelected

	for i, pageNum in pairs( {0, self.selectedPage } ) do
		if self.pages[pageNum] then
			for k,button in ipairs( self.pages[pageNum] ) do
				wasSelected = button.selected
				--if not addToSelection then
					--button:setSelected( false )
				--end
				hit = button:click( mouseX, mouseY, clicked, msgBoxActive )
				if hit then
					--[[if self.highlightSelected then
					self:disselectAll()
					button:setSelected(true)
					end]]
					-- clicking a selected button removes the selection:
					--if addToSelection and wasSelected then
					--	button:setSelected( false )
					--end
					hitButton = true
				end
			end
		end
	end

	--[[if self.pages[self.selectedPage] then
	for k,button in ipairs( self.pages[self.selectedPage] ) do
	wasSelected = button.selected
	if not addToSelection then
	button:setSelected( false )
	end
			hit = button:click( mouseX, mouseY, clicked, msgBoxActive )
			if hit then
				if addToSelection and wasSelected then
					button:setSelected( false )
				end
				hitButton = true
			end
		end
	end]]
	
	if not hitButton and clicked then
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

--[[function Panel:addToSelectionClick( x, y, button )
	self:click( x, y, button, nil, true )
end]]

-- used in box select:
function Panel:addToSelectionClick( x, y, shiftPressed )
	for i, pageNum in pairs( {0, self.selectedPage} ) do
		if self.pages[pageNum] then
			for k,button in ipairs( self.pages[pageNum] ) do
				hit = button:collisionCheck( x, y )
				if hit then
					--if button.event then
					--		button.event()
					--	end
					return button
				end
			end
		end
	end
end

function Panel:getSelected()
	local sel = {}
	for k, b in pairs(self.pages[0]) do
		if b.selected then table.insert( sel, b ) end
	end
	for k, b in pairs(self.pages[self.selectedPage]) do
		if b.selected then table.insert( sel, b ) end
	end
	return sel
end

function Panel:collisionCheck( x, y )
	--[[return x/Camera.scale > self.x and
	y/Camera.scale > self.y and
	x/Camera.scale < self.x + self.width and
					y/Camera.scale < self.y + self.height]]
	if self.box then
		local hit = self.box:collisionCheck( x-self.x*Camera.scale, y-self.y*Camera.scale )
		if hit then
			for i, pageNum in pairs( {0, self.selectedPage } ) do
				if self.pages[pageNum] then
					for k,button in ipairs( self.pages[pageNum] ) do
						if button:collisionCheck( x, y ) then
							button:highlight()
						end
					end
				end
			end
		end
		return hit
	end
	return false
end

function Panel:unhighlightAll( )
	for i, pageNum in pairs( {0, self.selectedPage } ) do
		if self.pages[pageNum] then
			for k,button in ipairs( self.pages[pageNum] ) do
				button:unhighlight()
			end
		end
	end
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
	
	if property.isTextProperty then

		local returnEvent = function( input )
			property.values[1] = input.txt
			obj:setProperty( name, property.values[1] ) 
			obj:applyOptions()
		end

		self:addInputBox( x + 1, y + 5, self.width-18, 5, obj[name],--property.values[1],
				--returnEvent, 200, "[0-9a-zA-Z%- ?!%.,:;%+%%_'=%(%)#<>%*~§$&/\"{}%[%]]" )
				returnEvent, 200, "[0-9a-zA-Z%- ?!%.,:;%+%%_'=%(%)#<>%*~&$/\"{}%[%]]" )
				--returnEvent, 200, "[0-9a-zA-Z%- ?!%.,&\"]" )
				--returnEvent, 200, "[0-9a-zA-Z%- ?!%.,%+%%_'#:;=%(%)[]<>/&$§]" )

	elseif property.isNumericTextProperty then

		local returnEvent = function( input )
			local num = tonumber(input.txt)
			if num then
				num = math.min( property.max, num )
				num = math.max( property.min, num )
				property.values[1] = num
			end
			input.txt = tostring(property.values[1])
			input.front = input.txt
			input.back = ""
			obj:setProperty( name, property.values[1] ) 
			obj:applyOptions()
			print("applied:" .. property.values[1])
		end

		self:addInputBox( x + 1, y + 5, self.width-18, 1, tostring(obj[name]),
				returnEvent, 200, "[%-%+0-9%.e]" )

	else

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

		self:addClickable( x + 3, y + 7, decrease,
		'LEUp',
		"Choose next value", nil,nil, true)

		self:addClickable( x + 25, y + 7, increase,
		'LEDown',
		"Choose next value", nil,nil, true)
	end

	property.x = x + self.x
	property.y = y + self.y
	property.obj = obj
	self.properties[ name ] = property
end

function Panel:addInputBox( x, y, width, lines, txt, returnEvent, maxLetters, allowedChars )
	local wrappedText, curX, curY = utility.wrap( txt or "", "", width*Camera.scale )
	local new = {
		x = x + self.x,
		y = y + self.y,
		width = width,
		pixelWidth = width*Camera.scale,
		height = lines*fontSmall:getHeight()/Camera.scale,
		txt = txt or "",
		front = txt or "",
		back = "",
		lines = lines,
		wrappedText = wrappedText,
		curX = curX,
		curY = curY,
		maxLetters = maxLetters or math.huge,
		returnEvent = returnEvent,
		allowedChars = allowedChars,
	}
	table.insert( self.inputBoxes, new )
end

-- Add the letter to the currently active text.
function Panel:textinput( letter )
	if self.activeInput then
		local inp = self.activeInput
		if letter:find( inp.allowedChars or ALLOWED_CHARS ) then
			--letter = string.lower(letter)
			if inp.maxLetters > #inp.txt then
				local prevFront, prevWrapped = inp.front, inp.wrappedText
				local prevX, prevY = inp.curX, inp.curY
				inp.front = inp.front .. letter
				inp.wrappedText,inp.curX,inp.curY =
				utility.wrap( inp.front, inp.back, inp.pixelWidth )

				-- Don't allow more than 'lines' lines. If number is greater with the newly added char,
				-- reset to previous.
				if #inp.wrappedText > inp.lines then
					inp.front = prevFront
					inp.wrappedText = prevWrapped
					inp.curX, inp.curY = prevX, prevY
				end
			end
		end
	end
end

function Panel:keypressed( key )
	if self.activeInput then
		local inp = self.activeInput
		-- back up text incase anything goes wrong:
		inp.oldFront, inp.oldBack = inp.front, inp.back
		local stop, jump

		if key == "backspace" then
			local len = #inp.front
			if len > 0 then
				inp.front = inp.front:sub(1, len-1)
			end
			inp.wrappedText,inp.curX,inp.curY = utility.wrap( inp.front, inp.back, inp.pixelWidth )
		elseif key == "escape" then
			inp.front = inp.txt
			inp.back = ""
			stop = true
			inp.wrappedText,inp.curX,inp.curY = utility.wrap( inp.front, inp.back, inp.pixelWidth )
		elseif key == "return" then
			inp.txt = inp.front .. inp.back
			stop = true
			if inp.returnEvent then
				inp.returnEvent( inp )
			end
			inp.wrappedText,inp.curX,inp.curY = utility.wrap( inp.front, inp.back, inp.pixelWidth )
		elseif key == "left" then
			local len = #inp.front

			if len > 0 then
				inp.back = inp.front:sub( len,len ) .. inp.back
				inp.front = inp.front:sub(1, len-1)
			end
			inp.wrappedText,inp.curX,inp.curY = utility.wrap( inp.front, inp.back, inp.pixelWidth )
		elseif key == "right" then
			local len = #inp.back
			if len > 0 then
				inp.front = inp.front .. inp.back:sub(1,1)
				inp.back = inp.back:sub(2,len)
			end
			inp.wrappedText,inp.curX,inp.curY = utility.wrap( inp.front, inp.back, inp.pixelWidth )
		elseif key == "delete" then
			local len = #inp.back
			if len > 0 then
				inp.back = inp.back:sub(2,len)
			end
			inp.wrappedText,inp.curX,inp.curY = utility.wrap( inp.front, inp.back, inp.pixelWidth )
		elseif key == "home" then
			inp.back = inp.front .. inp.back
			inp.front = ""
			inp.wrappedText,inp.curX,inp.curY = utility.wrap( inp.front, inp.back, inp.pixelWidth )
		elseif key == "end" then
			inp.front = inp.front .. inp.back
			inp.back = ""
			inp.wrappedText,inp.curX,inp.curY = utility.wrap( inp.front, inp.back, inp.pixelWidth )
		elseif key == "tab" then
			inp.txt = inp.front .. inp.back
			--[[if love.keyboard.isDown("lshift", "rshift") then
			jump = "backward"
			else
			jump = "forward"
			end]]
			stop = true
			if inp.returnEvent then
				inp.returnEvent( inp )
			end
			inp.wrappedText,inp.curX,inp.curY = utility.wrap( inp.front, inp.back, inp.pixelWidth )
		end
	
		if stop then
			self.activeInput = nil
			editor.activeInputPanel = nil
			return "stop"
		elseif jump then
			self.activeInput = nil
			editor.activeInputPanel = nil
			return jump
		end
	end
end


return Panel
