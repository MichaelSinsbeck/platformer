-------------------------------------
-- Level-editor main interface:
-------------------------------------

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
local uploadStatusPanel

local uploadStatusTimer = 0
local savePanelCallbackEvent

local toolButtons = {}
local groundButtons = {}
local backgroundButtons = {}

local propertiesPanelHeight

local panelsWithShortcuts

local KEY_CLOSE = "escape"
local KEY_STAMP = "s"
local KEY_PEN = "g"
local KEY_BGPEN = "b"
local KEY_BGSTAMP = "f"
local KEY_EDIT = "e"
local KEY_DELETE = "delete"
local KEY_DUPLICATE = "d"
local KEY_UPLOAD = "u"

local KEY_NEW = "f1"
local KEY_OPEN = "f2"
local KEY_SAVE = "f3"
local KEY_QUIT = "escape"
local KEY_MENU = "escape"
local KEY_TEST = "f4"

-- called when loading game	
function editor.init()

	-- save all files made by this user into the mylevels folder:
	love.filesystem.createDirectory("mylevels")
	
	local tileSize = Camera.scale * 8
	editor.cellQuad = love.graphics.newQuad(0, 0, Camera.width+tileSize, Camera.height+tileSize, tileSize, tileSize)
	editor.fillQuad = love.graphics.newQuad(0, 0, tileSize*3, tileSize*3, tileSize*3, tileSize*3 )

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
	editor.toolsToolTips["bgObject"] = "left mouse: add current background object, ctrl to add multiple times"
	editor.toolsToolTips["edit"] = "left mouse: select object, left + drag: move object"
end

function editor.createCellQuad()
	local tileSize = Camera.scale * 8
	editor.cellQuad = love.graphics.newQuad(0, 0, Camera.width/cam.zoom+tileSize,
							Camera.height/cam.zoom+tileSize, tileSize, tileSize)
end

