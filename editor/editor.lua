-------------------------------------
-- Level-editor main interface:
-------------------------------------
-- load
-- save
-- upload

local editor = {}

Panel = require("editor/panel")
--local Map = require("editor/editorMap")
local Ground = require("editor/ground")
local Background = require("editor/background")
local BgObject = require("editor/bgObject")
-- Object = require("editor/object")
local EditorCam = require("editor/editorCam")
require("editor/msgBox")

local map = nil
local cam = nil

local objectPanel 
local bgObjectPanel
local toolPanel
local menuPanel
local groundPanel
local backgroundPanel
--local editPanel
--local editBgPanel
local propertiesPanel
local loadPanel
local savePanel

local panelsWithShortcuts

local KEY_CLOSE = "escape"
local KEY_STAMP = "s"
local KEY_PEN = "d"
local KEY_BGPEN = "b"
local KEY_BGSTAMP = "f"
local KEY_EDIT = "e"
local KEY_DELETE = "delete"

local KEY_NEW = "f1"
local KEY_OPEN = "f2"
local KEY_SAVE = "f3"
local KEY_QUIT = "escape"
local KEY_TEST = "f4"

-- called when loading game	
function editor.init()

	-- save all user made files in here:
	love.filesystem.createDirectory("mylevels")
	
	editor.images = {}

	local prefix = Camera.scale * 8
	editor.images.tilesetGround = love.graphics.newImage( "images/tilesets/" .. prefix .. "grounds.png" )
	editor.images.tilesetBackground = love.graphics.newImage( "images/tilesets/" .. prefix .. "backgrounds.png" )
	editor.images.cell = love.graphics.newImage( "images/editor/" .. prefix .. "cell.png")
	editor.images.cell:setWrap('repeat', 'repeat')

	local tileSize = Camera.scale * 8
	editor.cellQuad = love.graphics.newQuad(0, 0, Camera.width+tileSize, Camera.height+tileSize, tileSize, tileSize)

	editor.images.fill = love.graphics.newImage( "images/editor/" .. prefix .. "fill.png")
	editor.fillQuad = love.graphics.newQuad(0, 0, tileSize*3, tileSize*3, tileSize*3, tileSize*3 )
	editor.images.pinLeft= love.graphics.newImage( "images/editor/" .. prefix .. "pinLeft.png")
	editor.images.pinRight= love.graphics.newImage( "images/editor/" .. prefix .. "pinRight.png")

	editor.images.highlight = love.graphics.newImage( "images/editor/" .. prefix .. "buttonHighlight.png")

	editor.groundList = Ground:init()
	editor.bgObjectList = BgObject:init()
	editor.objectList = {}
	for name, class in pairs(objectClasses) do
		local new = class:New()
		if new.isInEditor then
			new:init()
			table.insert(editor.objectList, new)
		end
	end

	editor.objectProperties = {}
	
	
	--editor.objectList, editor.objectProperties = Object:init()
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
end

function editor.createCellQuad()
	local tileSize = Camera.scale * 8
	editor.cellQuad = love.graphics.newQuad(0, 0, Camera.width/cam.zoom+tileSize,
							Camera.height/cam.zoom+tileSize, tileSize, tileSize)
end

function editor.createPropertiesPanel()
	propertiesPanel:clearAll()

	if map.selectedObject then
		propertiesPanel.visible = true
		local x, y = 13, 13
		propertiesPanel:addClickable( x, y, function() map:removeSelectedObject();
										propertiesPanel.visible = false end,
				'LEDeleteOff',
				'LEDeleteOn',
				'LEDeleteHover',
				"remove", nil, nil, KEY_DELETE, true)

		x,y = 8, 26
		if map.selectedObject.properties then
			for name, p in pairs(map.selectedObject.properties) do
				propertiesPanel:addProperty( name, x, y, p, map.selectedObject )
				y = y + 16
			end
		end
	elseif map.selectedBgObject then
		propertiesPanel.visible = true
		local x, y = 13, 13
		propertiesPanel:addClickable( x, y, function() map:removeSelectedBgObject()
			propertiesPanel.visible = false end,
			'LEDeleteOff',
			'LEDeleteOn',
			'LEDeleteHover',
			"remove", nil, nil, KEY_DELETE, true)
		x = x + 10
		propertiesPanel:addClickable( x, y, function() map:bgObjectLayerUp() end,
			'LELayerUpOff',
			'LELayerUpOn',
			'LELayerUpHover',
			"move up one layer", nil, nil, nil, true)
		x = x + 10
		propertiesPanel:addClickable( x, y, function() map:bgObjectLayerDown() end,
			'LELayerDownOff',
			'LELayerDownOn',
			'LELayerDownHover',
			"move down one layer", nil, nil, nil, true)

	end
