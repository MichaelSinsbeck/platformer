local WorldmapSubmenu = {}

local Submenu = require( "scripts/menu/submenu" )
local HotkeyDisplay = require("scripts/menu/hotkeyDisplay")
local submenu	-- use this to remember the current sub menu
local singleWorldWidth = 170
local distBetweenButtons = 10
local levelsPerWorld = 15
local distBetweenWorlds = singleWorldWidth-levelsPerWorld*distBetweenButtons
local bridges = {}
local numLevelButtons = 0
local levelButtons = {}

function WorldmapSubmenu:new( x, y )
	submenu = Submenu:new( x, y )
	
	-- Add hotkeys:
	local back = function()
		menu:switchToSubmenu( "Main" )
	end
	submenu:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		nil )
	submenu:addHotkey( keys.BACK, keys.PAD.BACK, "Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		back )

	submenu:addImage( "world1", -singleWorldWidth*0.5, -30 )
	submenu:addImage( "world2", singleWorldWidth*0.5, -30 )
	submenu:addImage( "world3", singleWorldWidth*1.5, -30 )
	submenu:addImage( "world4", singleWorldWidth*2.5, -30 )
	submenu:addImage( "world5", singleWorldWidth*3.5, -30 )

	--local x, y = -singleWorldWidth*0.5 + 6, 1
	--local prevX, prevY = nil, nil

	local currentLevel = config.getValue("level")
	local lastLevel = config.getValue("lastLevel") or Campaign[1]

	print(currentLevel, "current level")

--[[	for k, v in ipairs(Campaign) do

		local curButton
		-- add buttons until the current level is found:
		if not lastLevelFound then
			curButton = submenu:addButton(
							'worldItemOff',
							'worldItemOn',
							x, y, menu:startCampaignLevel( k ),
							self.scroll )

			numLevelButtons = k
		else
			submenu:addImage( "worldItemInactive", x, y )
		end

		if prevX and prevY then
			if lastLevelFound then
				--table.insert(menuLines, {typ="line", x1=prevX+size, y1=prevY+size, x2=x+size, y2=y+size})
			else
				--table.insert(menuLines, {typ="line", x1=prevX+size, y1=prevY+size, x2=x+size, y2=y+size, active = true})
			end
		end
		prevX, prevY = x,y

		if not currentLevel or v == currentLevel then
			if curButton then
				currentLevelFound = true
				submenu:setSelectedButton( curButton )		
			end
		end

		if not lastLevel or v == lastLevel then
			lastLevelFound = true
			Campaign.last = math.max(Campaign.last,k)
			--Campaign.worldNumber = math.floor( k/levelsPerWorld )+1 -- calculate worldNumber
		end

		if not firstButton then
			firstButton = curButton
		end
		
		x = x + distBetweenButtons
		
		-- after last level of each world
		-- bridge (logs)
		if k/levelsPerWorld == math.floor(k/levelsPerWorld) then
			if not lastLevelFound then
				WorldmapSubmenu:addBridge( math.floor(k/levelsPerWorld) )
			end
			
			x = x + distBetweenWorlds
		end
	end]]

	local lastLevelNum = 1	-- at least one level button should be created
	local selectLevelNum = 1	-- which level to select (default: last one)
	for k, v in ipairs( Campaign ) do
		-- Find the ID of the level which is the last "open" level:
		if v == lastLevel then
			lastLevelNum = k
		end
		-- Find the ID of the level which is the last played level:
		if v == currentLevel then
			selectLevelNum = k
		end
	end

	-- Create a list of buttons.
	-- Stop at the last "open" level.
	-- Select the level which was last played:
	self:createButtons( lastLevelNum, selectLevelNum, true )

	-- fallback:
	if not currentLevelFound and firstButton then
		-- start off with the first level selected:
		submenu:setSelectedButton( firstButton )
	end
	
	-- Extend the original drawing functions of the submenu class:
	submenu:addCustomDrawFunction( WorldmapSubmenu.draw, "MainLayer" )
	submenu:addCustomUpdateFunction( function(dt) WorldmapSubmenu:update(dt) end )

	return submenu
end

function WorldmapSubmenu:draw()
	for k, b in ipairs( bridges ) do
		b:draw()
	end
end
function WorldmapSubmenu:update( dt )
	for k, b in ipairs( bridges ) do
		if not b.animationFinished then
			b:update( dt )
			if b.animationFinished then
				menu:proceedToNextLevel( Campaign.current )
			end
		end
	end
end

function WorldmapSubmenu:scroll( )
	local b = submenu:getSelectedButton()
	if b then
		local x = math.floor((b.x - singleWorldWidth*0.5)/singleWorldWidth)*singleWorldWidth + singleWorldWidth -- set Camera position
		local y = -700
		menu:slideCameraTo( x, y, 1 )
		Campaign.worldNumber = math.floor((b.x + singleWorldWidth*0.5)/singleWorldWidth)+1 -- calculate worldNumber

		-- Create function which will set ninja coordinates. Then call that function:
		--local func = menu.setPlayerPosition( selButton.x+5, selButton.y+2 )
		--menuPlayer.vis:setAni(Campaign.bandana .. "Walk")
		--func()
		menu:setPlayerPosition( submenu.x + b.x, submenu.y + b.y-3 )
	end
end

function WorldmapSubmenu:createButtons( lastLevelNumber, selectLevelNum, addBridges )

	print("number of levels", "selectedLevel", lastLevelNumber, selectLevelNum )
	local x, y = -singleWorldWidth*0.5 + 6, 1

	for k, v in ipairs(Campaign) do
		if k > lastLevelNumber then
			break
		end

		if k > numLevelButtons then

			local curButton
			-- add buttons until the current level is found:
			if not lastLevelFound then
				curButton = submenu:addButton(
				'worldItemOff',
				'worldItemOn',
				x, y, menu:startCampaignLevel( k ),
				self.scroll )

				numLevelButtons = k

				levelButtons[k] = curButton
			else
				submenu:addImage( "worldItemInactive", x, y )
			end
		end

		-- bridge (logs)
		if k/levelsPerWorld == math.floor(k/levelsPerWorld) then
			if addBridges then
				WorldmapSubmenu:addBridge( math.floor(k/levelsPerWorld), true )
			end
			x = x + distBetweenWorlds
		end
		x = x + distBetweenButtons
	end

	if selectLevelNum then
		if levelButtons[selectLevelNum] then
			submenu:setSelectedButton( levelButtons[selectLevelNum] )
		end
	end
end

function WorldmapSubmenu:addBridge( worldNumber, noAnimation )
	print("New bridge for world:", worldNumber )
	local x = -singleWorldWidth*0.5 + (singleWorldWidth)*worldNumber - 15
	local y = 0
	local bridge = Bridge:new( x, y, noAnimation )
	table.insert( bridges, bridge )
end

return WorldmapSubmenu
