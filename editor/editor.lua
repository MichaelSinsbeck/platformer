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

local choosingBgObject = false

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

	groundPanel:addClickable( x, y, function() editor.selectedTool = "pen"
										editor.selectedGround = editor.groundList[1] end,
				'LEGround1Off',
				'LEGround1On',
				'LEGround1Hover',
				"1 - draw concrete ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.selectedTool = "pen"
										editor.selectedGround = editor.groundList[2] end,
				'LEGround2Off',
				'LEGround2On',
				'LEGround2Hover',
				"2 - draw dirt ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.selectedTool = "pen"
										editor.selectedGround = editor.groundList[3] end,
				'LEGround3Off',
				'LEGround3On',
				'LEGround3Hover',
				"3 - draw grass ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.selectedTool = "pen"
										editor.selectedGround = editor.groundList[4] end,
				'LEGround4Off',
				'LEGround4On',
				'LEGround4Hover',
				"4 - draw stone ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.selectedTool = "pen"
										editor.selectedGround = editor.groundList[5] end,
				'LEGround5Off',
				'LEGround5On',
				'LEGround5Hover',
				"5 - draw wood ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.selectedTool = "pen"
										editor.selectedGround = editor.groundList[6] end,
				'LEGround6Off',
				'LEGround6On',
				'LEGround6Hover',
				"6 - draw bridges" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.selectedTool = "pen"
										editor.selectedGround = editor.groundList[7] end,
				'LESpikes1Off',
				'LESpikes1On',
				'LESpikes1Hover',
				"7 - draw grey spikes" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.selectedTool = "pen"
										editor.selectedGround = editor.groundList[8] end,
				'LESpikes2Off',
				'LESpikes2On',
				'LESpikes2Hover',
				"8 - draw brown spikes" )

	editor.createBgObjectPanel()

	-- available tools:
	-- "pen", "bgObject"
	editor.selectedTool = "pen"
	editor.selectedGround = editor.groundList[1]
	editor.selectedBgObject = editor.bgObjectList[1]

	love.graphics.setPointStyle( "smooth" )
	love.graphics.setPointSize( 6 )
	-- debug (loads test.dat)
	editor.loadFile()
end

function editor.createBgObjectPanel()

	local PADDING = Camera.scale/2

	local panelWidth = love.graphics.getWidth()/Camera.scale - 40
	local panelHeight = love.graphics.getHeight()/Camera.scale - 23 - 14

	bgObjectPanel = Panel:new( 20, 10, panelWidth, panelHeight )

	local x, y = PADDING, PADDING
	local page = 1
	local maxY = -math.huge
	for k, obj in ipairs( editor.bgObjectList ) do

		local event = function()
			editor.selectedBgObject = obj
			choosingBgObject = false
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
	local clickedLeft = love.mouse.isDown("l")
	local clickedRight = love.mouse.isDown("r")
	local x, y = love.mouse.getPosition()
	local wX, wY = cam:screenToWorld( x, y )
	local hit = toolPanel:update( dt, x, y, clicked ) or
				groundPanel:update( dt, x, y, clicked ) or
				(choosingBgObject and bgObjectPanel:update( dt, x, y, clicked) )
	
	self.mouseOnCanvas = not hit

	local tileX = math.floor(wX/(Camera.scale*8))
	local tileY = math.floor(wY/(Camera.scale*8))

	local shift = love.keyboard.isDown("lshift", "rshift")
	local ctrl = love.keyboard.isDown("lctrl", "rctrl")

	if self.mouseOnCanvas and clicked then
		if not choosingBgObject then
			if not shift and not ctrl and
				(editor.clickedTileX ~= tileX or editor.clickedTileY ~= tileY) and 
				(editor.selectedTool ~= "bgObject" or editor.clickedLastFrame == false) then
				if clickedLeft then
					editor.useTool( tileX, tileY, editor.clickedTileX, editor.clickedTileY, "l", self.clickedLastFrame )
				else
					editor.useTool( tileX, tileY, editor.clickedTileX, editor.clickedTileY, "r", self.clickedLastFrame )
				end
				editor.clickedTileX = tileX
				editor.clickedTileY = tileY
				editor.lineStartX, editor.lineStartY = tileX, tileY
			end

		end
		choosingBgObject = false
	else
		if editor.clickedLastFrame then
			if (shift or ctrl) and self.selectedTool == "pen" then
				if editor.clickedLeftLastFrame then
					editor.useTool( tileX, tileY, editor.lineStartX, editor.lineStartY, "l" )
				else
					editor.useTool( tileX, tileY, editor.lineStartX, editor.lineStartY, "r" )
				end

				if not editor.lineStartX or not editor.lineStartY then
					editor.lineStartX, editor.lineStartY = tileX, tileY
				else
					editor.lineStartX, editor.lineStartY = tileX, tileY
				end
			end
		end
		editor.clickedLastFrame = false
		editor.clickedLeftLastFrame = false
		editor.clickedTileX = nil
		editor.clickedTileY = nil
	end

	if self.toolTip.text == "" and self.selectedTool and not hit then
		self.setToolTip( self.toolsToolTips[self.selectedTool] )
	end
	if clicked then 
		editor.clickedLastFrame = true
		editor.clickedLeftLastFrame = clickedLeft
	end

	map:update( dt )