end

-- called when editor is to be started:
function editor.start()

	editor.init()

	print("Starting editor..." )
	mode = "editor"

	-- make sure to return to level after testing map!
	editor.active = true

	map = Map:new( editor.backgroundList )
	cam = EditorCam:new() -- -Camera.scale*8*map.MAP_SIZE/2, -Camera.scale*8*map.MAP_SIZE/2 )

	love.mouse.setVisible( true )

	local toolPanelWidth = 10*9
	toolPanel = Panel:new( 15, love.graphics.getHeight()/Camera.scale-40,
							 toolPanelWidth, 16, true )
	local x,y = 20,15
	toolPanel:addClickable( x, y, function() editor.setTool("pen") end,
				'LEPenOff',
				'LEPenOn',
				'LEPenHover',
				"Draw Tool: Draw tiles onto the canvas.", nil,nil, KEY_PEN,true )
	x = x + 5
	x = x + 10
	toolPanel:addClickable( x, y, function() editor.setTool("bgPen") end,
				'LEPenOff',
				'LEPenOn',
				'LEPenHover',
				"Draw Tool: Draw tiles onto the background.", nil,nil,KEY_BGPEN,true )
	x = x + 5
	x = x + 10
	toolPanel:addClickable( x, y, function() editor.setTool("object") end,
				'LEObjectOff',
				'LEObjectOn',
				'LEObjectHover',
				"Object tool: Select and place foreground objects.", nil,nil,KEY_STAMP,true )
	x = x +10
	toolPanel:addClickable( x, y, function() editor.setTool("bgObject") end,
				'LEStampOff',
				'LEStampOn',
				'LEStampHover',
				"Stamp Tool: Select and place background objects.", nil,nil,KEY_BGSTAMP,true )
	x = x +5
	x = x +10 toolPanel:addClickable( x, y, function() editor.setTool("edit") end,
				'LEEditOff',
				'LEEditOn',
				'LEEditHover',
				KEY_STAMP .. " - Stamp Tool: Select and place background objects.", nil,nil,KEY_EDIT,true )
	x = x +10
	--[[
	toolPanel:addClickable( x, y, function() editor.setTool("editBg") end,
				'LEEditOff',
				'LEEditOn',
				'LEEditHover',
				KEY_STAMP .. " - Stamp Tool: Select and place background objects.")]]
				
	--[[toolPanel:addClickable( x, y, function() editor.setTool("erase") end,
				'LEEraserOff',
				'LEEraserOn',
				'LEEraserHover',
				"Eraser - remove tiles or objects.")]]
	menuPanel = Panel:new( love.graphics.getWidth()/Camera.scale - toolPanelWidth - 23,
							love.graphics.getHeight()/Camera.scale-40,
							toolPanelWidth, 16 )
	x, y = 20, 15
	
	menuPanel:addClickable( x, y, menu.startTransition( menu.initMain, true ),
				'LEExitOff',
				'LEExitOn',
				'LEExitHover',
				"Close editor and return to main menu.", nil,nil,KEY_QUIT,true )
				
	x = x + 10
	x = x + 5

	menuPanel:addClickable( x, y, function() editor.newMapAttempt() end,
				'LENewOff',
				'LENewOn',
				'LENewHover',
				"New map" , nil,nil,KEY_NEW,true )
	x = x + 10
	x = x + 5
	menuPanel:addClickable( x, y, function() editor.loadFileList() end,
				'LEOpenOff',
				'LEOpenOn',
				'LEOpenHover',
				"Load another map.", nil,nil,KEY_OPEN,true )
	x = x + 10
	menuPanel:addClickable( x, y, function() editor.saveFileStart() end,
				'LESaveOff',
				'LESaveOn',
				'LESaveHover',
				"Save the map.", nil,nil,KEY_SAVE,true )
	x = x + 10
	x = x + 5

	menuPanel:addClickable( x, y, function() editor.testMapAttempt() end,
				'LEPlayOff',
				'LEPlayOn',
				'LEPlayHover',
				KEY_TEST .. " - Test the map", nil,nil,KEY_TEST,true )
				
	-- Panel for choosing the ground type:
	local w = 160
	groundPanel = Panel:new( love.graphics.getWidth()/2/Camera.scale - w/2, 4, w, 32, true )
	x,y = 20, 13

	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[1] end,
				'LEGround1Off',
				'LEGround1On',
				'LEGround1Hover',
				"draw concrete ground", nil, nil, "1" )
	x = x + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[2] end,
				'LEGround2Off',
				'LEGround2On',
				'LEGround2Hover',
				"draw dirt ground", nil, nil, "2" )
	x = x + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[3] end,
				'LEGround3Off',
				'LEGround3On',
				'LEGround3Hover',
				"draw grass ground", nil, nil, "3" )
	x = x + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[4] end,
				'LEGround4Off',
				'LEGround4On',
				'LEGround4Hover',
				"draw stone ground", nil, nil, "4" )
	x = x + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[5] end,
				'LEGround5Off',
				'LEGround5On',
				'LEGround5Hover',
				"draw wood ground", nil, nil, "5" )
	x = x + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[6] end,
				'LEGround6Off',
				'LEGround6On',
				'LEGround6Hover',
				"draw bridges", nil, nil, "6" )
	x = x + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[7] end,
				'LESpikes1Off',
				'LESpikes1On',
				'LESpikes1Hover',
				"draw grey spikes", nil, nil, "7" )
	x = x + 10
	groundPanel:addClickable( x, y, function() editor.setTool("pen")
										editor.currentGround = editor.groundList[8] end,
				'LESpikes2Off',
				'LESpikes2On',
				'LESpikes2Hover',
				"draw brown spikes", nil, nil, "8" )

	-- Panel for choosing the background type:
	backgroundPanel = Panel:new( love.graphics.getWidth()/2/Camera.scale - w/2, 4, w, 32, true )
	x,y = 20, 13

	backgroundPanel:addClickable( x, y, function() editor.setTool("bgPen")
										editor.currentBackground = editor.backgroundList[1] end,
				'LEGround1Off',
				'LEGround1On',
				'LEGround1Hover',
				"draw concrete background", nil, nil, "1" )
	x = x + 10
	backgroundPanel:addClickable( x, y, function() editor.setTool("bgPen")
										editor.currentBackground = editor.backgroundList[2] end,
				'LEGround2Off',
				'LEGround2On',
				'LEGround2Hover',
				"draw soil background", nil, nil, "2" )
	x = x + 10
	backgroundPanel:addClickable( x, y, function() editor.setTool("bgPen")
										editor.currentBackground = editor.backgroundList[3] end,
				'LEGround2Off',
				'LEGround2On',
				'LEGround2Hover',
				"draw dark soil background", nil, nil, "3" )

	editor.createBgObjectPanel()
	editor.createObjectPanel()

	local panelX = love.graphics.getWidth()/Camera.scale - 64
	local panelHeight = love.graphics.getHeight()/Camera.scale - 64
	propertiesPanel = Panel:new( panelX, 16, 48, panelHeight )
	propertiesPanel.visible = false

	local x = love.graphics.getWidth()/3/Camera.scale
	local y = love.graphics.getHeight()/3/Camera.scale
	local panelWidth = x
	local panelHeight = y
	loadPanel = Panel:new( x, y, panelWidth, panelHeight )
	loadPanel.visible = false
	savePanel = Panel:new( x, y, panelWidth, panelHeight )
	savePanel.visible = false
	
	-- available tools:
	-- "pen", "bgObject"
	editor.currentTool = "pen"
	editor.currentGround = editor.groundList[1]
	editor.currentBackground = editor.backgroundList[1]
	editor.currentBgObject = editor.bgObjectList[1]

	love.graphics.setPointStyle( "smooth" )
	love.graphics.setPointSize( 6 )
	
	panelsWithShortcuts = {toolPanel, menuPanel, propertiesPanel}

	editor.loadFile()