function editor.createPropertiesPanel()
	propertiesPanel:clearAll()

	if #map.selectedObjects > 0 then
		propertiesPanel.visible = true
		local x, y = 13, 13
		propertiesPanel:addClickable( x, y, function() map:removeAllSelected()
			propertiesPanel.visible = false end,
			'LEDeleteOff',
			'LEDeleteOn',
			'LEDeleteHover',
			"remove", nil, KEY_DELETE, true)

		if #map.selectedObjects == 1 then
			if map.selectedObjects[1].isBackgroundObject then
				x,y = 13, 26
				propertiesPanel:addClickable( x, y, function() map:bgObjectLayerUp() end,
					'LELayerUpOff',
					'LELayerUpOn',
					'LELayerUpHover',
					"move up one layer", nil, nil, true)
				x = x + 10
				propertiesPanel:addClickable( x, y, function() map:bgObjectLayerDown() end,
					'LELayerDownOff',
					'LELayerDownOn',
					'LELayerDownHover',
					"move down one layer", nil, nil, true)
			else
				x,y = 8, 26
				if map.selectedObjects[1].properties then
					for name, p in pairs(map.selectedObjects[1].properties) do
						propertiesPanel:addProperty( name, x, y, p, map.selectedObjects[1] )
						y = y + 16
					end
				end
			end
		end

		local noBg, bg = false, false
		for k, v in pairs( map.selectedObjects ) do
			if v.isBackgroundObject then
				bg = true
			else
				noBg = true
			end
		end
		if not noBg or not bg then
			propertiesPanel:addClickable( 16, propertiesPanelHeight - 16,
				editor.duplicateSelection,
				'LEDuplicateOff',
				'LEDuplicateOn',
				'LEDuplicateHover',
				"Duplicate selection", nil, KEY_DUPLICATE, true)
		end
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

	toolButtons = {}

	local toolPanelHeight = 10*10
	toolPanel = Panel:new( 0, 16, 16, toolPanelHeight)
	
	local x,y = 16,16
	local b
	b = toolPanel:addClickable( x, y, function() editor.setTool("pen") end,
				'LEPenOff',
				'LEPenOn',
				'LEPenHover',
				"Draw Tool: Draw tiles onto the canvas", nil, KEY_PEN,true )
	toolButtons["pen"] = b
	--x = x + 5
	--x = x + 10
	y = y + 12
	b = toolPanel:addClickable( x, y, function() editor.setTool("bgPen") end,
				'LEPenOff',
				'LEPenOn',
				'LEPenHover',
				"Background tile tool: Draw tiles onto the background", nil,KEY_BGPEN,true )
	toolButtons["bgPen"] = b
	--x = x + 5
	--x = x + 10
	y = y + 12
	b = toolPanel:addClickable( x, y, function()
					if objectPanel.visible then
						editor.closeObjectPanel()
					else
						editor.setTool("object")
					end
				end,
				'LEObjectOff',
				'LEObjectOn',
				'LEObjectHover',
				"Object tool: Select and place foreground objects", nil,KEY_STAMP,true )
	toolButtons["object"] = b
	--x = x +10
	y = y + 12
	b = toolPanel:addClickable( x, y, function()
					if bgObjectPanel.visible then
						editor.closeBgObjectPanel()
					else
						editor.setTool("bgObject")
					end
				end,
				'LEStampOff',
				'LEStampOn',
				'LEStampHover',
				"Background object tool: Select and place background objects", nil,KEY_BGSTAMP,true )
	toolButtons["bgObject"] = b
	--x = x +5
	--x = x +10
	y = y + 12
	b = toolPanel:addClickable( x, y, function() editor.setTool("edit") end,
				'LEEditOff',
				'LEEditOn',
				'LEEditHover',
				"Edit Tool: Select, move and edit object properties",nil,KEY_EDIT,true )
	y = y + 16
	toolButtons["edit"] = b

	toolPanel:addClickable( x, y,
				function()
					menuPanel.visible = false
					editor.testMapAttempt()
				end,
				'LEPlayOff',
				'LEPlayOn',
				'LEPlayHover',
				"Test the map",nil, KEY_TEST, true )

	y = y + 16
	toolPanel:addClickable( x, y,
				function()
					menuPanel.visible = true
					bgObjectPanel.visible = false
					objectPanel.visible = false
					savePanel.visible = false
					loadPanel.visible = false
				end,
				'LEMenuOff',
				'LEMenuOn',
				'LEMenuHover',
				"Editor menu",nil,KEY_MENU,true )
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

	--menuPanel = Panel:new( -10 + toolPanelWidth - 2, -7,	toolPanelWidth, 16 )
	
	local menuWidth, menuHeight = 16*3, 64
	menuPanel = Panel:new( (love.graphics.getWidth()/Camera.scale - menuWidth)/2,
					(love.graphics.getHeight()/Camera.scale - menuHeight)/2,
					menuWidth, menuHeight )
	menuPanel.visible = false
	x, y = 18, 16
	menuPanel:addClickable( x, y,
				function()
					menuPanel.visible = false
					editor.newMapAttempt()
				end,
				'LENewOff',
				'LENewOn',
				'LENewHover',
				"New map" , nil, KEY_NEW, true )
	x = x + 12
	menuPanel:addClickable( x, y,
				function()
					menuPanel.visible = false
					editor.attemptUpload()
				end,
				'LEUploadOff',
				'LEUploadOn',
				'LEUploadHover',
				"Share level online" , nil, KEY_UPLOAD, true )
	y = y + 16
	x = 18
	menuPanel:addClickable( x, y,
				function()
					menuPanel.visible = false
					editor.loadFileListAttempt()
				end,
				'LEOpenOff',
				'LEOpenOn',
				'LEOpenHover',
				"Load another map", nil, KEY_OPEN, true )
	x = x + 12
	menuPanel:addClickable( x, y,
				function()
					menuPanel.visible = false
					editor.saveFileStart()
				end,
				'LESaveOff',
				'LESaveOn',
				'LESaveHover',
				"Save the map", nil, KEY_SAVE, true )
	y = y + 16
	x = 24
	menuPanel:addClickable( x, y, editor.closeAttempt,
				'LEExitOff',
				'LEExitOn',
				'LEExitHover',
				"Close editor and return to main menu", nil, KEY_QUIT, true )
				
	-- Panel for choosing the ground type:
	local w = 32
	local h = 8*10 + 2*16
	--groundPanel = Panel:new( love.graphics.getWidth()/2/Camera.scale - w/2, 4, w, 32 )
	groundPanel = Panel:new( love.graphics.getWidth()/Camera.scale - w, 17, w, h )
	x,y = 16, 16

	b = groundPanel:addClickable( x, y, function() editor.setTool("pen")
										groundPanel:deactivateAll()
										groundButtons[1]:setActive(true)
										editor.currentGround = editor.groundList[1] end,
				'LEGround1Off',
				'LEGround1On',
				'LEGround1Hover',
				"draw concrete ground", nil, "1" )
	groundButtons[1] = b
  y = y + 10
	b = groundPanel:addClickable( x, y, function() editor.setTool("pen")
										groundPanel:deactivateAll()
										groundButtons[2]:setActive(true)
										editor.currentGround = editor.groundList[2] end,
				'LEGround2Off',
				'LEGround2On',
				'LEGround2Hover',
				"draw dirt ground", nil, "2" )
	groundButtons[2] = b
  y = y + 10
	b = groundPanel:addClickable( x, y, function() editor.setTool("pen")
										groundPanel:deactivateAll()
										groundButtons[3]:setActive(true)
										editor.currentGround = editor.groundList[3] end,
				'LEGround3Off',
				'LEGround3On',
				'LEGround3Hover',
				"draw grass ground", nil,"3" )
	groundButtons[3] = b
  y = y + 10
	b = groundPanel:addClickable( x, y, function() editor.setTool("pen")
										groundPanel:deactivateAll()
										groundButtons[4]:setActive(true)
										editor.currentGround = editor.groundList[4] end,
				'LEGround4Off',
				'LEGround4On',
				'LEGround4Hover',
				"draw stone ground", nil, "4" )
	groundButtons[4] = b
  y = y + 10
	b = groundPanel:addClickable( x, y, function() editor.setTool("pen")
										groundPanel:deactivateAll()
										groundButtons[5]:setActive(true)
										editor.currentGround = editor.groundList[5] end,
				'LEGround5Off',
				'LEGround5On',
				'LEGround5Hover',
				"draw wood ground", nil, "5" )
	groundButtons[5] = b
  y = y + 10
	b = groundPanel:addClickable( x, y, function() editor.setTool("pen")
										groundPanel:deactivateAll()
										groundButtons[6]:setActive(true)
										editor.currentGround = editor.groundList[6] end,
				'LEGround6Off',
				'LEGround6On',
				'LEGround6Hover',
				"draw bridges", nil, "6" )
	groundButtons[6] = b
  y = y + 10
	b = groundPanel:addClickable( x, y, function() editor.setTool("pen")
										groundPanel:deactivateAll()
										groundButtons[7]:setActive(true)
										editor.currentGround = editor.groundList[7] end,
				'LESpikes1Off',
				'LESpikes1On',
				'LESpikes1Hover',
				"draw grey spikes", nil, "7" )
	groundButtons[7] = b
  y = y + 10
	b = groundPanel:addClickable( x, y, function() editor.setTool("pen")
										groundPanel:deactivateAll()
										groundButtons[8]:setActive(true)
										editor.currentGround = editor.groundList[8] end,
				'LESpikes2Off',
				'LESpikes2On',
				'LESpikes2Hover',
				"draw brown spikes", nil, "8" )
	groundButtons[8] = b

	-- Panel for choosing the background type:
	--backgroundPanel = Panel:new( love.graphics.getWidth()/2/Camera.scale - w/2, 4, w, 32 )
	--backgroundPanel = Panel:new( -9, 17, 32, h )
	h = 3*10 + 2*16
	backgroundPanel = Panel:new( love.graphics.getWidth()/Camera.scale - w, 17, w, h )
	x,y = 16, 16

	b = backgroundPanel:addClickable( x, y, function() editor.setTool("bgPen")
										backgroundPanel:deactivateAll()
										backgroundButtons[1]:setActive(true)
										editor.currentBackground = editor.backgroundList[1] end,
				'LEBGround1Off',
				'LEBGround1On',
				'LEBGround1Hover',
				"draw concrete background", nil, "1" )
	backgroundButtons[1] = b
  y = y + 10
	b = backgroundPanel:addClickable( x, y, function() editor.setTool("bgPen")
										backgroundPanel:deactivateAll()
										backgroundButtons[2]:setActive(true)
										editor.currentBackground = editor.backgroundList[2] end,
				'LEBGround2Off',
				'LEBGround2On',
				'LEBGround2Hover',
				"draw soil background", nil, "2" )
	backgroundButtons[2] = b
  y = y + 10
	b = backgroundPanel:addClickable( x, y, function() editor.setTool("bgPen")
										backgroundPanel:deactivateAll()
										backgroundButtons[3]:setActive(true)
										editor.currentBackground = editor.backgroundList[3] end,
				'LEBGround2Off',
				'LEBGround2On',
				'LEBGround2Hover',
				"draw dark soil background", nil, "3" )
	backgroundButtons[3] = b

	editor.createBgObjectPanel()
	editor.createObjectPanel()

	w = 48
	local panelX = love.graphics.getWidth()/Camera.scale - w
	propertiesPanelHeight = love.graphics.getHeight()/Camera.scale - 32
	propertiesPanel = Panel:new( panelX, 17, w, propertiesPanelHeight )
	propertiesPanel.visible = false

	local x = love.graphics.getWidth()/3/Camera.scale
	local y = love.graphics.getHeight()/3/Camera.scale
	local panelWidth = x
	local panelHeight = y + 16
	loadPanel = Panel:new( x, y, panelWidth, panelHeight )
	loadPanel.visible = false
	savePanel = Panel:new( x, y, panelWidth, panelHeight )
	savePanel.visible = false

	x = love.graphics.getWidth()/Camera.scale/2 - 48
	y = love.graphics.getHeight()/Camera.scale - 32 - 8
	uploadStatusPanel = Panel:new( x, y, 96, 32 )
	uploadStatusPanel.visible = false
	editor.uploadInProgress = false
	
	-- available tools:
	-- "pen", "bgObject"
	editor.setTool("pen")
	editor.currentGround = editor.groundList[1]
	editor.currentBackground = editor.backgroundList[1]
	backgroundPanel:deactivateAll()
	backgroundButtons[1]:setActive(true)
	groundPanel:deactivateAll()
	groundButtons[1]:setActive(true)
	--editor.currentBgObject = editor.bgObjectList[1]
	--groundPanel.pages[0][1]:setSelected( true )
	--backgroundPanel.pages[0][1]:setSelected( true )

	love.graphics.setPointStyle( "smooth" )
	love.graphics.setPointSize( 6 )
	
	panelsWithShortcuts = {toolPanel, propertiesPanel, groundPanel, backgroundPanel}

	--editor.loadFile()
	cam.zoom = 1
	cam:jumpTo(math.floor(map.width/2), math.floor(map.height/2))
