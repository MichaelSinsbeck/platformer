-------------------------------------
-- Level-editor main interface:
-------------------------------------
-- load
-- save
-- upload

local editor = {}

Clickable = require("editor/clickable")
Panel = require("editor/panel")
EditorMap = require("editor/editorMap")
Ground = require("editor/ground")
BgObject = require("editor/bgObject")

EditorCam = require("editor/editorCam")

local map = nil
local cam = nil

local bgObjectPanel
local toolPanel
local groundPanel
local editPanel


local KEY_CLOSE = "escape"
local KEY_STAMP = "s"
local KEY_PEN = "d"
local KEY_DELETE = "delete"

-- called when loading game	
function editor.init()

	-- save all user made files in here:
	love.filesystem.createDirectory("userlevels")
	
	editor.images = {}

	local prefix = Camera.scale * 8
	editor.images.tilesetGround = love.graphics.newImage( "images/tilesets/" .. prefix .. "grounds.png" )
	editor.images.tilesetBackground = love.graphics.newImage( "images/tilesets/" .. prefix .. "background1.png" )
	editor.images.cell = love.graphics.newImage( "images/editor/" .. prefix .. "cell.png")
	editor.images.cell:setWrap('repeat', 'repeat')

	local tileSize = Camera.scale * 8
	editor.cellQuad = love.graphics.newQuad(0, 0, Camera.width+tileSize, Camera.height+tileSize, tileSize, tileSize)

	editor.images.fill = love.graphics.newImage( "images/editor/" .. prefix .. "fill.png")
	editor.fillQuad = love.graphics.newQuad(0, 0, tileSize*3, tileSize*3, tileSize*3, tileSize*3 )

	editor.groundList = Ground:init()
	editor.bgObjectList = BgObject:init()

	editor.toolTip = {
		text = "",
		x = 0,
		y = 0,
	}
	editor.toolsToolTips = {}
	editor.toolsToolTips["pen"] = "left mouse: draw, right mouse: erase, shift: draw straight line, ctrl: flood fill"
	--editor.toolsToolTips["erase"] = "click: erase, shift+click: erase straight line"
	editor.toolsToolTips["bgObject"] = "left mouse: add current background object, right mouse: delete object"
	editor.toolsToolTips["edit"] = "left mouse: select object, left + drag: move object"
end

function editor.createCellQuad()
	local tileSize = Camera.scale * 8
	editor.cellQuad = love.graphics.newQuad(0, 0, Camera.width/cam.zoom+tileSize, Camera.height/cam.zoom+tileSize, tileSize, tileSize)
end