end

function editor.resume()
	mode = "editor"
	shaders:resetDeathEffect()
	love.mouse.setVisible( true )
	love.graphics.setBackgroundColor(22,45,80)
end

function editor.createBgObjectPanel()

	local PADDING = 1
	local BORDER_PADDING = 10

	local panelWidth = love.graphics.getWidth()/Camera.scale - 32
	local panelHeight = love.graphics.getHeight()/Camera.scale - 64

	bgObjectPanel = Panel:new( 16, 16, panelWidth, panelHeight )
	bgObjectPanel.visible = false

	local x, y = BORDER_PADDING, BORDER_PADDING --PADDING, PADDING
	local page = 1
	local maxY = -math.huge
	local currentCategory
	for k, obj in ipairs( editor.bgObjectList ) do

		if not currentCategory then
			-- start with the first object's category:
			currentCategory = obj.category_major
		end

		local event = function()
			editor.currentBgObject = obj
			bgObjectPanel.visible = false
		end

		local bBox = obj.bBox

		-- Is this object higher than the others of this row?
		maxY = math.max( bBox.maxY, maxY )

		if currentCategory ~= obj.category_major then
			currentCategory = obj.category_major
			y = BORDER_PADDING
			page = page +1
			x = BORDER_PADDING
			maxY = -math.huge
		else

		if x + bBox.maxX*8 > panelWidth then
			-- add the maximum height of the obejcts in this row, then continue:
			y = y + maxY*8 + PADDING
			if y + bBox.maxY*8 + 8 > panelHeight then
				y = BORDER_PADDING
				page = page +1
			end
			x = BORDER_PADDING

			maxY = -math.huge
		end
	end

		bgObjectPanel:addBatchClickable( x, y, event, obj.batch, bBox.maxX*8, bBox.maxY*8, obj.tag, page )

		x = x + bBox.maxX*8 + PADDING
	end
