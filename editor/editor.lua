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
	editor.toolsToolTips["draw"] = "click: draw, shift+click: draw straight line"
	editor.toolsToolTips["erase"] = "click: erase, shift+click: erase straight line"
	editor.toolsToolTips["bgObject"] = "click: add current object to scene's background"
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
	cam = EditorCam:new( -Camera.scale*8*map.MAP_SIZE/2, -Camera.scale*8*map.MAP_SIZE/2 )

	love.mouse.setVisible( true )

	local toolPanelWidth = love.graphics.getWidth()/Camera.scale-60
	toolPanel = Panel:new( 30, love.graphics.getHeight()/Camera.scale-23,
							 toolPanelWidth, 16 )
	-- right side:
	local x,y = 11,8
	toolPanel:addClickable( x, y, function() editor.setTool("draw") end,
				'LEPenOff',
				'LEPenOn',
				'LEPenHover',
				"Pen - draw single tiles or objects onto the map.")
	x = x + 10
	toolPanel:addClickable( x, y, function() editor.setTool("bgObject") end,
				'LEPenOff',
				'LEPenOn',
				'LEPenHover',
				"Stamp - Select and place background objects.")
	x = x +10
				
	toolPanel:addClickable( x, y, function() editor.setTool("erase") end,
				'LEEraserOff',
				'LEEraserOn',
				'LEEraserHover',
				"Eraser - remove tiles or objects.")

	-- left side
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

	groundPanel:addClickable( 8, 7, function() editor.selectedGround = editor.groundList[1] end,
				'LEGround1Off',
				'LEGround1On',
				'LEGround1Hover')

	groundPanel:addClickable( 8, 17, function() editor.selectedGround = editor.groundList[2] end,
				'LEGround2Off',
				'LEGround2On',
				'LEGround2Hover')
	groundPanel:addClickable( 8, 27, function() editor.selectedGround = editor.groundList[3] end,
				'LEGround3Off',
				'LEGround3On',
				'LEGround3Hover')
	groundPanel:addClickable( 8, 37, function() editor.selectedGround = editor.groundList[4] end,
				'LEGround4Off',
				'LEGround4On',
				'LEGround4Hover')
	groundPanel:addClickable( 8, 47, function() editor.selectedGround = editor.groundList[5] end,
				'LEGround5Off',
				'LEGround5On',
				'LEGround5Hover')
	groundPanel:addClickable( 8, 57, function() editor.selectedGround = editor.groundList[6] end,
				'LEGround6Off',
				'LEGround6On',
				'LEGround6Hover')


	editor.createBgObjectPanel()

	-- available tools:
	-- "draw", "erase"
	-- mabye later add "fill"
	editor.selectedTool = "draw"
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
		local b = love.graphics.newSpriteBatch( obj.tileset )

		-- after this operation, bBox should hold the dimensions of the sprite:
		local IDs, bBox = obj:addToBatch( b, {}, 0, 0 )

		local event = function()
			editor.selectedBgObject = obj
			choosingBgObject = false
		end

		maxY = math.max( bBox.maxY, maxY )

		if x + bBox.maxX*8 > panelWidth then
			-- add the maximum height of the obejcts in this row, then continue:
			y = y + maxY*8 + PADDING
			x = PADDING

			maxY = -math.huge
		end

		bgObjectPanel:addBatchClickable( x, y, event, b, bBox.maxX*8, bBox.maxY*8, obj.name, page )

		-- Is this object higher than the others of this row?

		x = x + bBox.maxX*8 + PADDING
	end
end

-- called as long as editor is running:
function editor:update( dt )

	self.toolTip.text = ""

	local clicked = love.mouse.isDown("l")
	local x, y = love.mouse.getPosition()
	local wX, wY = cam:screenToWorld( x, y )
	local hit = toolPanel:update( dt, x, y, clicked ) or
				groundPanel:update( dt, x, y, clicked ) or
				(choosingBgObject and bgObjectPanel:update( dt, x, y, clicked) )
	
	self.mouseOnCanvas = not hit

	local tileX = math.floor(wX/(Camera.scale*8))
	local tileY = math.floor(wY/(Camera.scale*8))

	local shift = love.keyboard.isDown("lshift", "rshift")


	if self.mouseOnCanvas and clicked then

		if not choosingBgObject then
			if not shift and (editor.clickedTileX ~= tileX or editor.clickedTileY ~= tileY) and 
				(editor.selectedTool ~= "bgObject" or editor.clickedLastFrame == false) then
				editor.useTool( tileX, tileY, editor.clickedTileX, editor.clickedTileY )
				editor.clickedTileX = tileX
				editor.clickedTileY = tileY
				editor.lineStartX, editor.lineStartY = tileX, tileY
			end

		end
		choosingBgObject = false
	else
		if editor.clickedLastFrame then
			if shift and (self.selectedTool == "draw" or self.selectedTool == "erase") then
				if not editor.lineStartX or not editor.lineStartY then
					editor.lineStartX, editor.lineStartY = tileX, tileY
				else
					editor.useTool( tileX, tileY, editor.lineStartX, editor.lineStartY )
					editor.lineStartX, editor.lineStartY = tileX, tileY
				end
			end
		end
		editor.clickedLastFrame = false
		editor.clickedTileX = nil
		editor.clickedTileY = nil
	end

	if self.toolTip.text == "" and self.selectedTool and not hit then
		self.setToolTip( self.toolsToolTips[self.selectedTool] )
	end
	if clicked then 
		editor.clickedLastFrame = true
	end
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
	
	if self.mouseOnCanvas then
		love.graphics.setColor(0,0,0,128)
		local rX = math.floor(wX/(8*Camera.scale))*8*Camera.scale
		local rY = math.floor(wY/(8*Camera.scale))*8*Camera.scale
		love.graphics.rectangle('fill',rX,rY,8*Camera.scale,8*Camera.scale)

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
	groundPanel:draw()

	if choosingBgObject then
		bgObjectPanel:draw()
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
	end
end

function editor.useTool( tileX, tileY, lastTileX, lastTileY )
	if editor.selectedTool == "draw" then
		if lastTileX and lastTileY then
			map:line( tileX, tileY,
				lastTileX, lastTileY,
				function(x, y) map:setGroundTile(x, y, editor.selectedGround, true ) end )
		else
			map:setGroundTile( tileX, tileY, editor.selectedGround, true )
		end
	elseif editor.selectedTool == "erase" then
		local success = false
		if lastTileX and lastTileY then
			map:line( tileX, tileY,
				lastTileX, lastTileY,
				function(x, y) map:eraseGroundTile(x, y, true ) end )
			success = true
		else
			success = map:eraseGroundTile( tileX, tileY, true )
		end
		if not success then
			map:removeBackgroundObject( tileX, tileY )
		end
	elseif editor.selectedTool == "bgObject" then
		map:addBackgroundObject( tileX, tileY, editor.selectedBgObject )
	end
end

function editor.setToolTip( tip )
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