-- called when editor is to be started:
function editor.start()
	print("Starting editor..." )
	mode = "editor"

	map = EditorMap:new()
	cam = EditorCam:new() -- -Camera.scale*8*map.MAP_SIZE/2, -Camera.scale*8*map.MAP_SIZE/2 )

	love.mouse.setVisible( true )

	local toolPanelWidth = love.graphics.getWidth()/Camera.scale-60
	toolPanel = Panel:new( 30, love.graphics.getHeight()/Camera.scale-23,
							 toolPanelWidth, 16 )
	-- left side:
	local x,y = 11,8
	toolPanel:addClickable( x, y, function() editor.setTool("pen") end,
				'LEPenOff',
				'LEPenOn',
				'LEPenHover',
				KEY_PEN .. " - Draw Tool: Draw tiles onto the canvas.")
	x = x + 10
	toolPanel:addClickable( x, y, function() editor.setTool("bgObject") end,
				'LEStampOff',
				'LEStampOn',
				'LEStampHover',
				KEY_STAMP .. " - Stamp Tool: Select and place background objects.")
	x = x +10
	toolPanel:addClickable( x, y, function() editor.setTool("edit") end,
				'LEEditOff',
				'LEEditOn',
				'LEEditHover',
				KEY_STAMP .. " - Stamp Tool: Select and place background objects.")
	x = x +10
				
	--[[toolPanel:addClickable( x, y, function() editor.setTool("erase") end,
				'LEEraserOff',
				'LEEraserOn',
				'LEEraserHover',
				"Eraser - remove tiles or objects.")]]

	-- right side
	x, y = toolPanelWidth - 13, 8
	toolPanel:addClickable( x, y, menu.startTransition( menu.initMain, true ),
				'LEExitOff',
				'LEExitOn',
				'LEExitHover',
				"Close editor and return to main menu.")
	x = x - 10
	toolPanel:addClickable( x, y, nil,
				'LESaveOff',
				'LESaveOn',
				'LESaveHover',
				"Save the map.")
	x = x - 10
	toolPanel:addClickable( x, y, nil,
				'LEOpenOff',
				'LEOpenOn',
				'LEOpenHover',
				"Load another map.")


	-- Panel for choosing the ground type:
	groundPanel = Panel:new( 1, 30, 16, 90 )
	x,y = 8,7

	groundPanel:addClickable( x, y, function() editor.currentTool = "pen"
										editor.currentGround = editor.groundList[1] end,
				'LEGround1Off',
				'LEGround1On',
				'LEGround1Hover',
				"1 - draw concrete ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.currentTool = "pen"
										editor.currentGround = editor.groundList[2] end,
				'LEGround2Off',
				'LEGround2On',
				'LEGround2Hover',
				"2 - draw dirt ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.currentTool = "pen"
										editor.currentGround = editor.groundList[3] end,
				'LEGround3Off',
				'LEGround3On',
				'LEGround3Hover',
				"3 - draw grass ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.currentTool = "pen"
										editor.currentGround = editor.groundList[4] end,
				'LEGround4Off',
				'LEGround4On',
				'LEGround4Hover',
				"4 - draw stone ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.currentTool = "pen"
										editor.currentGround = editor.groundList[5] end,
				'LEGround5Off',
				'LEGround5On',
				'LEGround5Hover',
				"5 - draw wood ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.currentTool = "pen"
										editor.currentGround = editor.groundList[6] end,
				'LEGround6Off',
				'LEGround6On',
				'LEGround6Hover',
				"6 - draw bridges" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.currentTool = "pen"
										editor.currentGround = editor.groundList[7] end,
				'LESpikes1Off',
				'LESpikes1On',
				'LESpikes1Hover',
				"7 - draw grey spikes" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.currentTool = "pen"
										editor.currentGround = editor.groundList[8] end,
				'LESpikes2Off',
				'LESpikes2On',
				'LESpikes2Hover',
				"8 - draw brown spikes" )

	editor.createBgObjectPanel()

	editPanel = Panel:new( 0, 0, 3*12, 12)
	editPanel.visible = false

	x, y = 6, 6
	editPanel:addClickable( x, y, function() map:removeSelectedBgObject() end,
				'LEDeleteOff',
				'LEDeleteOn',
				'LEDeleteHover',
				KEY_DELETE .. " - remove" )
	x = x + 10
	editPanel:addClickable( x, y, function() map:bgObjectLayerUp() end,
				'LELayerUpOff',
				'LELayerUpOn',
				'LELayerUpHover',
				"move up one layer" )
	x = x + 10
	editPanel:addClickable( x, y, function() map:bgObjectLayerDown() end,
				'LELayerDownOff',
				'LELayerDownOn',
				'LELayerDownHover',
				"move down one layer" )


	-- available tools:
	-- "pen", "bgObject"
	editor.currentTool = "pen"
	editor.currentGround = editor.groundList[1]
	editor.currentBgObject = editor.bgObjectList[1]

	love.graphics.setPointStyle( "smooth" )
	love.graphics.setPointSize( 6 )

	editor.loadFile()
end

function editor.createBgObjectPanel()

	local PADDING = Camera.scale/2

	local panelWidth = love.graphics.getWidth()/Camera.scale - 40
	local panelHeight = love.graphics.getHeight()/Camera.scale - 23 - 14

	bgObjectPanel = Panel:new( 20, 10, panelWidth, panelHeight )
	bgObjectPanel.visible = false

	local x, y = PADDING, PADDING
	local page = 1
	local maxY = -math.huge
	for k, obj in ipairs( editor.bgObjectList ) do

		local event = function()
			editor.currentBgObject = obj
			bgObjectPanel.visible = false
		end

		local bBox = obj.bBox

		maxY = math.max( bBox.maxY, maxY )

		if x + bBox.maxX*8 > panelWidth then
			-- add the maximum height of the obejcts in this row, then continue:
			y = y + maxY*8 + PADDING
			x = PADDING

			maxY = -math.huge
		end

		bgObjectPanel:addBatchClickable( x, y, event, obj.batch, bBox.maxX*8, bBox.maxY*8, obj.name, page )

		-- Is this object higher than the others of this row?

		x = x + bBox.maxX*8 + PADDING
	end