end

function editor.createObjectPanel()

	local PADDING = 3
	local BORDER_PADDING = 10

	local panelWidth = love.graphics.getWidth()/Camera.scale - 64
	local panelHeight = love.graphics.getHeight()/Camera.scale - 64

	objectPanel = Panel:new( 32, 16, panelWidth, panelHeight )
	objectPanel.visible = false

	local x, y = BORDER_PADDING, BORDER_PADDING
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

			if x + obj.width/8 + 8 > panelWidth then
				-- add the maximum height of the obejcts in this row, then continue:
				y = y + maxY/8 + PADDING
				if y + obj.height/8 + 8 > panelHeight then
					y = BORDER_PADDING
					page = page + 1
				end
				x = BORDER_PADDING

				maxY = -math.huge
			end


			objectPanel:addClickableObject( x, y, event, obj, obj.tag, page )
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

	--[[
	if map.selectedBgObject and editBgPanel.visible then
		local ex, ey = cam:worldToScreen( map.selectedBgObject.drawX,
							map.selectedBgObject.drawY + map.selectedBgObject.height )
		editBgPanel:moveTo( ex/(Camera.scale), ey/(Camera.scale) + 3 )
	elseif map.selectedObject and editPanel.visible then
		local ex, ey = cam:worldToScreen( map.selectedObject.editorX,
							map.selectedObject.editorY + map.selectedObject.height )
		editPanel:moveTo( ex/(Camera.scale), ey/(Camera.scale) + 3 )
	end]]
	local hit = ( msgBox.active and msgBox:collisionCheck( x, y ) ) or
				( loadPanel.visible and loadPanel:collisionCheck( x, y ) ) or
				( savePanel.visible and savePanel:collisionCheck( x, y ) ) or
				( menuPanel.visible and menuPanel:collisionCheck( x, y ) ) or
				( toolPanel.visible and toolPanel:collisionCheck( x, y ) ) or
				( groundPanel.visible and groundPanel:collisionCheck( x, y ) ) or
				( backgroundPanel.visible and backgroundPanel:collisionCheck( x, y ) ) or
				( bgObjectPanel.visible and bgObjectPanel:collisionCheck(x, y) ) or
				--( editBgPanel.visible and editBgPanel:collisionCheck(x, y) ) or
				--( editPanel.visible and editPanel:collisionCheck(x, y) ) or
				( propertiesPanel.visible and propertiesPanel:collisionCheck(x, y) ) or
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

	if self.mouseOnCanvas and not msgBox.active then
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
						--local tX, tY = math.floor(tileX-0.5), math.floor(tileY-0.5)
						--local sX, sY = math.floor(self.lastTileX-0.5), math.floor(self.lastTileY-0.5)
						map:line( tileX, tileY,
						self.lastTileX, self.lastTileY, false,
						function(x, y) map:setBackgroundTile(x, y, self.currentBackground, true ) end )
					end
				else
					if self.currentTool == "pen" then
						map:setGroundTile( tileX, tileY, self.currentGround, true )
					else 	-- bgPen
						--local tX, tY = math.floor(tileX-0.5), math.floor(tileY-0.5)
						--map:setBackgroundTile( tX, tY, self.currentBackground, true )
						--map:setBackgroundTile( tX+1, tY, self.currentBackground, true )
						--map:setBackgroundTile( tX, tY+1, self.currentBackground, true )
						--map:setBackgroundTile( tX+1, tY+1, self.currentBackground, true )
						map:setBackgroundTile( tileX, tileY, self.currentBackground, true )
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
						self.lastTileX, self.lastTileY, false,
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
		elseif self.currentTool == "edit" and self.dragging and
			(tileX ~= self.lastTileX or tileY ~= self.lastTileY) then
			if not map:dragObject( tileX, tileY ) then
				map:dragBgObject( tileX, tileY )
			end
		end
		self.lastTileX, self.lastTileY = tileX, tileY
	else
		-- mouse did hit a panel? Then check for a click:
		local hit = ( msgBox.active and msgBox:click( x, y, nil ) ) or
			( loadPanel.visible and loadPanel:click( x, y, nil, msgBox.active ) ) or
			( savePanel.visible and savePanel:click( x, y, nil, msgBox.active ) ) or
			( menuPanel.visible and menuPanel:click( x, y, nil, msgBox.active ) ) or
			( toolPanel.visible and toolPanel:click( x, y, nil, msgBox.active ) ) or
			( groundPanel.visible and groundPanel:click( x, y, nil, msgBox.active ) ) or
			( backgroundPanel.visible and backgroundPanel:click( x, y, nil, msgBox.active) ) or
			--( editBgPanel.visible and editBgPanel:click( x, y, false) ) or 
			--( editPanel.visible and editPanel:click( x, y, false) ) or 
			( bgObjectPanel.visible and bgObjectPanel:click( x, y, nil, msgBox.active ) ) or
			( propertiesPanel.visible and propertiesPanel:click( x, y, nil, msgBox.active ) ) or
			( objectPanel.visible and objectPanel:click( x, y, nil, msgBox.active ) )
	end

	if self.toolTip.text == "" and self.currentTool and not hit then
		self.setToolTip( self.toolsToolTips[self.currentTool] )
	end

	map:update( dt )

	menuPanel:update( dt )
	toolPanel:update( dt )
	groundPanel:update( dt )
	--editBgPanel:update( dt )
	--editPanel:update( dt )
	propertiesPanel:update( dt )
	if loadPanel.visible then
		loadPanel:update( dt )
	end
	if savePanel.visible then
		savePanel:update( dt )
	end
	if msgBox.active then
		msgBox:update( dt )
	end
	if objectPanel.visible then
		objectPanel:update( dt )
	end
	if bgObjectPanel.visible then
		bgObjectPanel:update( dt )
	end
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
		local hit = ( msgBox.active and msgBox:collisionCheck( x, y ) ) or
				( loadPanel.visible and loadPanel:collisionCheck( x, y ) ) or
				( savePanel.visible and savePanel:collisionCheck( x, y ) ) or
				( menuPanel.visible and menuPanel:collisionCheck( x, y ) ) or
				( toolPanel.visible and toolPanel:collisionCheck( x, y ) ) or
				( groundPanel.visible and groundPanel:collisionCheck( x, y ) ) or
				( backgroundPanel.visible and backgroundPanel:collisionCheck( x, y ) ) or
				( bgObjectPanel.visible and bgObjectPanel:collisionCheck(x, y) ) or
				--( editBgPanel.visible and editBgPanel:collisionCheck(x, y) ) or
				--( editPanel.visible and editPanel:collisionCheck(x, y) ) or
				( propertiesPanel.visible and propertiesPanel:collisionCheck(x, y) ) or
				( objectPanel.visible and objectPanel:collisionCheck(x, y) )

		if not hit then
			if map:selectBorderMarker( wX, wY ) then
				hit = true
			end
		end

		local mouseOnCanvas = not hit

		if mouseOnCanvas and not msgBox.active and not loadPanel.visible and not savePanel.visible then
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
						self.lastClickX, self.lastClickY, false,
						function(x, y) map:setBackgroundTile(x, y, self.currentBackground, true ) end )
				elseif self.ctrl then
					map:startFillBackground( tileX, tileY, "set", self.currentBackground )
				else
					self.drawing = true

					--local tX, tY = math.floor(tileX-0.5), math.floor(tileY-0.5)
					map:setBackgroundTile( tileX, tileY, self.currentBackground, true )
					--map:setBackgroundTile( tX+1, tY, self.currentBackground, true )
					--map:setBackgroundTile( tX, tY+1, self.currentBackground, true )
					--map:setBackgroundTile( tX+1, tY+1, self.currentBackground, true )
				end
				self.lastClickX, self.lastClickY = tileX, tileY
			elseif self.currentTool == "bgObject" and self.currentBgObject then
				map:addBgObject( tileX-1, tileY-1, self.currentBgObject )
			elseif self.currentTool == "object" and self.currentObject then
				map:addObject( tileX, tileY, self.currentObject.tag )
				--editor.setTool("edit")
			elseif self.currentTool == "edit" then
				map:selectNoObject()
				map:selectNoBgObject()
				propertiesPanel.visible = false
				--editPanel.visible = false
				--editBgPanel.visible = false
				if map:selectObjectAt( tileX, tileY ) then
					--editPanel.visible = true
					self.dragging = true
					editor.createPropertiesPanel()
				elseif map:selectBgObjectAt( tileX, tileY ) then
					--editBgPanel.visible = true
					self.dragging = true
					editor.createPropertiesPanel()
				--else
					--editBgPanel.visible = false
					--editPanel.visible = false
				end
			end
		else
			-- a panel was hit: check if any button was pressed:
			local hit = ( msgBox.active and msgBox:click( x, y, "l" ) ) or
				( loadPanel.visible and loadPanel:click( x, y, "l", msgBox.active ) ) or
				( savePanel.visible and savePanel:click( x, y, "l", msgBox.active ) ) or
				( menuPanel.visible and menuPanel:click( x, y, "l",
								msgBox.active or loadPanel.visible or savePanel.visible) ) or
				( toolPanel.visible and toolPanel:click( x, y, "l",
								msgBox.active or loadPanel.visible or savePanel.visible) ) or
				( groundPanel.visible and groundPanel:click( x, y, "l",
								msgBox.active or loadPanel.visible or savePanel.visible) ) or
				( backgroundPanel.visible and backgroundPanel:click( x, y, "l",
								msgBox.active or loadPanel.visible or savePanel.visible) ) or
				--( editBgPanel.visible and editBgPanel:click( x, y, true) ) or 
				--( editPanel.visible and editPanel:click( x, y, true) ) or 
				( propertiesPanel.visible and propertiesPanel:click(x, y, "l",
								msgBox.active or loadPanel.visible or savePanel.visible) ) or
				( bgObjectPanel.visible and bgObjectPanel:click( x, y, "l",
								msgBox.active or loadPanel.visible or savePanel.visible) ) or
				( objectPanel.visible and objectPanel:click( x, y, "l",
								msgBox.active or loadPanel.visible or savePanel.visible) )
		end
	elseif button == "r" then

		local wX, wY = cam:screenToWorld( x, y )
		local tileX = math.floor(wX/(Camera.scale*8))
		local tileY = math.floor(wY/(Camera.scale*8))
		local hit = ( msgBox.active and msgBox:collisionCheck( x, y ) ) or
				( toolPanel.visible and toolPanel:collisionCheck( x, y ) ) or
				( menuPanel.visible and menuPanel:collisionCheck( x, y ) ) or
				( groundPanel.visible and groundPanel:collisionCheck( x, y ) ) or
				( backgroundPanel.visible and backgroundPanel:collisionCheck( x, y ) ) or
				( bgObjectPanel.visible and bgObjectPanel:collisionCheck(x, y) ) or
				--( editBgPanel.visible and editBgPanel:collisionCheck(x, y) ) or
				--( editPanel.visible and editPanel:collisionCheck(x, y) ) or
				( propertiesPanel.visible and propertiesPanel:collisionCheck(x, y ) ) or
				( objectPanel.visible and objectPanel:collisionCheck(x, y) )

		local mouseOnCanvas = not hit

		if mouseOnCanvas and not msgBox.active and
					not loadPanel.visible and not savePanel.visible then
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
					self.lastClickX, self.lastClickY, false,
					function(x, y) map:eraseBackgroundTile(x, y, true ) end, true )
				elseif self.ctrl then
					-- fill the area
					--map:startFillGround( tileX, tileY, "erase", nil )
					map:startFillBackground( tileX, tileY, "erase", nil )
				else
					-- start erasing
					self.erasing = true
					-- force to erase one tile:
					--[[local tX, tY = math.floor(tileX-0.5), math.floor(tileY-0.5)
					map:eraseBackgroundTile( tX, tY, true )
					map:eraseBackgroundTile( tX+1, tY, true )
					map:eraseBackgroundTile( tX, tY+1, true )
					map:eraseBackgroundTile( tX+1, tY+1, true )]]
					map:eraseBackgroundTile( tileX, tileY, true )
				end
				self.lastClickX, self.lastClickY = tileX, tileY
			elseif self.currentTool == "object" or self.currentTool == "bgObject" then
				if not map:removeObjectAt( tileX, tileY ) then
					map:removeBgObjectAt( tileX, tileY )
				end
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