end

function editor.resume()
	mode = "editor"
	shaders:resetDeathEffect()
	love.mouse.setVisible( true )
	love.graphics.setBackgroundColor(22,45,80)
end

function editor.createBgObjectPanel()

	local PADDING = 0
	local BORDER_PADDING = 10

	local panelWidth = love.graphics.getWidth()/Camera.scale - 32
	local panelHeight = love.graphics.getHeight()/Camera.scale - 64

	bgObjectPanel = Panel:new(-- 0, 16, panelWidth, panelHeight )
		(love.graphics.getWidth()/Camera.scale-panelWidth)*0.5,
		(love.graphics.getHeight()/Camera.scale-panelHeight)*0.5,
		panelWidth, panelHeight )
	bgObjectPanel.visible = false

	local x, y = BORDER_PADDING, BORDER_PADDING --PADDING, PADDING
	local page = 1
	local maxY = -math.huge
	local currentCategory
	for k, category in pairs( editor.bgObjectList ) do
		for i, obj in ipairs( category ) do
			bgObjectPanel:addBatchClickable( 8 + (8+PADDING)*obj.panelX,
					8 + (8+PADDING)*obj.panelY,
					nil, obj, 8, 8, obj.tag, page )
		end
		page = page + 1	-- own page for each category
		--x = x + bBox.maxX*8 + PADDING
	end

	-- Add "end" button
	bgObjectPanel:addClickable( panelWidth - 13, panelHeight - 18, editor.closeBgObjectPanel,
		"LEAcceptOff",
		"LEAcceptOn",
		"LEAcceptHover",
		"Accept selection", 0, KEY_BGSTAMP, true )
					
end

function editor.closeBgObjectPanel()
	bgObjectPanel.visible = false
	local selected = bgObjectPanel:getSelected()
	editor.currentBgObjects = {}
	for k, p in pairs( selected ) do
		table.insert( editor.currentBgObjects, {x=p.x, y=p.y, obj=p.obj} )
	end

	editor.sortSelectedObjects()
end

function editor.closeObjectPanel()
	objectPanel.visible = false
	local selected = objectPanel:getSelected()
	editor.currentObjects = {}
	for k, button in pairs( selected ) do
		table.insert( editor.currentObjects, {x=button.x, y=button.y, obj=button.obj} )
	end

	editor.sortSelectedObjects()
end


-- This function calculates tile offsets for multiple selected
-- background objects:
function editor.sortSelectedObjects()
	local found = true
	local currentTileX, currentTileY = 0, 0

	local t = editor.currentObjects
	
	if editor.currentTool == "bgObject" then
		t = editor.currentBgObjects
	end
	if not t then return end
	-- sort by x:
	repeat
		found = false
		local minX = math.huge
	
		-- out of all remaining tiles, find the ones which are
		-- furthest to the left:
		for k, o in pairs( t ) do
			if not o.tileX then
				minX = math.min( minX, o.x )
				found = true
			end
		end
		
		-- if any remaining tiles were found, then all the ones
		-- which have the same x value as the lowest one should
		-- be added to the current column.
		for k, o in pairs( t ) do
			if minX == o.x then
				o.tileX = currentTileX
			end
		end
		currentTileX = currentTileX + 1
	until found == false

	-- sort by y:
	repeat
		found = false
		local minY = math.huge
		
		for k, o in pairs( t ) do
			if not o.tileY then
				minY = math.min( minY, o.y )
				found = true
			end
		end

		for k, o in pairs( t ) do
			if minY == o.y then
				o.tileY = currentTileY
			end
		end
		currentTileY = currentTileY + 1
	until found == false
end

function editor.createObjectPanel()

	local PADDING = 3
	local BORDER_PADDING = 10

	local panelWidth = love.graphics.getWidth()/Camera.scale - 64
	local panelHeight = love.graphics.getHeight()/Camera.scale - 64

	objectPanel = Panel:new(
		(love.graphics.getWidth()/Camera.scale-panelWidth)*0.5,
		(love.graphics.getHeight()/Camera.scale-panelHeight)*0.5,
		panelWidth, panelHeight )
	objectPanel.visible = false

	local x, y = BORDER_PADDING, BORDER_PADDING
	local page = 1
	local maxY = -math.huge
	local scale = Camera.scale
	local dx,dy = -math.huge, -math.huge
	for k, obj in ipairs( editor.objectList ) do
		if obj.vis[1] then
		local w,h = obj:getPreviewSize()
		dx = math.max(dx,w/scale)
		dy = math.max(dy,h/scale)
		end
	end
	for k, obj in ipairs( editor.objectList ) do
		if obj.vis[1] then
			local width, height = obj:getPreviewSize()
			--[[local event = function()
				editor.currentObject = obj
				objectPanel.visible = false
			end]]

			-- Is this object higher than the others of this row?
			if x + dx + 8 > panelWidth then
				y = y + dy + PADDING
				if y + dy + 8 > panelHeight then
					y = BORDER_PADDING
					page = page + 1
				end
				x = BORDER_PADDING
			end
			
			objectPanel:addClickableObject( x, y, nil, obj, obj.tag, page )
			x = x + dx + PADDING
						
			--[[maxY = math.max( height, maxY )

			if x + width/scale + 8 > panelWidth then
				-- add the maximum height of the obejcts in this row, then continue:
				y = y + maxY/scale + PADDING
				if y + height/scale + 8 > panelHeight then
					y = BORDER_PADDING
					page = page + 1
				end
				x = BORDER_PADDING

				maxY = -math.huge
			end
			
			--print(obj.tag .. ': ' .. obj:getPreviewSize())
			objectPanel:addClickableObject( x + 0.5*width/scale, y, nil, obj, obj.tag, page )
			x = x + width/scale + PADDING]]
		end
	end

	-- Add "end" button
	objectPanel:addClickable( panelWidth - 13, panelHeight - 18, editor.closeObjectPanel,
		"LEAcceptOff",
		"LEAcceptOn",
		"LEAcceptHover",
		"Accept selection", 0, KEY_STAMP, true )
end

