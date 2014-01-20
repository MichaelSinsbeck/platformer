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

EditorCam = require("editor/editorCam")

local map = nil
local cam = nil

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
	cam = EditorCam:new()

	love.mouse.setVisible( true )
	local toolPanelWidth = love.graphics.getWidth()/Camera.scale-60
	toolPanel = Panel:new( 30, love.graphics.getHeight()/Camera.scale-18,
							 toolPanelWidth, 16 )
	-- right side:
	toolPanel:addClickable( 11, 8, function() editor.setTool("draw") end,
				'LEPenOff',
				'LEPenOn',
				'LEPenHover')
				
	toolPanel:addClickable( 21, 8, function() editor.setTool("erase") end,
				'LEEraserOff',
				'LEEraserOn',
				'LEEraserHover')
	
	-- left side
	toolPanel:addClickable( toolPanelWidth - 13, 8,
				menu.startTransition( menu.initMain, true ),
				'LEExitOff',
				'LEExitOn',
				'LEExitHover')

	toolPanel:addClickable( toolPanelWidth - 23, 8,
				nil,
				'LESaveOff',
				'LESaveOn',
				'LESaveHover')

	toolPanel:addClickable( toolPanelWidth - 33, 8,
				nil,
				'LEOpenOff',
				'LEOpenOn',
				'LEOpenHover')



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

	-- available tools:
	-- "draw", "erase"
	-- mabye later add "fill"
	editor.selectedTool = "draw"
	editor.selectedGround = editor.groundList[1]
	
	-- debug (loads test.dat)
	editor.loadFile()
end

-- called as long as editor is running:
function editor:update( dt )
	local clicked = love.mouse.isDown("l")
	local x, y = love.mouse.getPosition()
	local wX, wY = cam:screenToWorld( x, y )
	local hit = toolPanel:update( dt, x, y, clicked ) or groundPanel:update( dt, x, y, clicked )
	
	self.mouseOnCanvas = not hit

	if self.mouseOnCanvas and clicked then
		local tileX = math.floor(wX/(Camera.scale*8))
		local tileY = math.floor(wY/(Camera.scale*8))
		if editor.clickedTileX ~= tileX or editor.clickedTileY ~= tileY then
			editor.useTool( tileX, tileY )
			editor.clickedTileX = tileX
			editor.clickedTileY = tileY
		end
	else
		editor.clickedTileX = nil
		editor.clickedTileY = nil
	end

	--[[local clicked = false -- love.mouse.isDown("m")

	if clicked then
		if editor.clickedX and editor.clickedY then
			local dx, dy = x-editor.clickedX, y-editor.clickedY
			dx, dy = dx*cam.zoom, dy*cam.zoom
			cam:move(dx, dy)
		end
		editor.clickedX, editor.clickedY = x, y
	else
		editor.clickedX, editor.clickedY = nil, nil
	end]]
	
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
	end

	cam:free()

	toolPanel:draw()
	groundPanel:draw()
	
	--[[love.graphics.print(wX,10,10)
	love.graphics.print(wY,10,50)--]]

	love.graphics.print( love.timer.getFPS(), 20, love.graphics.getHeight() - 40 )

end

function editor.setTool( tool )
	editor.selectedTool = tool
end

function editor.useTool( tileX, tileY )
	if editor.selectedTool == "draw" then
		map:setGroundTile( tileX, tileY, editor.selectedGround, true )
	elseif editor.selectedTool == "erase" then
		local success = map:eraseGroundTile( tileX, tileY, true )
		-- TODO:
		-- if success is false, then try to delete background object
		-- at this position instead.
	end
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