local toConvert = {
			"end", "end_air", "end_dirt", "end_fall", "end_spikes", "end_wall",
		}
		-- add levels 1 through 21:
		for k = 1, 9 do
			table.insert( toConvert, "l0" .. k )
		end
		for k = 10, 21 do
			table.insert( toConvert, "l" .. k )
		end

local converted = {}


function editor.keypressed( key, repeated )

	if key == "f10" then
				-- DEBUG:
		-- toConvert = {"l01"}
		for k, v in ipairs( toConvert ) do
			if not converted[v] then
			map = Map:convert( "levels/bkup/" .. v .. ".dat" )
			--editor.saveFileNow( v .. ".dat" )
			converted[v] = true
			break
		end
		end
		return
	end
	if editor.activeInputPanel and editor.activeInputPanel.visible then
		editor.activeInputPanel:keypressed( key )
		return
	end

	local panelsToCheck = panelsWithShortcuts	
	if msgBox.active then
		panelsToCheck = {msgBox.panel}
	elseif loadPanel.visible then
		panelsToCheck = {loadPanel}
	elseif savePanel.visible then
		panelsToCheck = {savePanel}
	end
		
	for i, panel in pairs(panelsToCheck) do
		if panel.visible then
			for k, v in pairs(panel.pages[0]) do
				if v.shortcut and v.shortcut == key then
					v.event()
				end
			end
		end
	end



	if key == KEY_CLOSE and bgObjectPanel.visible then
		bgObjectPanel.visible = false
		editor.currentBgObject = editor.currentBgObject or editor.bgObjectList[1]
	--elseif key == KEY_PEN then
	--	editor.setTool("pen")
	--elseif key == KEY_STAMP then
	--	editor.setTool("bgObject")
	--elseif key == KEY_TEST then
	--	editor.testMapAttempt()
	--elseif key == KEY_DELETE then
	--	if map.selectedBgObject then
	--		map:removeSelectedBgObject()
	--	elseif map.selectedObject then
	--		map:removeSelectedObject()
	--	end
	--	propertiesPanel.visible = false
	
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


	love.graphics.setColor( 255, 255, 255, 255 )
	if self.currentTool == "object" or self.currentTool == "pen" then
		love.graphics.setColor( 120, 120, 120, 255 )
	end
	map:drawBackground()

	love.graphics.setColor( 255, 255, 255, 255 )
	if self.currentTool == "bgObject" or self.currentTool == "bgPen" then
		love.graphics.setColor( 120, 120, 120, 255 )
	end
	map:drawGround()

	map:drawForeground()

	map:drawObjects()
	map:drawLines()

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
			if self.currentObject.tag == "LineHook" and map.openLineHook then
				love.graphics.line( rX+4*Camera.scale, rY+4*Camera.scale,
					(map.openLineHook.tileX*8+4)*Camera.scale,
					(map.openLineHook.tileY*8+4)*Camera.scale )
			end
		elseif self.currentTool == "pen" then
			if self.ctrl then
				love.graphics.draw( editor.images.fill, editor.fillQuad, rX-tileSize, rY-tileSize )
			else
				love.graphics.rectangle( 'fill',rX,rY, tileSize, tileSize )
			end
		elseif self.currentTool == "bgPen" then
			--local tX = math.floor(rX - tileSize/2) - tileSize*0.3
			--local tY = math.floor(rY - tileSize/2) - tileSize*0.3
			if self.ctrl then
				love.graphics.draw( editor.images.fill, editor.fillQuad, rX-tileSize, rY-tileSize )
			else
				love.graphics.rectangle( 'fill',rX,rY, tileSize, tileSize )
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
--[[
	if editBgPanel.visible then
		editBgPanel:draw()
	elseif editPanel.visible then
		editPanel:draw()
	end]]

	toolPanel:draw()
	menuPanel:draw()

	if loadPanel.visible then
		loadPanel:draw()
	elseif savePanel.visible then
		savePanel:draw()
	elseif objectPanel.visible then
		objectPanel:draw()
	elseif bgObjectPanel.visible then
		bgObjectPanel:draw()
	elseif groundPanel.visible then
		groundPanel:draw()
	elseif backgroundPanel.visible then
		backgroundPanel:draw()
	elseif propertiesPanel.visible then
		propertiesPanel:draw()
	end

	if msgBox.active then
		msgBox:draw()
	end
	
	love.graphics.print( self.toolTip.text, self.toolTip.x, self.toolTip.y )
	
	--[[love.graphics.print(wX,10,10)
	love.graphics.print(wY,10,50)--]]

	love.graphics.print( love.timer.getFPS(), 20, love.graphics.getHeight() - 40 )