end

function editor.mousepressed( button )
	if button == "m" then
		cam:setMouseAnchor()
	elseif button == "wu" then
		cam:zoomIn()
	elseif button == "wd" then
		cam:zoomOut()
	end
end

function editor.mousereleased( button )
	if button == "m" then
		cam:releaseMouseAnchor()
	end
end

function editor.keypressed( key, repeated )
	if key == KEY_CLOSE and choosingBgObject then
		choosingBgObject = false
		editor.selectedBgObject = editor.selectedBgObject or editor.bgObjectList[1]
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
			editor.selectedGround = editor.groundList[num]
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
		if self.selectedBgObject and self.selectedTool == "bgObject" then
			love.graphics.draw( self.selectedBgObject.batch, rX - 8*Camera.scale, rY - 8*Camera.scale)
		else
			love.graphics.rectangle('fill',rX,rY,8*Camera.scale,8*Camera.scale)
		end
		
		-- draw the line:
		if self.lineStartX and self.lineStartY and love.keyboard.isDown("lshift", "rshift") then
			local sX = math.floor(self.lineStartX)*8*Camera.scale
			local sY = math.floor(self.lineStartY)*8*Camera.scale
			love.graphics.setColor( 255,188,128,200 )
			love.graphics.line( rX+4*Camera.scale, rY+4*Camera.scale, sX+4*Camera.scale, sY+4*Camera.scale )

			love.graphics.setColor( 255,188,128,255)
			love.graphics.point( rX + 4*Camera.scale, rY+4*Camera.scale )
			love.graphics.point( sX + 4*Camera.scale, sY+4*Camera.scale )
			love.graphics.setColor(255,255,255,255)
		end
	end

	cam:free()

	toolPanel:draw()


	if choosingBgObject then
		bgObjectPanel:draw()
	elseif editor.selectedTool == "pen" then
		groundPanel:draw()
	end
	
	love.graphics.print( self.toolTip.text, self.toolTip.x, self.toolTip.y )
	
	--[[love.graphics.print(wX,10,10)
	love.graphics.print(wY,10,50)--]]

	love.graphics.print( love.timer.getFPS(), 20, love.graphics.getHeight() - 40 )

end

function editor.setTool( tool )
	editor.selectedTool = tool
	if tool == "bgObject" then
		choosingBgObject = true
	else
		choosingBgObject = false
	end
end

function editor.useTool( tileX, tileY, lastTileX, lastTileY, mouse, heldDown )
	if editor.selectedTool == "pen" then
		if mouse == "l" then	-- draw
			if love.keyboard.isDown( "lctrl", "rctrl" ) then
				map:startFillGround( tileX, tileY, "set", editor.selectedGround )
			else
				if lastTileX and lastTileY then
					map:line( tileX, tileY,
					lastTileX, lastTileY,
					function(x, y) map:setGroundTile(x, y, editor.selectedGround, true ) end )
				else
					map:setGroundTile( tileX, tileY, editor.selectedGround, true )
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
		--map:removeBackgroundObject( tileX, tileY )
	elseif editor.selectedTool == "bgObject" then
		if mouse == "l" then
			map:addBackgroundObject( tileX-1, tileY-1, editor.selectedBgObject )
		else
			map:removeBackgroundObject( tileX, tileY )
		end
	elseif editor.selectedTool == "edit" then
		if mouse == "l" then
			if heldDown then	-- not a new click, but dragging instead
				map:dragBgObject( tileX, tileY )
			else	-- new click:
				map:selectBgObject( tileX, tileY )
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
