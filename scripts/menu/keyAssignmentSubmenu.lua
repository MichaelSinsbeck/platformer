local KeyAssignmentSubmenu = {}

local Submenu = require( "scripts/menu/submenu" )
local HotkeyDisplay = require("scripts/menu/hotkeyDisplay")
local submenu	-- use this to remember the current sub menu

local LIST_WIDTH = 100	-- Dummy value
local LIST_HEIGHT = 100	-- Dummy value
local LIST_ENTRY_HEIGHT = 8
local selectedFunction = 1
local firstDisplayedFunction = 1
local numDisplayedFunctions = 8
local functions = {}

-- Assignment:
--local keyCurrentlyAssigning = nil
--
local function createFunction( f, keyType )
	f.name = string.lower( keyType )
	f.keyType = keyType
	f.keyVis = Visualizer:New( getAnimationForKey( keys[keyType] ) )
	f.keyVis:init()
	f.keyNameVis = Visualizer:New( nil, nil, nameForKey( keys[keyType] ) )
	f.keyNameVis:init()
	f.padVis = Visualizer:New( getAnimationForPad( keys.PAD[keyType] ) )
	f.padVis:init()
end

function KeyAssignmentSubmenu:new( x, y )
	local width = 0.6*love.graphics.getWidth()/Camera.scale - 16
	local height = love.graphics.getHeight()/Camera.scale - 32

	LIST_WIDTH = width
	LIST_HEIGHT = height
	numDisplayedFunctions = (LIST_HEIGHT-16)/(LIST_ENTRY_HEIGHT) - 1

	functions = {}
	for i = 1, #keyTypes do
		local f = {}
		createFunction( f, keyTypes[i] )
		table.insert( functions, f )
	end

	submenu = Submenu:new( x, y )

	--[[local cancelAssignment = function()
		submenu:setLayerVisible( "Assignment", false )
		self.keyCurrentlyAssigning = nil
	end]]
	
	local p = submenu:addPanel( -LIST_WIDTH/2, -LIST_HEIGHT/2 - 8, LIST_WIDTH, LIST_HEIGHT )
	p:turnIntoList( LIST_ENTRY_HEIGHT, 2 )

	submenu:addLayer("Assignment")
	submenu:setLayerVisible( "Assignment", false )
	submenu:addPanel( -LIST_WIDTH/2 + 8, -16, LIST_WIDTH - 16, 32, "Assignment" )
	--[[submenu:addHotkey( keys.BACK, keys.PAD.BACK, "Cancel",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		cancelAssignment, "Assignment" )]]

	-- Add invisible buttons to list which allow level selection:
	local lineHover = function()
		local cy = (20 - LIST_HEIGHT/2 + LIST_ENTRY_HEIGHT*(selectedFunction-firstDisplayedFunction-1))
		local cx = -LIST_WIDTH/2 + 12
		menu:setPlayerPosition( x + cx, y + cy )	-- player position must be in global coordinates
	end

	local startReassignment = function()
		self.keyCurrentlyAssigning = keyTypes[selectedFunction]
		print("Starting assignment for: ", self.keyCurrentlyAssigning )
		submenu:setLayerVisible( "Assignment", true )
		submenu:clearLayer( "Assignment" )
		--submenu:addPanel( -LIST_WIDTH/2 + 8, -16, LIST_WIDTH - 16, 32, "Assignment" )
		submenu:addText( "Enter new key for '" .. functions[selectedFunction].name .. "'",
				-LIST_WIDTH/2 + 32, -4, LIST_WIDTH - 64, "Assignment" )
	end

	local buttonCenter = submenu:addButton( "", "", 0, 0, startReassignment, lineHover )
	buttonCenter.invisible = true

	local moveUp = function()
		selectedFunction = math.max( 1, selectedFunction - 1 )

		if selectedFunction < firstDisplayedFunction then
			firstDisplayedFunction = selectedFunction
		end

		submenu:setSelectedButton( buttonCenter )
	end
	local moveDown = function()
		selectedFunction = math.min( #functions, selectedFunction + 1 )

		if selectedFunction - firstDisplayedFunction + 1 > numDisplayedFunctions then
			firstDisplayedFunction = selectedFunction - numDisplayedFunctions + 1
		end

		submenu:setSelectedButton( buttonCenter )
	end

	submenu:addButton( "", "", 0, -10, nil, moveUp )
	submenu:addButton( "", "", 0, 10, nil, moveDown )

	-- Add hotkeys:
	local back = function()
		--submenu:startExitTransition(
		--	function()
				menu:switchToSubmenu( "Settings" )
		--	end )
	end
	submenu:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Reassign",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		nil )
	submenu:addHotkey( keys.BACK, keys.PAD.BACK, "Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		back )

	submenu:setActivateFunction(
		function()
			submenu:setSelectedButton( buttonCenter )
		end )
	submenu:setDeactivateFunction(
		function()
			KeyAssignmentSubmenu:close()
		end	)

	-- Extend the original drawing functions of the submenu class:
	submenu:addCustomDrawFunction( KeyAssignmentSubmenu.draw, "MainLayer" )

	return submenu
end

function KeyAssignmentSubmenu:draw()
	local x = -LIST_WIDTH/2 + 4
	local y = -LIST_HEIGHT/2
	local w = LIST_WIDTH - 8
	local h = LIST_HEIGHT

	local xName = (x + 12)*Camera.scale
	local xKeyboard = (x + 0.5*w)*Camera.scale
	local xKeyboardCenter = (x + 0.625*w)*Camera.scale
	local xPad = (x + 0.75*w)*Camera.scale
	local xPadCenter = (x + 0.875*w)*Camera.scale
	local xEnd = (x + w)*Camera.scale

	-- draw headers:
	love.graphics.setColor( 30,0,0,75 )
	love.graphics.rectangle( "fill", xName, y*Camera.scale, xKeyboard - xName - 2*Camera.scale, LIST_ENTRY_HEIGHT*Camera.scale)
	love.graphics.rectangle( "fill", xKeyboard, y*Camera.scale, xPad - xKeyboard - 2*Camera.scale, LIST_ENTRY_HEIGHT*Camera.scale)
	love.graphics.rectangle( "fill", xPad, y*Camera.scale, xEnd - xPad - 2*Camera.scale, LIST_ENTRY_HEIGHT*Camera.scale)

	love.graphics.setColor( 255,255,255,255 )
	--love.graphics.setColor( 0,0,0,255 )
	love.graphics.print( "Function", xName + 2*Camera.scale, (y + 2)*Camera.scale )
	love.graphics.print( "Keyboard", xKeyboard + 2*Camera.scale, (y + 2)*Camera.scale )
	love.graphics.print( "Controller", xPad + 2*Camera.scale, (y + 2)*Camera.scale )

	local lastDisplayedFunction = math.min( numDisplayedFunctions + firstDisplayedFunction - 1, #functions )
	for i = firstDisplayedFunction, lastDisplayedFunction do
		local curY = (2 + y + LIST_ENTRY_HEIGHT*(i-firstDisplayedFunction+1))*Camera.scale
		local visY = curY + 2*Camera.scale
		love.graphics.print( functions[i].name .. ":", xName, curY )
		functions[i].keyVis:draw( xKeyboardCenter, visY )
		functions[i].keyNameVis:draw( xKeyboardCenter, visY )
		functions[i].padVis:draw( xPadCenter, visY )
	end

	--[[
	--for i, level in ipairs( userlevels ) do
	local lastDisplayedLevel = math.min( displayedUserlevels + firstDisplayedUserlevel - 1, #userlevelsFiltered )

	--print(#userlevels, lastDisplayedLevel, displayedUserlevels, firstDisplayedUserlevel )
	for i = firstDisplayedUserlevel, lastDisplayedLevel do
		local level = userlevelsFiltered[i]

		local curY = (2 + y + LIST_ENTRY_HEIGHT*(i-firstDisplayedUserlevel+1))*Camera.scale

		-- draw indicator showing if level is ready to play or needs to be downloaded first:
		level.statusVis:draw( xStatus + 4*Camera.scale, curY + 0.25*LIST_ENTRY_HEIGHT*Camera.scale )
		love.graphics.print( i .. ": " .. level.levelname, xLevelname, curY )
		love.graphics.print( level.author, xAuthor, curY )
		level.ratingFunVis:draw( xFun + 12*Camera.scale, curY + 0.25*LIST_ENTRY_HEIGHT*Camera.scale )
		level.ratingDifficultyVis:draw( xDifficulty + 12*Camera.scale, curY + 0.25*LIST_ENTRY_HEIGHT*Camera.scale )
		level.authorizationVis:draw( xAuthorized + 8*Camera.scale, curY + 0.25*LIST_ENTRY_HEIGHT*Camera.scale )
	end


	]]
end

function KeyAssignmentSubmenu:assignKey( key )

	-- Update the display for the key, and the key
	-- in the keys list:
	for i, f in ipairs( functions ) do
		if f.keyType == self.keyCurrentlyAssigning then
			keys[self.keyCurrentlyAssigning] = key
			createFunction( f, f.keyType )
			keys.setChanged()
			break
		end
	end

	submenu:setLayerVisible( "Assignment", false )
	self.keyCurrentlyAssigning = nil
end

function KeyAssignmentSubmenu:assignPad( key )
	-- Update the display for the key, and the key
	-- in the keys list:
	for i, f in ipairs( functions ) do
		if f.keyType == self.keyCurrentlyAssigning then
			keys.PAD[self.keyCurrentlyAssigning] = key
			createFunction( f, f.keyType )
			keys.setChanged()
			break
		end
	end

	submenu:setLayerVisible( "Assignment", false )
	self.keyCurrentlyAssigning = nil
end

function KeyAssignmentSubmenu:close()
	keys:exitSubMenu()
end

return KeyAssignmentSubmenu