end

function editor.setTool( tool )
	map:selectNoBgObject()
	map:selectNoObject()
	propertiesPanel.visible = false
	editor.currentTool = tool
	bgObjectPanel.visible = false
	objectPanel.visible = false
	--editPanel.visible = false
	--editBgPanel.visible = false
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
	if editor.activeInputPanel and editor.activeInputPanel.visible then
		editor.activeInputPanel:textinput( letter )
	end
end

function editor.testMapAttempt()
	local foundPlayer, foundFlag
	for k, obj in ipairs( map.objectList ) do
		if obj.tag == "Player" then
			foundPlayer = true
		elseif obj.tag == "Exit" then
			foundFlag = true
		end
	end

	if not foundPlayer then
		msgBox:new("No player found on map.\nTest with default start position?", editor.testMapNow)
		return
	end
	if not foundFlag then
		msgBox:new("No flag found on map.\nTest without it?", editor.testMapNow)
		return
	end
	editor.testMapNow()
end

function editor.testMapNow()
	editor.saveFileNow( "test.dat", "" )

	menu.startTransition( menu.startGame( "test.dat" ), false )()
end

function editor.newMapAttempt()
	msgBox:new( "Create new map?\nAnswering yes will destroy all changes for the current map.",
				editor.newMapNow, nil )