-- called as long as editor is running:
function editor:update( dt )
	self.toolTip.text = ""

	local clicked = love.mouse.isDown("l", "r")
	local x, y = love.mouse.getPosition()
	local wX, wY = cam:screenToWorld( x, y )

	if objectPanel.visible then
		objectPanel:unPreviewAll()
	elseif bgObjectPanel.visible then
		bgObjectPanel:unPreviewAll()
	end

	if editor.selectBox then
		map:unPreviewAll()		-- removes box selection highlight
	end


	if msgBox.visible then msgBox:unhighlightAll() end
	if loadPanel.visible then loadPanel:unhighlightAll() end
	if savePanel.visible then savePanel:unhighlightAll() end
	if menuPanel.visible then menuPanel:unhighlightAll() end
	if bgObjectPanel.visible then bgObjectPanel:unhighlightAll() end
	if objectPanel.visible then objectPanel:unhighlightAll() end
	if toolPanel.visible then toolPanel:unhighlightAll() end
	if groundPanel.visible then groundPanel:unhighlightAll() end
	if backgroundPanel.visible then backgroundPanel:unhighlightAll() end
	if propertiesPanel.visible then propertiesPanel:unhighlightAll() end

	local hit = false
	if msgBox.visible then
		hit = true
		msgBox:collisionCheck( x, y )
	else
		if loadPanel.visible then
			hit = true
			loadPanel:collisionCheck( x, y )
		elseif savePanel.visible then
			hit = true
			savePanel:collisionCheck( x, y )
		elseif menuPanel.visible then
			menuPanel:collisionCheck( x, y )
			hit = true
		else
			if toolPanel.visible then
				hit = hit or toolPanel:collisionCheck( x, y )
			end
			if groundPanel.visible then
				hit = hit or groundPanel:collisionCheck( x, y )
			end
			if backgroundPanel.visible then
				hit = hit or backgroundPanel:collisionCheck( x, y )
			end
			if bgObjectPanel.visible then
				hit = hit or bgObjectPanel:collisionCheck(x, y)
			end
			if propertiesPanel.visible then
				hit = hit or propertiesPanel:collisionCheck(x, y)
			end
			if objectPanel.visible then
				hit = hit or objectPanel:collisionCheck(x, y)
			end
		end
	end

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

	if self.mouseOnCanvas and not msgBox.visible then
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
			map:dragObject( tileX, tileY )
				--map:dragBgObject( tileX, tileY )
		end
		self.lastTileX, self.lastTileY = tileX, tileY
	--else
		-- mouse did hit a panel? Then check for a click:
		--[[local hit = ( msgBox.active and msgBox:click( x, y, nil ) ) or
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
			( objectPanel.visible and objectPanel:click( x, y, nil, msgBox.active ) )]]

	end
	if editor.selectBox then
		editor.selectBox.eX, editor.selectBox.eY = x, y
		-- Highlight buttons which are under the selection box:
		if objectPanel.visible then
			-- Pretend there was a "click" at multiple coordinates in the
			-- selected area. The step between the clicks is small enough
			-- to make sure every tile will be hit at least once:
			local points = editor.createBoxSelectPoints( Camera.scale*8 )
			for k, p in pairs(points) do
				button = objectPanel:addToSelectionClick( p.x, p.y, false )
				if button then
					if button.obj then	-- only selct buttons that represent an object
						button:setSelectionPreview(true)
					end
				end
			end
		elseif bgObjectPanel.visible then
			local points = editor.createBoxSelectPoints( Camera.scale*8 )
			for k, p in pairs(points) do
				button = bgObjectPanel:addToSelectionClick( p.x, p.y, false )
				if button then
					if button.obj then	-- only selct buttons that represent an object
						button:setSelectionPreview(true)
					end
				end
			end
		elseif self.mouseOnCanvas then
			local wX, wY = cam:screenToWorld( editor.selectBox.sX, editor.selectBox.sY )
			local sX = math.floor(wX/(Camera.scale*8))
			local sY = math.floor(wY/(Camera.scale*8))
			wX, wY = cam:screenToWorld( editor.selectBox.eX, editor.selectBox.eY )
			local eX = math.floor(wX/(Camera.scale*8))
			local eY = math.floor(wY/(Camera.scale*8))

			if eX < sX then
				eX, sX = sX, eX
			end
			if eY < sY then
				eY, sY = sY, eY
			end
			-- Almost the same as findObjectsInRegion, but slightly faster:
			map:highlightAllInRegion( sX, sY, eX+2, eY+2 )
		end
	end

	if self.toolTip.text == "" and self.currentTool and not hit then
		self.setToolTip( self.toolsToolTips[self.currentTool] )
	end

	map:update( dt )

	toolPanel:update( dt )
	if groundPanel.visible then
		groundPanel:update( dt )
	end
	if backgroundPanel.visible then
		backgroundPanel:update( dt )
	end
	--editBgPanel:update( dt )
	--editPanel:update( dt )
	if propertiesPanel.visible then
		propertiesPanel:update( dt )
	end
	if menuPanel.visible then
		menuPanel:update( dt )
	end
	if loadPanel.visible then
		loadPanel:update( dt )
	end
	if savePanel.visible then
		savePanel:update( dt )
	end
	if msgBox.visible then
		msgBox:update( dt )
	end
	if objectPanel.visible then
		objectPanel:update( dt )
	end
	if bgObjectPanel.visible then
		bgObjectPanel:update( dt )
	end

	-- Count down upload status timer and if it goes below zero, disable the status panel:
	if uploadStatusTimer > 0 then
		uploadStatusTimer = uploadStatusTimer - dt
		if uploadStatusTimer <= 0 then
			uploadStatusPanel.visible = false
		end
	end
end

--[[
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
		local preventDrawing

		local hit = ( msgBox.visible and msgBox:collisionCheck( x, y ) ) or
				( loadPanel.visible and loadPanel:collisionCheck( x, y ) ) or
				( savePanel.visible and savePanel:collisionCheck( x, y ) ) or
				( menuPanel.visible and menuPanel:collisionCheck( x, y ) ) or
				( toolPanel.visible and toolPanel:collisionCheck( x, y ) ) or
				( groundPanel.visible and groundPanel:collisionCheck( x, y ) ) or
				( backgroundPanel.visible and backgroundPanel:collisionCheck( x, y ) ) or
				--( editBgPanel.visible and editBgPanel:collisionCheck(x, y) ) or
				--( editPanel.visible and editPanel:collisionCheck(x, y) ) or
				( propertiesPanel.visible and propertiesPanel:collisionCheck(x, y) ) or
				( objectPanel.visible and objectPanel:collisionCheck(x, y) )

		if bgObjectPanel.visible then
			preventDrawing = true
			if bgObjectPanel:collisionCheck(x, y) then
				hit = true
			else
				bgObjectPanel.visible = false
			end
		end
		if objectPanel.visible then
			preventDrawing = true
			if objectPanel:collisionCheck(x, y) then
				hit = true
			else
				objectPanel.visible = false
			end
		end

		if not hit then
			if map:selectBorderMarker( wX, wY ) then
				hit = true
			end
		end

		local mouseOnCanvas = (not hit) and (not preventDrawing)

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
end]]