end

-- called as long as editor is running:
function editor:update( dt )
	self.toolTip.text = ""

	local clicked = love.mouse.isDown("l", "r")
	local x, y = love.mouse.getPosition()
	local wX, wY = cam:screenToWorld( x, y )

	if map.selectedBgObject and editPanel.visible then
		local ex, ey = cam:worldToScreen( map.selectedBgObject.drawX,
							map.selectedBgObject.drawY + map.selectedBgObject.height )
		editPanel:moveTo( ex/(Camera.scale), ey/(Camera.scale) )
	end

	local hit = toolPanel:collisionCheck( x, y ) or groundPanel:collisionCheck( x, y ) or
				( bgObjectPanel.visible and bgObjectPanel:collisionCheck(x, y) ) or
				( editPanel.visible and editPanel:collisionCheck(x, y) )
	
	self.mouseOnCanvas = not hit
	self.drawLine = false

	local tileX = math.floor(wX/(Camera.scale*8))
	local tileY = math.floor(wY/(Camera.scale*8))

	self.shift = love.keyboard.isDown("lshift", "rshift")
	self.ctrl = love.keyboard.isDown("lctrl", "rctrl")

	if self.mouseOnCanvas then
		if self.drawing then
			if tileX ~= self.lastTileX or tileY ~= self.lastTileY then
				if math.abs(tileX - self.lastTileX) > 1 or
					math.abs(tileX - self.lastTileY) > 1 then
					map:line( tileX, tileY,
						self.lastTileX, self.lastTileY,
						function(x, y) map:setGroundTile(x, y, self.currentGround, true ) end )
				else
					map:setGroundTile( tileX, tileY, self.currentGround, true )
				end
			end
		elseif self.erasing then
			if tileX ~= self.lastTileX or tileY ~= self.lastTileY then
				if math.abs(tileX - self.lastTileX) > 1 or
					math.abs(tileX - self.lastTileY) > 1 then
					map:line( tileX, tileY,
						self.lastTileX, self.lastTileY,
						function(x, y) map:eraseGroundTile(x, y, true ) end )
				else
					map:eraseGroundTile( tileX, tileY, true )
				end
			end
		end
		if self.currentTool == "pen" and self.shift then
			self.drawLine = true
		elseif self.currentTool == "edit" and self.dragging and
				(tileX ~= self.lastTileX or tileY ~= self.lastTileY) then
			map:dragBgObject( tileX, tileY )
		end
		self.lastTileX, self.lastTileY = tileX, tileY
	else
		local hit = toolPanel:click( x, y, false ) or groundPanel:click( x, y, false ) or
			( editPanel.visible and editPanel:click( x, y, false) ) or 
			( bgObjectPanel.visible and bgObjectPanel:click( x, y, false ) )
	end

	if self.toolTip.text == "" and self.currentTool and not hit then
		self.setToolTip( self.toolsToolTips[self.currentTool] )
	end

	map:update( dt )

	toolPanel:update( dt )
	groundPanel:update( dt )
	editPanel:update( dt )
end

