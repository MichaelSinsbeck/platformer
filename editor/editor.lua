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
	editor.images.penOff_IMG = love.graphics.newImage("images/editor/" .. prefix .. "penOff.png")
	editor.images.penOn_IMG = love.graphics.newImage("images/editor/" .. prefix .. "penOn.png")
	editor.images.penHover_IMG = love.graphics.newImage("images/editor/" .. prefix .. "penHover.png")
	editor.images.eraserOff_IMG = love.graphics.newImage("images/editor/" .. prefix .. "eraserOff.png")
	editor.images.eraserOn_IMG = love.graphics.newImage("images/editor/" .. prefix .. "eraserOn.png")
	editor.images.eraserHover_IMG = love.graphics.newImage("images/editor/" .. prefix .. "eraserHover.png")

	editor.images.loadOff_IMG = love.graphics.newImage("images/editor/" .. prefix .. "loadOff.png")
	editor.images.loadOn_IMG = love.graphics.newImage("images/editor/" .. prefix .. "loadOn.png")
	editor.images.loadHover_IMG = love.graphics.newImage("images/editor/" .. prefix .. "loadHover.png")
	editor.images.saveOff_IMG = love.graphics.newImage("images/editor/" .. prefix .. "saveOff.png")
	editor.images.saveOn_IMG = love.graphics.newImage("images/editor/" .. prefix .. "saveOn.png")
	editor.images.saveHover_IMG = love.graphics.newImage("images/editor/" .. prefix .. "saveHover.png")

	editor.images.tilesetGround = love.graphics.newImage( "images/tilesets/" .. prefix .. "grounds.png" )
	editor.images.tilesetBackground = love.graphics.newImage( "images/tilesets/" .. prefix .. "background1.png" )

	editor.groundList = Ground:init()
end

-- called when editor is to be started:
function editor.start()
	print("Starting editor..." )
	mode = "editor"

	map = EditorMap:new()
	cam = EditorCam:new()

	love.mouse.setVisible( true )
	groundPanel = Panel:new( 1, 30, 15, 90 )


	local toolPanelWidth = love.graphics.getWidth()/Camera.scale-60
	toolPanel = Panel:new( 30, love.graphics.getHeight()/Camera.scale-16,
							 toolPanelWidth, 15 )
	-- right side:
	toolPanel:addClickable( 7, 3, function() editor.setTool("draw") end,
				editor.images.penOff_IMG,
				editor.images.penOn_IMG,
				editor.images.penHover_IMG)
	toolPanel:addClickable( 17, 3, function() editor.setTool("erase") end,
				editor.images.eraserOff_IMG,
				editor.images.eraserOn_IMG,
				editor.images.eraserHover_IMG)
	
	-- left side
	toolPanel:addClickable( toolPanelWidth - 17, 3,
				menu.startTransition( menu.initMain, true ),
				menu.images.exitOff_IMG,
				menu.images.exitOn_IMG)

	toolPanel:addClickable( toolPanelWidth - 27, 3,
				nil,
				editor.images.saveOff_IMG,
				editor.images.saveOn_IMG,
				editor.images.saveHover_IMG)

	toolPanel:addClickable( toolPanelWidth - 37, 3,
				nil,
				editor.images.loadOff_IMG,
				editor.images.loadOn_IMG,
				editor.images.loadHover_IMG)

	-- available tools:
	-- "draw", "erase"
	-- mabye later add "fill"
	editor.selectedTool = "draw"
	editor.selectedGround = editor.groundList[1]
	
	-- debug (loads test.dat)
	editor.loadFile()
end

-- called as long as editor is running:
function editor.update( dt )
	local clicked = love.mouse.isDown("l")
	local x, y = love.mouse.getPosition()
	local wX, wY = cam:screenToWorld( x, y )
	local hit = toolPanel:update( dt, x, y, clicked ) or groundPanel:update( dt, x, y, clicked )

	if not hit and clicked then
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
function editor.draw()

	cam:apply()

	map:drawGrid()
	map:drawBackground()
	map:drawGround()

	cam:free()

	toolPanel:draw()
	groundPanel:draw()
	
	local x, y = love.mouse.getPosition()
	local wX, wY = cam:screenToWorld( x, y )
	love.graphics.print(wX,10,10)
	love.graphics.print(wY,10,50)

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