function editor:mousepressed( button, x, y )
	if button == "m" then
		cam:setMouseAnchor()
	elseif button == "wu" then
		cam:zoomIn()
	elseif button == "wd" then
		cam:zoomOut()
	elseif button == "l" or button == "r" then
		
		local wX, wY = cam:screenToWorld( x, y )
		local tileX = math.floor(wX/(Camera.scale*8))
		local tileY = math.floor(wY/(Camera.scale*8))

		local mouseOnCanvas = true
		local panelRemoved = false

		-- Following panels are mutually exclusive:
		if msgBox.visible then
			mouseOnCanvas = false
			if msgBox:collisionCheck(x, y) then
				msgBox:click( x, y, button )
			end
		elseif loadPanel.visible then
			mouseOnCanvas = false
			if loadPanel:collisionCheck(x, y) then
				loadPanel:click( x, y, button )
			end
		elseif savePanel.visible then
			mouseOnCanvas = false
			if savePanel:collisionCheck(x, y) then
				savePanel:click( x, y, button )
			end
		elseif menuPanel.visible then
			mouseOnCanvas = false
			if menuPanel:collisionCheck(x, y) then
				menuPanel:click( x, y, button )
			else
				menuPanel.visible = false
			end
		elseif bgObjectPanel.visible then
			mouseOnCanvas = false
			if bgObjectPanel:collisionCheck(x, y) and button == "l" then
				-- bgObjectPanel:addToSelectionClick( x, y, button )
				--if love.keyboard.isDown( "lshift", "rshift" ) then
				--	bgObjectPanel:addToSelectionClick( x, y )
				--else
				--bgObjectPanel:click( x, y, button )
				--end
				editor.startBoxSelect( x, y )
				--[[else
					bgObjectPanel:click( x, y, button )
				end]]
			else
				--bgObjectPanel.visible = false
				editor.closeBgObjectPanel()
				panelRemoved = true
			end
		elseif objectPanel.visible then
			mouseOnCanvas = false
			if objectPanel:collisionCheck(x, y) and button == "l" then
				--objectPanel:click( x, y, button )
				editor.startBoxSelect( x, y )
			else
				--objectPanel.visible = false
				editor.closeObjectPanel()
				panelRemoved = true
			end
		end

		if mouseOnCanvas or panelRemoved then
			if menuPanel.visible then
				if menuPanel:collisionCheck(x, y) then
					menuPanel:click( x, y, button )
					mouseOnCanvas = false
				end
			end
			if toolPanel.visible then
				if toolPanel:collisionCheck(x, y) then
					toolPanel:click( x, y, button )
					mouseOnCanvas = false
				end
			end
			if groundPanel.visible then
				if groundPanel:collisionCheck(x, y) then
					groundPanel:click( x, y, button )
					mouseOnCanvas = false
				end
			end
			if backgroundPanel.visible then
				if backgroundPanel:collisionCheck(x, y) then
					backgroundPanel:click( x, y, button )
					mouseOnCanvas = false
				end
			end
			if propertiesPanel.visible then
				if propertiesPanel:collisionCheck(x, y) then
					propertiesPanel:click( x, y, button )
					mouseOnCanvas = false
				end
			end
		end

		if mouseOnCanvas then
			if map:selectBorderMarker( wX, wY ) then
				mouseOnCanvas = false
			end
		end

		if mouseOnCanvas then
			self:useTool( tileX, tileY, button )
		end
	end
end

