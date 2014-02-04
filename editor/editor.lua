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
Background = require("editor/background")
BgObject = require("editor/bgObject")
Object = require("editor/object")
EditorCam = require("editor/editorCam")

local map = nil
local cam = nil

local objectPanel
local bgObjectPanel
local toolPanel
local groundPanel
local backgroundPanel
local editPanel
local editBgPanel

local KEY_CLOSE = "escape"
local KEY_STAMP = "s"
local KEY_PEN = "d"
local KEY_BGPEN = "b"
local KEY_DELETE = "delete"
local KEY_TEST = "t"

-- called when loading game	
function editor.init()

	-- save all user made files in here:
	love.filesystem.createDirectory("mylevels")
	
	editor.images = {}

	local prefix = Camera.scale * 8
	editor.images.tilesetGround = love.graphics.newImage( "images/tilesets/" .. prefix .. "grounds.png" )
	--editor.images.tilesetBackground = love.graphics.newImage( "images/tilesets/" .. prefix .. "background1.png" )
	editor.images.tilesetBackground = love.graphics.newImage( "images/tilesets/" .. prefix .. "backgrounds.png" )
	editor.images.cell = love.graphics.newImage( "images/editor/" .. prefix .. "cell.png")
	editor.images.cell:setWrap('repeat', 'repeat')

	local tileSize = Camera.scale * 8
	editor.cellQuad = love.graphics.newQuad(0, 0, Camera.width+tileSize, Camera.height+tileSize, tileSize, tileSize)

	editor.images.fill = love.graphics.newImage( "images/editor/" .. prefix .. "fill.png")
	editor.fillQuad = love.graphics.newQuad(0, 0, tileSize*3, tileSize*3, tileSize*3, tileSize*3 )
	editor.images.pinLeft= love.graphics.newImage( "images/editor/" .. prefix .. "pinLeft.png")
	editor.images.pinRight= love.graphics.newImage( "images/editor/" .. prefix .. "pinRight.png")

	editor.groundList = Ground:init()
	editor.bgObjectList = BgObject:init()
	editor.objectList = Object:init()
	editor.backgroundList = Background:init()

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
	editor.toolsToolTips["editBg"] = "left mouse: select object, left + drag: move object"
end

function editor.createCellQuad()
	local tileSize = Camera.scale * 8
	editor.cellQuad = love.graphics.newQuad(0, 0, Camera.width/cam.zoom+tileSize,
							Camera.height/cam.zoom+tileSize, tileSize, tileSize)
end