end

function editor.newMapNow()
	map = Map:new( editor.backgroundList )
	cam.zoom = 1
	cam:jumpTo(math.floor(map.width/2), math.floor(map.height/2))
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
function editor.loadFileList()
	local list = love.filesystem.getDirectoryItems( "mylevels/")
	
	loadPanel:clearAll()

	loadPanel:addClickable( loadPanel.width - 12, 12, editor.closeFileList,
		"LEDeleteOff",
		"LEDeleteOn",
		"LEDeleteHover",
		"Cancel", nil, nil, "escape", true )
	loadPanel:addLabel( 8, 8, "Load file:" )

	local x, y = 14,14
	local page = 1
	for k, v in ipairs(list) do
		if v:match("(.*%.dat)$") then
			loadPanel:addClickableLabel( x, y,
				function()
					editor.loadFile( v )
					loadPanel.visible = false
				end,
				loadPanel.width - 34, v, page )
			y = y + 6
			if y > loadPanel.height - 16 then
				y = 14
				page = page + 1
			end
		end
	end

	loadPanel.visible = true
end

function editor.closeFileList()
	loadPanel.visible = false
end

function editor.saveFileStart()
	savePanel:clearAll()

	savePanel:addClickable( savePanel.width - 12, savePanel.height - 12, editor.closeSaveFilePanel,
		"LEDeleteOff",
		"LEDeleteOn",
		"LEDeleteHover",
		"Cancel", nil, nil, "escape", true )
	savePanel:addClickable( savePanel.width - 22, savePanel.height - 12,
		function()
			editor.saveFileAttempt( map.name .. ".dat" )
			editor.closeSaveFilePanel()
		end,
		"LEAcceptOff",
		"LEAcceptOn",
		"LEAcceptHover",
		"Cancel", nil, nil, "return", true )


	savePanel:addLabel( 8, 8, "Level name:" )
	savePanel:addLabel( 8, 20, "Short description:" )

	local setMapName = function( txt )
		map.name = txt or ""	
	end
	local setMapDescription = function( txt )
		map.description = txt or ""	
	end
	local chars = "[0-9a-zA-Z%-]"
	savePanel:addInputBox( 10, 13, savePanel.width - 20, 1, map.name or "", setMapName, 30, chars )
	savePanel:addInputBox( 10, 25, savePanel.width - 20, 20*Camera.scale/fontSmall:getHeight(), map.description or "", setMapDescription, 200 )

	savePanel.visible = true