function editor:useTool( tileX, tileY, button )
	if self.currentTool == "pen" then
		if self.shift and self.lastClickX and self.lastClickY then
			-- draw a line
			if button == "l" then
				map:line( tileX, tileY,
				self.lastClickX, self.lastClickY, false,
				function(x, y) map:setGroundTile(x, y, self.currentGround, true ) end )
			elseif button == "r" then
				map:line( tileX, tileY,
				self.lastClickX, self.lastClickY, false,
				function(x, y) map:eraseGroundTile(x, y, true ) end )
			end
		elseif self.ctrl then
			-- fill the area
			if button == "l" then
				map:startFillGround( tileX, tileY, "set", self.currentGround )
			elseif button == "r" then
				map:startFillGround( tileX, tileY, "erase" )
			end
		else
			if button == "l" then
				-- paint:
				self.drawing = true
				-- force to draw one tile:
				map:setGroundTile( tileX, tileY, self.currentGround, true )
			elseif button == "r" then
				-- start erasing
				self.erasing = true
				-- force to erase one tile:
				map:eraseGroundTile( tileX, tileY, true )
			end
		end
		self.lastClickX, self.lastClickY = tileX, tileY
	elseif self.currentTool == "bgPen" then
		if self.shift and self.lastClickX and self.lastClickY then
			-- draw a line
			if button == "l" then
				map:line( tileX, tileY,
				self.lastClickX, self.lastClickY, false,
				function(x, y) map:setBackgroundTile(x, y, self.currentBackground, true ) end )
			elseif button == "r" then
				map:line( tileX, tileY,
				self.lastClickX, self.lastClickY, false,
				function(x, y) map:eraseBackgroundTile(x, y, true ) end )
			end
		elseif self.ctrl then
			if button == "l" then
				map:startFillBackground( tileX, tileY, "set", self.currentBackground )
			elseif button == "r" then
				map:startFillBackground( tileX, tileY, "erase" )
			end
		else
			if button == "l" then
				self.drawing = true
				map:setBackgroundTile( tileX, tileY, self.currentBackground, true )
			elseif button == "r" then
				self.erasing = true
				map:eraseBackgroundTile( tileX, tileY, true )
			end

		end
		self.lastClickX, self.lastClickY = tileX, tileY
	elseif self.currentTool == "bgObject" and self.currentBgObjects then
		if button == "l" then
			if not love.keyboard.isDown("lctrl", "rctrl") then
				editor.setTool("edit")
			end
			local new, o = {}, nil
			--for k, v in pairs( self.currentBgObjects ) do
			for k = #self.currentBgObjects, 1, -1 do	-- add bottom up!
				o = self.currentBgObjects[k]
				new[#new+1] = map:addBgObject( tileX + o.tileX, tileY + o.tileY, o.obj )
			end
			if not love.keyboard.isDown("lctrl", "rctrl") then
				for i = #new, 1, -1 do		-- select in forward order
					map:selectObject(new[i])
				end
				editor.createPropertiesPanel()
			end
		elseif button == "r" then
			local wX, wY = cam:screenToWorld( love.mouse.getPosition() )
			local tX = wX/(Camera.scale*8)
			local tY = wY/(Camera.scale*8)
			if not map:removeObjectAt( tX, tY ) then
				map:removeBgObjectAt( tX, tY )
			end
		end
	elseif self.currentTool == "object" and self.currentObjects then
		if button == "l" then
			if not love.keyboard.isDown("lctrl", "rctrl") then
				editor.setTool("edit")
			end
			local new, o = {}, nil
			--for k, o in pairs( self.currentObjects ) do
			for k = #self.currentObjects, 1, -1 do			-- add from the bottom up!
				o = self.currentObjects[k]
				local newObject = map:addObject( tileX + o.tileX, tileY + o.tileY, o.obj.tag )
				if editor.propertiesClipboard and editor.propertiesClipboard[k] then
					-- For each property...
					if newObject.properties then
						for name, p in pairs( newObject.properties ) do
							-- ... copy the value over from the 'parent' object (the duplicated one):
							newObject:setProperty( name, editor.propertiesClipboard[k][name] )
						end
						newObject:applyOptions()
					end
				end
				new[#new+1] = newObject
			end
			if not love.keyboard.isDown("lctrl", "rctrl") then
				for i = #new, 1, -1 do		-- select in forward order
					map:selectObject(new[i])
				end
				editor.createPropertiesPanel()
			end
		elseif button == "r" then
			if not map:removeObjectAt( tileX, tileY ) then
				map:removeBgObjectAt( tileX, tileY )
			end
		end
	elseif self.currentTool == "edit" then
		if button == "l" then
			--[[if not self.shift then
				map:selectNoObject()
				map:selectNoBgObject()
			end]]
			propertiesPanel.visible = false
			--editPanel.visible = false
			--editBgPanel.visible = false
			--[[if map:selectObjectAt( tileX, tileY ) then
				--editPanel.visible = true
				self.dragging = true
				editor.createPropertiesPanel()
			else]]
				
				-- overwrite the mouse position for this purpose:
				local wX, wY = cam:screenToWorld( love.mouse.getPosition() )
				local tX = wX/(Camera.scale*8)
				local tY = wY/(Camera.scale*8)
				local list = map:findObjectAt( tX, tY, true )
				if #list > 0 then
					for k, obj in pairs(list) do
						if not obj.selected then
							if not self.shift then	-- only deselect if shift not pressed
								map:selectNoObject()
								--map:selectNoBgObject()
							end
							map:selectObject( obj )
						end
					end
					--editBgPanel.visible = true
					self.dragging = true
					--obj.oX = tileX - obj.x
					--obj.oY = tileY - obj.y
					--self.dragStartX, self.dragStarty = tileX, tileY

					map:setDragOffset( tileX, tileY )

					editor.createPropertiesPanel()
					--else
					--editBgPanel.visible = false
					--editPanel.visible = false
				else
					if not self.shift then	-- only deselect if shift not pressed
						map:selectNoObject()
						--map:selectNoBgObject()
					end
					editor.startBoxSelect( love.mouse.getPosition() )
				end
			--end
		elseif button == "r" then
			if not map:removeObjectAt( tileX, tileY ) then
				map:removeBgObjectAt( tileX, tileY )
			end
		end
	end
end

function editor.duplicateSelection()
	local noBg, bg = false, false
	for k, v in pairs( map.selectedObjects ) do
		if v.isBackgroundObject then
			bg = true
		else
			noBg = true
		end
	end
	if noBg and bg then
		print("Select either background objects or foreground objects to duplicate - not both!")
	else
		if bg then
			editor.currentBgObjects = {}
			for k, v in ipairs( map.selectedObjects ) do
				table.insert( editor.currentBgObjects, {x=v.x, y=v.y, obj=v.objType} )
			end
			--editor.currentTool = "bgObject"
			editor.setTool( "bgObject" )
			bgObjectPanel.visible = false
		else
			local tmpList = {}
			editor.currentObjects = {}
			for k, v in ipairs( map.selectedObjects ) do
				table.insert( editor.currentObjects, {x=v.x, y=v.y, obj=v} )
				tmpList[k] = v
			end
			--editor.currentTool = "object"
			editor.setTool( "object" )
			objectPanel.visible = false

			-- function "setTool" clears the property clipboard, so set it after calling
			-- that function:
			editor.propertiesClipboard = tmpList
		end
		editor.sortSelectedObjects()
		map:selectNoObject()
	end
end

function editor:mousereleased( button, x, y )
	if button == "m" then
		cam:releaseMouseAnchor()
	elseif button == "l" then
		if editor.selectBox then
			editor.endBoxSelect( "notAborted" )
		end
		if map.draggedBorderMarker then
			map:dropBorderMarker()
		end
		self.drawing = false
		self.dragging = false
	elseif button == "r" then
		self.erasing = false
	end
end

function editor.startBoxSelect( x, y )
	editor.selectBox = {sX = x, sY = y, eX = x, eY = y}
end

function editor.createBoxSelectPoints( step, sX, sY, eX, eY )
	list = {}
	local sX, sY = sX or editor.selectBox.sX, sY or editor.selectBox.sY
	local eX, eY = eX or editor.selectBox.eX, eY or editor.selectBox.eY
	local stepX, stepY = step, step
	if sX > eX then stepX = -step end
	if sY > eY then stepY = -step end

	for x = sX, eX, stepX do
		for y = sY, eY, stepY do
			table.insert( list, {x = x, y = y} )
		end
	end
	-- make sure to add last lines as well:
	for x = sX, eX, stepX do
		table.insert( list, {x = x, y = eY} )
	end
	for y = sY, eY, stepY do
		table.insert( list, {x = eX, y = y} )
	end
	table.insert( list, {x = eX, y = eY} )
	return list
end

function editor.endBoxSelect( aborted )
	if aborted ~= "aborted" then
		if objectPanel.visible then
			--local sX, sY = editor.selectBox.sX, editor.selectBox.sY
			--local eX, eY = editor.selectBox.eX, editor.selectBox.eY
			local tileSize = Camera.scale*8
			local points = editor.createBoxSelectPoints( tileSize )

			-- Pretend there was a "click" at multiple coordinates in the
			-- selected area. The step between the clicks is small enough
			-- to make sure every tile will be hit at least once:

			local hitButtonList = {}
			local eventButtonList = {}
			-- Shift-clicking a single button that's already selected leads to it
			-- being un-selected:
			local singleButton, button
			local numButtonsHit = 0
			local buttonWasAlreadySelected
			for k, p in pairs(points) do
					button = objectPanel:addToSelectionClick( p.x, p.y, shift )
					if button then
						singleButton = button
						numButtonsHit = numButtonsHit + 1
						if numButtonsHit == 1 then
							buttonWasAlreadySelected = singleButton.selected
						end
						--button:setSelected( true )
						if button.obj then	-- only selct buttons that represent an object
							table.insert( hitButtonList, button )
						elseif button.event then
							table.insert( eventButtonList, button )
						end
					end
				end

			-- to prevent events from being executed too early or too often, run them now:
			for k, b in pairs( eventButtonList ) do
				b.event( )
			end
			-- Must be called AFTER running the events:
			local shift = love.keyboard.isDown( "lshift", "rshift" )
			if not shift then
				objectPanel:disselectAll()
			end
			if numButtonsHit == 1 and shift and buttonWasAlreadySelected then
				singleButton:setSelected( false )
			else
				for k, b in pairs( hitButtonList ) do
					b:setSelected( true )
				end
			end
		elseif bgObjectPanel.visible then
			local tileSize = Camera.scale*8
			local points = editor.createBoxSelectPoints( tileSize )

			-- Pretend there was a "click" at multiple coordinates in the
			-- selected area. The step between the clicks is small enough
			-- to make sure every tile will be hit at least once:

			local hitButtonList = {}
			local eventButtonList = {}
			-- Shift-clicking a single button that's already selected leads to it
			-- being un-selected:
			local singleButton, button
			local numButtonsHit = 0
			local buttonWasAlreadySelected
			for k, p in pairs( points ) do
					button = bgObjectPanel:addToSelectionClick( p.x, p.y, shift )
					if button then
						singleButton = button
						numButtonsHit = numButtonsHit + 1
						if numButtonsHit == 1 then
							buttonWasAlreadySelected = singleButton.selected
						end
						if button.obj then	-- only selct buttons that represent a bgObject
							--button:setSelected( true )
							table.insert( hitButtonList, button )
						elseif button.event then
			table.insert( eventButtonList, button )
						end
					end
			end
	
			-- to prevent events from being executed too early or too often, run them now:
			for k, b in pairs( eventButtonList ) do
				b.event( )
			end
			-- must be called AFTER running the events:
			local shift = love.keyboard.isDown( "lshift", "rshift" )
			if not shift then
				bgObjectPanel:disselectAll()
			end
			if numButtonsHit == 1 and shift and buttonWasAlreadySelected then
				singleButton:setSelected( false )
			else
				for k, b in pairs( hitButtonList ) do
					b:setSelected( true )
				end
			end
		else		-- edit tiles

			-- go through all tiles within box and try to select tiles there:
			local wX, wY = cam:screenToWorld( editor.selectBox.sX, editor.selectBox.sY )
			local sX = math.floor(wX/(Camera.scale*8))
			local sY = math.floor(wY/(Camera.scale*8))
			wX, wY = cam:screenToWorld( editor.selectBox.eX, editor.selectBox.eY )
			local eX = math.floor(wX/(Camera.scale*8))
			local eY = math.floor(wY/(Camera.scale*8))
			local shift = love.keyboard.isDown( "lshift", "rshift" )
			if not shift then
				map:selectNoObject()
			end
			--local points = editor.createBoxSelectPoints( 1, sX, sY, eX, eY )
			--
			-- Only tiles which are fully IN the box area should be selected.
			-- This is achieved by adding a 1-tile padding (the +stepX, -stepX etc.):
			--[[for k, p in pairs( points ) do
				local list = map:findObjectAt( p.x, p.y )
				if #list > 0 then
					for i, obj in pairs(list) do
						map:selectObject( obj )
					end
				end
			end]]
			
			if eX < sX then
				eX, sX = sX, eX
			end
			if eY < sY then
				eY, sY = sY, eY
			end

			local list = map:findObjectsInRegion( sX, sY, eX+2, eY+2 )
			for i, obj in pairs(list) do
				map:selectObject( obj )
			end

			if #map.selectedObjects > 0 then
				editor.createPropertiesPanel()
			end
		end
	end
	editor.selectBox = nil
	map:unPreviewAll()		-- removes box selection highlight
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
	if msgBox.visible then
		panelsToCheck = {msgBox.panel}
	elseif loadPanel.visible then
		panelsToCheck = {loadPanel}
	elseif savePanel.visible then
		panelsToCheck = {savePanel}
	elseif menuPanel.visible then
		panelsToCheck = {menuPanel}
	elseif bgObjectPanel.visible then
		panelsToCheck = {bgObjectPanel, toolPanel}
	elseif objectPanel.visible then
		panelsToCheck = {objectPanel, toolPanel}
	end
	
	local found = false
	for i, panel in pairs(panelsToCheck) do
		if panel.visible then
			for i, pageNum in pairs( {0, panel.selectedPage } ) do
				if panel.pages[pageNum] then
					for k, b in pairs(panel.pages[pageNum]) do
						if b.shortcut and b.shortcut == key then
							b.event()

							panel:disselectAll()
							--v:setSelected( true )
							found = true
						end
						if found then break end
					end
				end
				if found then break end
			end
		end
		if found then break end
	end

	if key == KEY_CLOSE and bgObjectPanel.visible then
		--bgObjectPanel.visible = false
		editor.closeBgObjectPanel()
		--editor.currentBgObjects = editor.currentBgObject or editor.bgObjectList[1]
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
	elseif key == KEY_CLOSE and objectPanel.visible then
		editor.closeObjectPanel()
	--elseif key == KEY_DUPLICATE then
		--map:duplicateSelection()
		--editor.createPropertiesPanel()
	--editor.duplicateSelection()
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

	love.graphics.setFont( fontSmall )
	--love.graphics.setLineWidth(2)

	cam:apply()

	-- map:drawGrid()
	local tileSize = Camera.scale * 8
	local cx,cy = cam:screenToWorld( 0, 0 )
	cx = math.floor(cx/tileSize)*tileSize
	cy = math.floor(cy/tileSize)*tileSize
	love.graphics.draw(AnimationDB.image.cell, editor.cellQuad,cx,cy)


	love.graphics.setColor( 255, 255, 255, 255 )
	--if self.currentTool == "object" or self.currentTool == "pen" then
	--	love.graphics.setColor( 120, 120, 120, 255 )
	--end
	map:drawBackground()

	love.graphics.setColor( 255, 255, 255, 255 )
	if self.currentTool == "bgObject" or
		self.currentTool == "bgPen" or
		self.currentTool == "edit" then
		love.graphics.setColor( 120, 120, 120, 230 )
	end
	map:drawGround()

	map:drawForeground()

	map:drawObjects()
	map:drawLines()

	love.graphics.setColor( 255, 255, 255, 255 )

	map:drawBorder()

	if self.mouseOnCanvas then
		love.graphics.setColor(0,0,0,128)
		local rX = math.floor(wX/(tileSize))*tileSize
		local rY = math.floor(wY/(tileSize))*tileSize
		if self.currentBgObjects and self.currentTool == "bgObject" then
			for k, v in pairs(self.currentBgObjects) do
				love.graphics.draw( v.obj.batch,
						rX + v.tileX*tileSize,
						rY + v.tileY*tileSize)
			end
		elseif self.currentObjects and self.currentTool == "object" then
			--love.graphics.draw( self.currentObject.obj, rX, rY)
			local offset = 0.5*tileSize
			for k, o in pairs(self.currentObjects) do
				--v.obj.vis[1]:draw( rX + offset + v.tileX*tileSize, rY + offset + v.tileY*tileSize, true )
				if o.obj.preview then
					o.obj.preview:draw( rX + offset + o.tileX*tileSize, rY + offset + o.tileY*tileSize, true )
				else
					for i, vis in ipairs( o.obj.vis ) do
						vis:draw( rX + offset + o.tileX*tileSize, rY + offset + o.tileY*tileSize, true )
					end
				end
				if o.obj.tag == "LineHook" and map.openLineHook then
					love.graphics.line( rX+4*Camera.scale, rY+4*Camera.scale,
						(map.openLineHook.tileX*8+4)*Camera.scale,
						(map.openLineHook.tileY*8+4)*Camera.scale )
				end
			end
		elseif self.currentTool == "pen" then
			if self.ctrl then
				love.graphics.draw( AnimationDB.image.fill, editor.fillQuad, rX-tileSize, rY-tileSize )
			else
				love.graphics.rectangle( 'fill',rX,rY, tileSize, tileSize )
			end
		elseif self.currentTool == "bgPen" then
			--local tX = math.floor(rX - tileSize/2) - tileSize*0.3
			--local tY = math.floor(rY - tileSize/2) - tileSize*0.3
			if self.ctrl then
				love.graphics.draw( AnimationDB.image.fill, editor.fillQuad, rX-tileSize, rY-tileSize )
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
	if menuPanel.visible then
		menuPanel:draw()
	end
	if uploadStatusPanel.visible then
		uploadStatusPanel:draw()
	end

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

	if msgBox.visible then
		msgBox:draw()
	end
	
		if editor.selectBox then
			love.graphics.setColor( 255, 255, 255, 20 )
			love.graphics.rectangle( "fill", editor.selectBox.sX, editor.selectBox.sY,
			editor.selectBox.eX - editor.selectBox.sX, editor.selectBox.eY - editor.selectBox.sY )
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.rectangle( "line", editor.selectBox.sX, editor.selectBox.sY,
			editor.selectBox.eX - editor.selectBox.sX, editor.selectBox.eY - editor.selectBox.sY )
			
			if DEBUG then
				local tileSize = Camera.scale*8
				local points = editor.createBoxSelectPoints( tileSize )

				love.graphics.setColor( 255, 125, 0, 255 )
				for k, p in pairs( points ) do
						love.graphics.point( p.x, p.y )
					end
				love.graphics.setColor( 255, 255, 255, 255 )
			end
		end
	
	love.graphics.setFont( fontSmall )
	love.graphics.print( self.toolTip.text, self.toolTip.x, self.toolTip.y )
	
	--[[love.graphics.print(wX,10,10)
	love.graphics.print(wY,10,50)--]]

	love.graphics.print( love.timer.getFPS(), 20, love.graphics.getHeight() - 40 )

end

function editor.setTool( tool )
	--map:selectNoBgObject()
	map:selectNoObject()
	propertiesPanel.visible = false
	editor.currentTool = tool
	bgObjectPanel.visible = false
	objectPanel.visible = false
	--editPanel.visible = false
	--editBgPanel.visible = false
	groundPanel.visible = false
	backgroundPanel.visible = false
	toolPanel:deactivateAll()
	if tool == "bgObject" then
		bgObjectPanel.visible = true
		bgObjectPanel:disselectAll()
	elseif tool == "object" then
		objectPanel.visible = true
		-- Important: If there were porperties to be copied (happend during object duplication)
		-- then forget about them here. Otherwise the properties might be copied to new objects,
		-- which we don't want.
		editor.propertiesClipboard = nil
	elseif tool == "pen" then
		groundPanel.visible = true
	elseif tool == "bgPen" then
		backgroundPanel.visible = true
	end

	if toolButtons[tool] then
		toolButtons[tool]:setActive( true )
	end
	
end

function editor.setToolTip( tip )
	tip = tip or ""
	editor.toolTip.text = string.lower(tip)
	editor.toolTip.x = (love.graphics.getWidth() - fontSmall:getWidth( editor.toolTip.text ))/2
	editor.toolTip.y = love.graphics.getHeight() - fontSmall:getHeight() - 10
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
	if map and map.unsavedChanges then
	msgBox:new( "Create new map?\nAnswering yes will destroy all unsaved changes for the current map.",
				editor.newMapNow, nil )
	else
		editor.newMapNow()
	end
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

function editor.loadFileListAttempt()
	if map and map.unsavedChanges then
		msgBox:new( "There are unsaved changes. Are you sure you want to load another map?",
			editor.loadFileList, nil )
	else
		editor.loadFileList()
	end
end

function editor.loadFileList()
	local list = love.filesystem.getDirectoryItems( "mylevels/")
	
	loadPanel:clearAll()

	loadPanel:addClickable( loadPanel.width - 12, 12, editor.closeFileList,
		"LEDeleteOff",
		"LEDeleteOn",
		"LEDeleteHover",
		"Cancel", nil, "escape", true )
	loadPanel:addLabel( 8, 8, "Load file:" )

	local x, y = 14,14
	local page = 1 for k, v in ipairs(list) do if v:match("(.*%.dat)$") then
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

function editor.saveFileStart( callbackEvent )
	savePanel:clearAll()

	savePanel:addClickable( savePanel.width - 12, savePanel.height - 12, editor.closeSaveFilePanel,
		"LEDeleteOff",
		"LEDeleteOn",
		"LEDeleteHover",
		"Cancel", nil, "escape", true )
	savePanel:addClickable( savePanel.width - 22, savePanel.height - 12,
		function()
			editor.saveFileAttempt( map.name .. ".dat" )
			editor.closeSaveFilePanel()
		end,
		"LEAcceptOff",
		"LEAcceptOn",
		"LEAcceptHover",
		"Accept", nil, "return", true )

	savePanel:addLabel( 8, 8, "Level name:" )
	savePanel:addLabel( 8, 20, "Author:" )
	savePanel:addLabel( 8, 32, "Short description:" )

	local setMapAuthor = function( txt )
		map.author = txt or ""
	end
	local setMapName = function( txt )
		map.name = txt or ""	
	end
	local setMapDescription = function( txt )
		map.description = txt or ""	
	end
	local chars = "[0-9a-zA-Z%-]"
	savePanel:addInputBox( 10, 13, savePanel.width - 20, 1, map.name or "", setMapName, 30, chars )
	savePanel:addInputBox( 10, 25, savePanel.width - 20, 1, map.author or "", setMapAuthor, 30, chars )
	savePanel:addInputBox( 10, 37, savePanel.width - 20, 20*Camera.scale/fontSmall:getHeight(), map.description or "", setMapDescription, 200 )

	savePanelCallbackEvent = callbackEvent

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
	fileName = fileName or "bkup/bkup.dat"

	if #fileName:match("(.*).dat"):gsub(" ", "") == 0 then
		print("Warning: Empty file name!")
		msgBox:new("Warning: Cannot save!\nFilename must not be empty.", editor.saveFileStart )
		return
	end

	if (not map.author or #map.author:gsub(" ", "") == 0) and not testFile then
		print("Warning: Empty author name!")
		msgBox:new("Warning: Cannot save!\nAuthor name must not be empty.", editor.saveFileStart )
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
		content = content .. "Author: " .. (map.author or "anonymous") .. "\n"

		content = content .. "Description:\n"
		content = content .. map:descriptionToString()
		content = content .. "\nendDescription\n\n"
		
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

	-- remember the author name for future levels:
	config.setValue("author", map.author)

	-- Mark all changes as saved, but only if this is NOT just a test save. A test save is only
	-- done when playtesting the map - the saved file can't be restored by the user, so this is
	-- not considered a proper save.
	if fullName ~= "test.dat" then
		map.unsavedChanges = false
		if savePanelCallbackEvent then
			savePanelCallbackEvent()
		end
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


------------------------------------------------------------------------
-- Handle uploading:
------------------------------------------------------------------------

function editor.attemptUpload()

	if editor.uploadInProgress then
		msgBox:new( "Another upload is in progress. Wait for it to finish.",
				nil, nil )
		return
	end

	if not map then
		msgBox:new( "No map present.",
				nil, nil )
		return
	end

	if not map.name then
		msgBox:new( "Map has to be saved first. Save now?",
			function() editor.saveFileStart( editor.attemptUpload ) end, nil )
		return
	end

	if not map.author or map.author == "" then
		msgBox:new( "Map has no author. Add one now?",
			function() editor.saveFileStart( editor.attemptUpload ) end, nil )
		return
	end

	if map.unsavedChanges then
		msgBox:new( "Unsaved changes present. You need to save the level before you can upload. Save now?",
			function() editor.saveFileStart( editor.attemptUpload ) end, nil )
		return
	end

	editor.startUploadNow()
end

-- The following will not warn the user if anything's wrong with the level,
-- so don't call it directly. Call attemptUploadNow instead.
function editor.startUploadNow()
	print("Attempting upload:")
	if not map then return end
	if not map.name then return end
	if not map.author then return end

	editor.uploadInProgress = true

	uploadStatusPanel:clearAll()
	uploadStatusPanel:addLabel( 16, 8, "Uploading level file:" )
	uploadStatusPanel:addLabel( 16, 12, map.name )
	uploadStatusPanel:addLabel( 16, 16, "by " .. map.author )
	uploadStatusPanel.visible = true
	uploadStatusTimer = -1

	local filename = love.filesystem.getSaveDirectory()
	filename = filename .. "/mylevels/" .. map.name .. ".dat"

	threadInterface.new( "upload",	-- thread name (only used for printing debug messages)
		"scripts/levelsharing/upload.lua",	-- thread script
		"uploadFile",	-- function to call (inside script)
		editor.uploadSuccess, editor.uploadFailed,	-- callback events when done
		-- the following are arguments passed to the function:
		"http://www.germanunkol.de/bandana/userlevels/upload.php",
		filename,
		map.name, map.author or "anonymous")
end

function editor.uploadSuccess()
	if uploadStatusPanel then
		uploadStatusPanel:clearAll()
		uploadStatusPanel:addLabel( 12, 8, "Successfully uploaded!")
		uploadStatusPanel:addLabel( 12, 12, "Map is now awaiting\nauthorization.")
		uploadStatusTimer = 5
	end
	editor.uploadInProgress = false
end

function editor.uploadFailed( reason )
	if uploadStatusPanel then
		uploadStatusPanel:clearAll()
		uploadStatusPanel:addLabel( 16, 8, "Failed to upload." )
		--uploadStatusPanel:addLabel( 16, 16, "Check your connection." )
		if reason then
			uploadStatusPanel:addLabel( 16, 16, reason )
		end
		uploadStatusTimer = 5
	end
	editor.uploadInProgress = false
end

------------------------------------------------------------------------
-- Handle exiting the editor:
------------------------------------------------------------------------

function editor.closeAttempt()
	if map and map.unsavedChanges then
		menuPanel.visible = false
		msgBox:new( "There are unsaved changes. Are you sure you want to quit?",
			editor.closeNow, nil )
	else
		editor.closeNow()
	end
end

function editor.closeNow()
	menu.startTransition( menu.initMain, true )()
end

return editor