function editor:mousepressed( button, x, y )
	if button == "m" then
		cam:setMouseAnchor()
	elseif button == "wu" then
		cam:zoomIn()
	elseif button == "wd" then
		cam:zoomOut()
	elseif button == "l" then

		local wX, wY = cam:screenToWorld( x, y )
		local tileX = math.floor(wX/(Camera.scale*8))
		local tileY = math.floor(wY/(Camera.scale*8))
		local hit = toolPanel:collisionCheck( x, y ) or groundPanel:collisionCheck( x, y ) or
				( bgObjectPanel.visible and bgObjectPanel:collisionCheck(x, y) ) or
				( editPanel.visible and editPanel:collisionCheck(x, y) )

		local mouseOnCanvas = not hit

		if mouseOnCanvas then
			if self.currentTool == "pen" then

				if self.shift and self.lastClickX and self.lastClickY then
					-- draw a line
					map:line( tileX, tileY,
						self.lastClickX, self.lastClickY,
						function(x, y) map:setGroundTile(x, y, self.currentGround, true ) end )
				elseif self.ctrl then
					-- fill the area
					map:startFillGround( tileX, tileY, "set", self.currentGround )
				else
					-- paint:
					self.drawing = true
					-- force to draw one tile:
					map:setGroundTile( tileX, tileY, self.currentGround, true )
				end
				self.lastClickX, self.lastClickY = tileX, tileY
			elseif self.currentTool == "bgObject" then
				map:addBgObject( tileX-1, tileY-1, self.currentBgObject )
			elseif self.currentTool == "edit" then
				if map:selectBgObjectAt( tileX, tileY ) then
					editPanel.visible = true
					self.dragging = true
				else
					editPanel.visible = false
				end
			end
		else
			-- a panel was hit: check if any button was pressed:
			local hit = toolPanel:click( x, y, true ) or groundPanel:click( x, y, true ) or
				( editPanel.visible and editPanel:click( x, y, true) ) or 
				( bgObjectPanel.visible and bgObjectPanel:click( x, y, true ) )
		end
	elseif button == "r" then

		local wX, wY = cam:screenToWorld( x, y )
		local tileX = math.floor(wX/(Camera.scale*8))
		local tileY = math.floor(wY/(Camera.scale*8))
		local hit = toolPanel:collisionCheck( x, y ) or groundPanel:collisionCheck( x, y ) or
				( bgObjectPanel.visible and bgObjectPanel:collisionCheck(x, y) ) or
				( editPanel.visible and editPanel:collisionCheck(x, y) )

		local mouseOnCanvas = not hit

		if mouseOnCanvas then
			if self.currentTool == "pen" then

				if self.shift and self.lastClickX and self.lastClickY then
					-- draw a line
					map:line( tileX, tileY,
					self.lastClickX, self.lastClickY,
					function(x, y) map:eraseGroundTile(x, y, true ) end )
				elseif self.ctrl then
					-- fill the area
					map:startFillGround( tileX, tileY, "erase", nil )
				else
					-- start erasing
					self.erasing = true
					-- force to erase one tile:
					map:eraseGroundTile( tileX, tileY, true )
				end
				self.lastClickX, self.lastClickY = tileX, tileY
			elseif self.currentTool == "bgObject" then
				map:removeBgObjectAt( tileX, tileY )
			end
		end
	end
end

function editor:mousereleased( button, x, y )
	if button == "m" then
		cam:releaseMouseAnchor()
	elseif button == "l" then
		self.drawing = false
		map:dropBgObject()
		self.dragging = false
	elseif button == "r" then
		self.erasing = false
	end
end

function editor.keypressed( key, repeated )
	if key == KEY_CLOSE and bgObjectPanel.visible then
		bgObjectPanel.visible = false
		editor.currentBgObject = editor.currentBgObject or editor.bgObjectList[1]
	elseif key == KEY_PEN then
		editor.setTool("pen")
	elseif key == KEY_STAMP then
		editor.setTool("bgObject")
	elseif key == KEY_DELETE then
		if map.selectedBgObject then
			map:removeSelectedBgObject()
		end
	elseif tonumber(key) then		-- let user choose the ground type using the number keys
		local num = tonumber(key)
		if num >= 1 and num < 10 and editor.groundList[num] then
			editor.currentGround = editor.groundList[num]
		end
	end
end