-- called when editor is to be started:
function editor.start()
	print("Starting editor..." )
	mode = "editor"

	-- make sure to return to level after testing map!
	editor.active = true

	map = EditorMap:new( editor.backgroundList )
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
	x = x + 10
	toolPanel:addClickable( x, y, function() editor.setTool("bgPen") end,
				'LEPenOff',
				'LEPenOn',
				'LEPenHover',
				KEY_BGPEN .. " - Draw Tool: Draw tiles onto the background.")
	x = x + 10
	x = x + 10
	toolPanel:addClickable( x, y, function() editor.setTool("object") end,
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
	x = x +10
	toolPanel:addClickable( x, y, function() editor.setTool("bgObject") end,
				'LEStampOff',
				'LEStampOn',
				'LEStampHover',
				KEY_STAMP .. " - Stamp Tool: Select and place background objects.")
	x = x +10
	toolPanel:addClickable( x, y, function() editor.setTool("editBg") end,
				'LEEditOff',
				'LEEditOn',
				'LEEditHover',
				KEY_STAMP .. " - Stamp Tool: Select and place background objects.")
				
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
	toolPanel:addClickable( x, y, function() editor.saveFile() end,
				'LESaveOff',
				'LESaveOn',
				'LESaveHover',
				"Save the map.")
	x = x - 10
	toolPanel:addClickable( x, y, function() editor.loadFile() end,
				'LEOpenOff',
				'LEOpenOn',
				'LEOpenHover',
				"Load another map.")
	x = x - 10
	toolPanel:addClickable( x, y, function() editor.testMap() end,
				'LEPlayOff',
				'LEPlayOn',
				'LEPlayHover',
				KEY_TEST .. " - Test the map")


	-- Panel for choosing the ground type:
	groundPanel = Panel:new( 1, 30, 16, 90 )
	x,y = 8,7

	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[1] end,
				'LEGround1Off',
				'LEGround1On',
				'LEGround1Hover',
				"1 - draw concrete ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[2] end,
				'LEGround2Off',
				'LEGround2On',
				'LEGround2Hover',
				"2 - draw dirt ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[3] end,
				'LEGround3Off',
				'LEGround3On',
				'LEGround3Hover',
				"3 - draw grass ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[4] end,
				'LEGround4Off',
				'LEGround4On',
				'LEGround4Hover',
				"4 - draw stone ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[5] end,
				'LEGround5Off',
				'LEGround5On',
				'LEGround5Hover',
				"5 - draw wood ground" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[6] end,
				'LEGround6Off',
				'LEGround6On',
				'LEGround6Hover',
				"6 - draw bridges" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[7] end,
				'LESpikes1Off',
				'LESpikes1On',
				'LESpikes1Hover',
				"7 - draw grey spikes" )
	y = y + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[8] end,
				'LESpikes2Off',
				'LESpikes2On',
				'LESpikes2Hover',
				"8 - draw brown spikes" )

	-- Panel for choosing the background type:
	backgroundPanel = Panel:new( 1, 30, 16, 90 )
	x,y = 8,7

	backgroundPanel:addClickable( x, y, function() editor.setTool("bgPen")
										editor.currentBackground = editor.backgroundList[1] end,
				'LEGround1Off',
				'LEGround1On',
				'LEGround1Hover',
				"1 - draw concrete background" )
	y = y + 10
	backgroundPanel:addClickable( x, y, function() editor.setTool("bgPen")
										editor.currentBackground = editor.backgroundList[2] end,
				'LEGround2Off',
				'LEGround2On',
				'LEGround2Hover',
				"2 - draw soil background" )
	y = y + 10
	backgroundPanel:addClickable( x, y, function() editor.setTool("bgPen")
										editor.currentBackground = editor.backgroundList[3] end,
				'LEGround2Off',
				'LEGround2On',
				'LEGround2Hover',
				"3 - draw dark soil background" )

	editor.createBgObjectPanel()
	editor.createObjectPanel()

	editBgPanel = Panel:new( 0, 0, 3*12, 12)
	editBgPanel.visible = false

	x, y = 6, 6
	editBgPanel:addClickable( x, y, function() map:removeSelectedBgObject()
											editBgPanel.visible = false end,
				'LEDeleteOff',
				'LEDeleteOn',
				'LEDeleteHover',
				KEY_DELETE .. " - remove" )
	x = x + 10
	editBgPanel:addClickable( x, y, function() map:bgObjectLayerUp() end,
				'LELayerUpOff',
				'LELayerUpOn',
				'LELayerUpHover',
				"move up one layer" )
	x = x + 10
	editBgPanel:addClickable( x, y, function() map:bgObjectLayerDown() end,
				'LELayerDownOff',
				'LELayerDownOn',
				'LELayerDownHover',
				"move down one layer" )

	editPanel = Panel:new( 0, 0, 12, 12 )
	editPanel.visible = false

	x, y = 6, 6
	editPanel:addClickable( x, y, function() map:removeSelectedObject();
											editPanel.visible = false end,
				'LEDeleteOff',
				'LEDeleteOn',
				'LEDeleteHover',
				KEY_DELETE .. " - remove" )



	-- available tools:
	-- "pen", "bgObject"
	editor.currentTool = "pen"
	editor.currentGround = editor.groundList[1]
	editor.currentBackground = editor.backgroundList[1]
	editor.currentBgObject = editor.bgObjectList[1]

	love.graphics.setPointStyle( "smooth" )
	love.graphics.setPointSize( 6 )

	editor.loadFile()
end

function editor.resume()
	mode = "editor"
	shaders:resetDeathEffect()
	love.mouse.setVisible( true )
	love.graphics.setBackgroundColor(22,45,80)
end

function editor.createBgObjectPanel()

	local PADDING = 4

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

		-- Is this object higher than the others of this row?
		maxY = math.max( bBox.maxY, maxY )

		if x + bBox.maxX*8 > panelWidth then
			-- add the maximum height of the obejcts in this row, then continue:
			y = y + maxY*8 + PADDING
			x = PADDING

			maxY = -math.huge
		end

		bgObjectPanel:addBatchClickable( x, y, event, obj.batch, bBox.maxX*8, bBox.maxY*8, obj.name, page )

		x = x + bBox.maxX*8 + PADDING
	end
end