end

function editor.closeSaveFilePanel()
	savePanel.visible = false
end

function editor.saveFileAttempt( fileName, testFile )
	fileName = fileName or "bkup.dat"
	local fullName = "mylevels/" .. fileName 
	if love.filesystem.isFile( fullName ) then
		local ev = function()
			editor.saveFileNow( fileName, testFile )
		end
		msgBox:new( "The file '" .. fileName .. "' already exists.\nOverwrite?", ev )
	else
		editor.saveFileNow( fileName, testFile )
	end
end


-- Note: the following does NOT prompt if there's an existing file of the
-- same file name. To do that, call saveFileAttempt instead.
function editor.saveFileNow( fileName, testFile )
	fileName = fileName or "bkup.dat"

	if #fileName:match("(.*).dat"):gsub(" ", "") == 0 then
		print("Warning: Empty file name!")
		msgBox:new("Warning: Cannot save!\nFilename must not be empty.", function() end )
		return
	end

	local fullName = "mylevels/" .. fileName
	if testFile then
		fullName = "test.dat"
	end

	print("Saving as '" .. fullName .. "'")

	if map then
		local content = FILE_HEADER

		content = content .. map:dimensionsToString() .. "\n"

		content = content .. "Description:\n"
		content = content .. map:descriptionToString()
		content = content .. "endDescription\n\n"
		
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
	map = Map:loadFromFile( fullName ) or map
	cam.zoom = 1
	cam:jumpTo(math.floor(map.width/2), math.floor(map.height/2))
end

return editor