-- called as long as editor is running:
function editor:draw()
	local x, y = love.mouse.getPosition()
	local wX, wY = cam:screenToWorld( x, y )

	cam:apply()

	-- map:drawGrid()
	local tileSize = Camera.scale * 8
	local cx,cy = cam:screenToWorld( 0, 0 )
		cx = math.floor(cx/tileSize)*tileSize
		cy = math.floor(cy/tileSize)*tileSize
		love.graphics.draw(editor.images.cell, editor.cellQuad,cx,cy)


	map:drawBackground()
	
	map:drawGround()

	map:drawBoundings()
	
	if self.mouseOnCanvas then

		love.graphics.setColor(0,0,0,128)
		local rX = math.floor(wX/(8*Camera.scale))*8*Camera.scale
		local rY = math.floor(wY/(8*Camera.scale))*8*Camera.scale
		if self.currentBgObject and self.currentTool == "bgObject" then
			love.graphics.draw( self.currentBgObject.batch, rX - 8*Camera.scale, rY - 8*Camera.scale)
		else
			if self.ctrl and self.currentTool == "pen" then
				love.graphics.draw( editor.images.fill, editor.fillQuad, rX-tileSize, rY-tileSize )
			else
				love.graphics.rectangle( 'fill',rX,rY, tileSize, tileSize )
			end
		end

		-- draw the line:
		if self.drawLine then
			local sX = math.floor(self.lastClickX)*8*Camera.scale
			local sY = math.floor(self.lastClickY)*8*Camera.scale
			love.graphics.setColor( 255,188,128,200 )
			love.graphics.line( rX+4*Camera.scale, rY+4*Camera.scale, sX+4*Camera.scale, sY+4*Camera.scale )

			love.graphics.setColor( 255,188,128,255)
			love.graphics.point( rX + 4*Camera.scale, rY+4*Camera.scale )
			love.graphics.point( sX + 4*Camera.scale, sY+4*Camera.scale )
			love.graphics.setColor(255,255,255,255)
		end
	end
	
	cam:free()

	if map.selectedBgObject then
		editPanel:draw()
	end

	toolPanel:draw()


	if bgObjectPanel.visible then
		bgObjectPanel:draw()
	elseif editor.currentTool == "pen" then
		groundPanel:draw()
	end
	
	love.graphics.print( self.toolTip.text, self.toolTip.x, self.toolTip.y )
	
	--[[love.graphics.print(wX,10,10)
	love.graphics.print(wY,10,50)--]]

	love.graphics.print( love.timer.getFPS(), 20, love.graphics.getHeight() - 40 )

end

function editor.setTool( tool )
	map:selectNoBgObject()
	editor.currentTool = tool
	if tool == "bgObject" then
		bgObjectPanel.visible = true
	else
		bgObjectPanel.visible = false
	end
end

function editor.useTool( tileX, tileY, lastTileX, lastTileY, mouse, heldDown )
	if editor.currentTool == "pen" then
		if mouse == "l" then	-- draw
			if love.keyboard.isDown( "lctrl", "rctrl" ) then
			else
				if lastTileX and lastTileY then
					map:line( tileX, tileY,
					lastTileX, lastTileY,
					function(x, y) map:setGroundTile(x, y, editor.currentGround, true ) end )
				else
					map:setGroundTile( tileX, tileY, editor.currentGround, true )
				end
			end
		elseif mouse == "r" then	-- erase
			if love.keyboard.isDown( "lctrl", "rctrl" ) then
				map:startFillGround( tileX, tileY, "erase", nil )
			else
				if lastTileX and lastTileY then
					map:line( tileX, tileY,
					lastTileX, lastTileY,
					function(x, y) map:eraseGroundTile(x, y, true ) end )
				else
					map:eraseGroundTile( tileX, tileY, true )
				end
			end
		end
	elseif editor.currentTool == "bgObject" then
		if mouse == "l" then
			map:addBackgroundObject( tileX-1, tileY-1, editor.currentBgObject )
		else
			map:removeBackgroundObject( tileX, tileY )
		end
	elseif editor.currentTool == "edit" then
		if mouse == "l" then
			if heldDown then	-- not a new click, but dragging instead
				map:dragBgObject( tileX, tileY )
			else	-- new click:
				map:selectBgObjectAt( tileX, tileY )
			end
		end
	end
end

function editor.setToolTip( tip )
	tip = tip or ""
	editor.toolTip.text = string.lower(tip)
	editor.toolTip.x = (love.graphics.getWidth() - love.graphics.getFont():getWidth( tip ))/2
	editor.toolTip.y = love.graphics.getHeight() - love.graphics.getFont():getHeight() - 10
end

function editor.textinput( letter )
end

------------------------------------
-- Saving and Loading maps:
------------------------------------
-- Note: loading maps into the editor is slightly different
-- from loading them for the game.

-- displays all file names and lets user choose one of them:
function editor.loadList()
	
end

function editor.saveFile( fileName )
	fileName = "userlevels/" .. (fileName or "test.dat")
end

function editor.loadFile( fileName )
	fileName = "userlevels/" .. (fileName or "test.dat")
end

return editor