function editor.createObjectPanel()

	local PADDING = 4

	local panelWidth = love.graphics.getWidth()/Camera.scale - 40
	local panelHeight = love.graphics.getHeight()/Camera.scale - 23 - 14

	objectPanel = Panel:new( 20, 10, panelWidth, panelHeight )
	objectPanel.visible = false

	local x, y = PADDING, PADDING
	local page = 1
	local maxY = -math.huge
	for k, obj in ipairs( editor.objectList ) do
		if obj.vis[1] then
			local event = function()
				editor.currentObject = obj
				objectPanel.visible = false
			end

			-- Is this object higher than the others of this row?
			maxY = math.max( obj.height, maxY )

			if x + obj.width > panelWidth then
				-- add the maximum height of the obejcts in this row, then continue:
				y = y + maxY*8 + PADDING
				x = PADDING

				maxY = -math.huge
			end

			objectPanel:addClickableObject( x, y, event, obj, obj.name, page )


			x = x + obj.width/8 + PADDING
		end
	end
end

-- called as long as editor is running:
function editor:update( dt )
	self.toolTip.text = ""

	local clicked = love.mouse.isDown("l", "r")
	local x, y = love.mouse.getPosition()
	local wX, wY = cam:screenToWorld( x, y )

	if map.selectedBgObject and editBgPanel.visible then
		local ex, ey = cam:worldToScreen( map.selectedBgObject.drawX,
							map.selectedBgObject.drawY + map.selectedBgObject.height )
		editBgPanel:moveTo( ex/(Camera.scale), ey/(Camera.scale) + 3 )
	elseif map.selectedObject and editPanel.visible then
		local ex, ey = cam:worldToScreen( map.selectedObject.editorX,
							map.selectedObject.editorY + map.selectedObject.height )
		editPanel:moveTo( ex/(Camera.scale), ey/(Camera.scale) + 3 )
	end

	local hit = toolPanel:collisionCheck( x, y ) or
				( groundPanel.visible and groundPanel:collisionCheck( x, y ) ) or
				( backgroundPanel.visible and backgroundPanel:collisionCheck( x, y ) ) or
				( bgObjectPanel.visible and bgObjectPanel:collisionCheck(x, y) ) or
				( editBgPanel.visible and editBgPanel:collisionCheck(x, y) ) or
				( editPanel.visible and editPanel:collisionCheck(x, y) ) or
				( objectPanel.visible and objectPanel:collisionCheck(x, y) )

	if map.draggedBorderMarker then
		map:dragBorderMarker( wX, wY )
		hit = true
	elseif map:collisionCheckBorderMarker( wX, wY ) then
		hit = true
	end
	
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
					if self.currentTool == "pen" then
						map:line( tileX, tileY,
						self.lastTileX, self.lastTileY, false,
						function(x, y) 
							map:setGroundTile(x, y, self.currentGround, true ) end )
					else	-- bgPen
						local tX, tY = math.floor(tileX-0.5), math.floor(tileY-0.5)
						local sX, sY = math.floor(self.lastTileX-0.5), math.floor(self.lastTileY-0.5)
						map:line( tX+1, tY+1,
						sX+1, sY+1, true,
						function(x, y) map:setBackgroundTile(x, y, self.currentBackground, true ) end )
					end
				else
					if self.currentTool == "pen" then
						map:setGroundTile( tileX, tileY, self.currentGround, true )
					else 	-- bgPen
						local tX, tY = math.floor(tileX-0.5), math.floor(tileY-0.5)
						map:setBackgroundTile( tX, tY, self.currentBackground, true )
						map:setBackgroundTile( tX+1, tY, self.currentBackground, true )
						map:setBackgroundTile( tX, tY+1, self.currentBackground, true )
						map:setBackgroundTile( tX+1, tY+1, self.currentBackground, true )
					end
				end
			end
		elseif self.erasing then
			if tileX ~= self.lastTileX or tileY ~= self.lastTileY then
				if math.abs(tileX - self.lastTileX) > 1 or
					math.abs(tileX - self.lastTileY) > 1 then
					if self.currentTool == "pen" then
						map:line( tileX, tileY,
						self.lastTileX, self.lastTileY, false,
						function(x, y) map:eraseGroundTile(x, y, true ) end )
					else
						map:line( tileX, tileY,
						self.lastTileX, self.lastTileY, true,
						function(x, y) map:eraseBackgroundTile(x, y, true ) end )
					end
				else
					if self.currentTool == "pen" then
						map:eraseGroundTile( tileX, tileY, true )
					else
						map:eraseBackgroundTile( tileX, tileY, true )
					end
				end
			end
		end
		if (self.currentTool == "pen" or self.currentTool == "bgPen") and self.shift then
			self.drawLine = true
		elseif self.currentTool == "editBg" and self.dragging and
			(tileX ~= self.lastTileX or tileY ~= self.lastTileY) then
			map:dragBgObject( tileX, tileY )
		elseif self.currentTool == "edit" and self.dragging and
			(tileX ~= self.lastTileX or tileY ~= self.lastTileY) then
			map:dragObject( tileX, tileY )
		end
		self.lastTileX, self.lastTileY = tileX, tileY
	else
		-- mouse did hit a panel? Then check for a click:
		local hit = toolPanel:click( x, y, false ) or 
		( groundPanel.visible and groundPanel:click( x, y, false ) ) or
		( backgroundPanel.visible and backgroundPanel:click( x, y, false) ) or
		( editBgPanel.visible and editBgPanel:click( x, y, false) ) or 
		( editPanel.visible and editPanel:click( x, y, false) ) or 
		( bgObjectPanel.visible and bgObjectPanel:click( x, y, false ) ) or
		( objectPanel.visible and objectPanel:click( x, y, false ) )
	end

	if self.toolTip.text == "" and self.currentTool and not hit then
		self.setToolTip( self.toolsToolTips[self.currentTool] )
	end

	map:update( dt )

	toolPanel:update( dt )
	groundPanel:update( dt )
	editBgPanel:update( dt )
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
		local hit = toolPanel:collisionCheck( x, y ) or
				( groundPanel.visible and groundPanel:collisionCheck( x, y ) ) or
				( backgroundPanel.visible and backgroundPanel:collisionCheck( x, y ) ) or
				( bgObjectPanel.visible and bgObjectPanel:collisionCheck(x, y) ) or
				( editBgPanel.visible and editBgPanel:collisionCheck(x, y) ) or
				( editPanel.visible and editPanel:collisionCheck(x, y) ) or
				( objectPanel.visible and objectPanel:collisionCheck(x, y) )

		if not hit then
			if map:selectBorderMarker( wX, wY ) then
				hit = true
			end
		end

		local mouseOnCanvas = not hit

		if mouseOnCanvas then
			if self.currentTool == "pen" then

				if self.shift and self.lastClickX and self.lastClickY then
					-- draw a line
					map:line( tileX, tileY,
						self.lastClickX, self.lastClickY, false,
						function(x, y)
							map:setGroundTile(x, y, self.currentGround, true ) end )
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
			elseif self.currentTool == "bgPen" then
				if self.shift and self.lastClickX and self.lastClickY then
					-- draw a line
					map:line( tileX, tileY,
						self.lastClickX, self.lastClickY, true,
						function(x, y) map:setBackgroundTile(x, y, self.currentBackground, true ) end )
				elseif self.ctrl then
					map:startFillBackground( tileX, tileY, "set", self.currentBackground )
				else
					self.drawing = true

					local tX, tY = math.floor(tileX-0.5), math.floor(tileY-0.5)
					map:setBackgroundTile( tX, tY, self.currentBackground, true )
					map:setBackgroundTile( tX+1, tY, self.currentBackground, true )
					map:setBackgroundTile( tX, tY+1, self.currentBackground, true )
					map:setBackgroundTile( tX+1, tY+1, self.currentBackground, true )
				end
				self.lastClickX, self.lastClickY = tileX, tileY
			elseif self.currentTool == "bgObject" then
				map:addBgObject( tileX-1, tileY-1, self.currentBgObject )
			elseif self.currentTool == "object" then
				map:addObject( tileX, tileY, self.currentObject.name )
				--editor.setTool("edit")
			elseif self.currentTool == "editBg" then
				if map:selectBgObjectAt( tileX, tileY ) then
					editBgPanel.visible = true
					self.dragging = true
				else
					editBgPanel.visible = false
				end
			elseif self.currentTool == "edit" then
				if map:selectObjectAt( tileX, tileY ) then
					editPanel.visible = true
					self.dragging = true
				else
					editPanel.visible = false
				end
			end
		else
			-- a panel was hit: check if any button was pressed:
			local hit = toolPanel:click( x, y, true ) or
				( groundPanel.visible and groundPanel:click( x, y, true ) ) or
				( backgroundPanel.visible and backgroundPanel:click( x, y, true ) ) or
				( editBgPanel.visible and editBgPanel:click( x, y, true) ) or 
				( editPanel.visible and editPanel:click( x, y, true) ) or 
				( bgObjectPanel.visible and bgObjectPanel:click( x, y, true ) ) or
				( objectPanel.visible and objectPanel:click( x, y, true ) )
		end
	elseif button == "r" then


		local wX, wY = cam:screenToWorld( x, y )
		local tileX = math.floor(wX/(Camera.scale*8))
		local tileY = math.floor(wY/(Camera.scale*8))
		local hit = toolPanel:collisionCheck( x, y ) or
				( groundPanel.visible and groundPanel:collisionCheck( x, y ) ) or
				( backgroundPanel.visible and backgroundPanel:collisionCheck( x, y ) ) or
				( bgObjectPanel.visible and bgObjectPanel:collisionCheck(x, y) ) or
				( editBgPanel.visible and editBgPanel:collisionCheck(x, y) ) or
				( editPanel.visible and editPanel:collisionCheck(x, y) ) or
				( objectPanel.visible and objectPanel:collisionCheck(x, y) )

		local mouseOnCanvas = not hit

		if mouseOnCanvas then
			if self.currentTool == "pen" then

				if self.shift and self.lastClickX and self.lastClickY then
					-- draw a line
					map:line( tileX, tileY,
					self.lastClickX, self.lastClickY, false,
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
			elseif self.currentTool == "bgPen" then
				if self.shift and self.lastClickX and self.lastClickY then
					-- draw a line
					map:line( tileX, tileY,
					self.lastClickX, self.lastClickY, true,
					function(x, y) map:eraseBackgroundTile(x, y, true ) end, true )
				elseif self.ctrl then
					-- fill the area
					--map:startFillGround( tileX, tileY, "erase", nil )
					map:startFillBackground( tileX, tileY, "erase", nil )
				else
					-- start erasing
					self.erasing = true
					-- force to erase one tile:
					local tX, tY = math.floor(tileX-0.5), math.floor(tileY-0.5)
					map:eraseBackgroundTile( tX, tY, true )
					map:eraseBackgroundTile( tX+1, tY, true )
					map:eraseBackgroundTile( tX, tY+1, true )
					map:eraseBackgroundTile( tX+1, tY+1, true )
				end
				self.lastClickX, self.lastClickY = tileX, tileY
			elseif self.currentTool == "bgObject" then
				map:removeBgObjectAt( tileX, tileY )
			elseif self.currentTool == "object" then
				map:removeObjectAt( tileX, tileY )
			end
		end
	end
end

function editor:mousereleased( button, x, y )
	if button == "m" then
		cam:releaseMouseAnchor()
	elseif button == "l" then
		if map.draggedBorderMarker then
			map:dropBorderMarker()
		end
		self.drawing = false
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
	elseif key == KEY_TEST then
		editor.testMap()
	elseif key == KEY_DELETE then
		if map.selectedBgObject then
			map:removeSelectedBgObject()
		end
	elseif tonumber(key) then		-- let user choose the ground type using the number keys
		local num = tonumber(key)
		if editor.currentTool == "pen" then
			if editor.groundList[num] then
				editor.currentGround = editor.groundList[num]
			end
		elseif editor.currentTool == "bgPen" then	
			if editor.backgroundList[num] then
				editor.currentBackground = editor.backgroundList[num]
			end
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

	map:drawObjects()

	map:drawForeground()

	map:drawBoundings()

	if self.mouseOnCanvas then

		love.graphics.setColor(0,0,0,128)
		local rX = math.floor(wX/(tileSize))*tileSize
		local rY = math.floor(wY/(tileSize))*tileSize
		if self.currentBgObject and self.currentTool == "bgObject" then
			love.graphics.draw( self.currentBgObject.batch, rX - tileSize, rY - tileSize)
		elseif self.currentObject and self.currentTool == "object" then
			--love.graphics.draw( self.currentObject.obj, rX, rY)
			local w, h = self.currentObject.width, self.currentObject.height
			self.currentObject.vis[1]:draw( rX + w*0.5, rY + h*0.5, true )
		elseif self.currentTool == "pen" then
			if self.ctrl then
				love.graphics.draw( editor.images.fill, editor.fillQuad, rX-tileSize, rY-tileSize )
			else
				love.graphics.rectangle( 'fill',rX,rY, tileSize, tileSize )
			end
		elseif self.currentTool == "bgPen" then
			local tX = math.floor(rX - tileSize/2) - tileSize*0.3
			local tY = math.floor(rY - tileSize/2) - tileSize*0.3
			if self.ctrl then
				love.graphics.draw( editor.images.fill, editor.fillQuad, rX-tileSize, rY-tileSize )
			else
			love.graphics.rectangle( 'fill', tX, tY, tileSize*1.6, tileSize*1.6 )
		end
		end

		-- draw the line:
		if self.drawLine and self.lastClickX and self.lastClickY then
			local sX = math.floor(self.lastClickX)*tileSize
			local sY = math.floor(self.lastClickY)*tileSize
			love.graphics.setColor( 255,188,128,200 )
			love.graphics.line( rX+4*Camera.scale, rY+4*Camera.scale, sX+4*Camera.scale, sY+4*Camera.scale )

			love.graphics.setColor( 255,188,128,255)
			love.graphics.point( rX + 4*Camera.scale, rY+4*Camera.scale )
			love.graphics.point( sX + 4*Camera.scale, sY+4*Camera.scale )
			love.graphics.setColor(255,255,255,255)
		end
	end

	if DEBUG then
		map:drawBackgroundTypes( cam )
	end
	
	cam:free()

	if editBgPanel.visible then
		editBgPanel:draw()
	elseif editPanel.visible then
		editPanel:draw()
	end

	toolPanel:draw()

	if objectPanel.visible then
		objectPanel:draw()
	elseif bgObjectPanel.visible then
		bgObjectPanel:draw()
	elseif groundPanel.visible then
		groundPanel:draw()
	elseif backgroundPanel.visible then
		backgroundPanel:draw()
	end
	
	love.graphics.print( self.toolTip.text, self.toolTip.x, self.toolTip.y )
	
	--[[love.graphics.print(wX,10,10)
	love.graphics.print(wY,10,50)--]]

	love.graphics.print( love.timer.getFPS(), 20, love.graphics.getHeight() - 40 )

end

function editor.setTool( tool )
	map:selectNoBgObject()
	map:selectNoObject()
	editor.currentTool = tool
	bgObjectPanel.visible = false
	objectPanel.visible = false
	editPanel.visible = false
	editBgPanel.visible = false
	groundPanel.visible = false
	backgroundPanel.visible = false
	if tool == "bgObject" then
		bgObjectPanel.visible = true
	elseif tool == "object" then
		objectPanel.visible = true
	elseif tool == "pen" then
		groundPanel.visible = true
	elseif tool == "bgPen" then
		backgroundPanel.visible = true
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

function editor.testMap()
	editor.saveFile( "test.dat", "" )

	menu.startTransition( menu.startGame( "test.dat" ), false )()
end

------------------------------------
-- Saving and Loading maps:
------------------------------------
-- Note: loading maps into the editor is slightly different
-- from loading them for the game.

-- displays all file names and lets user choose one of them:
--
--
local FILE_HEADER = [[
BANDANA LEVEL
----------------------------------------
File created with Bandana level editor.
To play the level, put it into the 'userlevels'
subdirectory. To edit it, place this file into
the 'mylevels' directory.
]]
--
function editor.loadList()
	list = love.filesystem.getDirectoryList( "userlevels/")
end

function editor.saveFile( fileName, testFile )
	local fullName = "mylevels/" .. (fileName or "bkup.dat")
	if testFile then
		fullName = "test.dat"
	end

	print("Attempting to save as '" .. fullName .. "'")

	if love.filesystem.isFile( fullName ) then
		print( "\tWarning: file exists! Replacing..." )
		-- TODO:
		-- Add message box here, let the user choose to overwrite or not.
	end

	if map then
		local content = FILE_HEADER

		content = content .. map:dimensionsToString() .. "\n"
		
		content = content .. "Background:\n"
		content = content .. map:backgroundToString()
		content = content .. "endBackground\n\n"

		content = content .. "Ground:\n"
		content = content .. map:groundToString()
		content = content .. "endGround\n\n"

		content = content .. "BgObjects:\n"
		content = content .. map:backgroundObjectsToString()
		content = content .. "endBgObjects\n\n"

		content = content .. "Objects:\n"
		content = content .. map:objectsToString()
		content = content .. "endObjects\n\n"
		love.filesystem.write( fullName, content )
	else
		print("\tError: no map!")
	end
end

function editor.loadFile( fileName, testFile )
	local fullName = "mylevels/" .. (fileName or "bkup.dat")
	if testFile then
		fullName = "test.dat"
	end
	map = EditorMap:loadFromFile( fullName ) or map
	cam:jumpTo(math.floor(map.width/2), math.floor(map.height/2))
end

return editor
