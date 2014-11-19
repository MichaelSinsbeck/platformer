local WorldmapSubmenu = {}

local Submenu = require( "scripts/menu/submenu" )
local HotkeyDisplay = require("scripts/menu/hotkeyDisplay")
local submenu	-- use this to remember the current sub menu
local singleWorldWidth = 170
local distBetweenButtons = 10
local levelsPerWorld = 15
local distBetweenWorlds = singleWorldWidth-levelsPerWorld*distBetweenButtons

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

	local x, y = -singleWorldWidth*0.5 + 6, 1
	local prevX, prevY = nil, nil

	local currentLevel = config.getValue("level")
	local lastLevel = config.getValue("lastLevel") or Campaign[1]
	local currentLevelFound = false
	local lastLevelFound = false
	local firstButton

	for k, v in ipairs(Campaign) do

		local curButton
		-- add buttons until the current level is found:
		if not lastLevelFound then
			curButton = submenu:addButton(
							'worldItemOff',
							'worldItemOn',
							x, y, menu:startCampaignLevel( k ),
							self.scroll )
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
		end

		if not firstButton then
			firstButton = curButton
		end
		
		x = x + distBetweenButtons
		
		-- after last level of each world
		-- bridge (logs)
		if k/levelsPerWorld == math.floor(k/levelsPerWorld) then
			--[[wx = x + 1.5
			for i = 1,nLogs do
				local thisVis = Visualizer:New('log')
				thisVis:init()
				if lastLevelFound then
					thisVis.sx = 0
					thisVis.sy = 0
				end
				local wy = y + 5 - math.sin(math.pi * (i-1)/(nLogs-1))				
				table.insert(menuLogs, {vis = thisVis, x = wx, y = wy})
				wx = wx + 2.1
			end]]
			
			x = x + distBetweenWorlds
		end

	end

	-- fallback:
	if not currentLevelFound and firstButton then
		-- start off with the first level selected:
		submenu:setSelectedButton( firstButton )
	end


	-- Extend the original drawing functions of the submenu class:
	--submenu:addCustomDrawFunction( WorldmapSubmenu.draw, "MainLayer" )

	return submenu
end

function WorldmapSubmenu:draw()
end

function WorldmapSubmenu:scroll( )
	local b = submenu:getSelectedButton()
	if b then
		local x = math.floor((b.x - singleWorldWidth*0.5)/singleWorldWidth)*singleWorldWidth + singleWorldWidth -- set Camera position
		local y = -700
		menu:slideCameraTo( x, y, 1 )
		Campaign.worldNumber = math.floor(b.x/singleWorldWidth)+1 -- calculate worldNumber

		-- Create function which will set ninja coordinates. Then call that function:
		--local func = menu.setPlayerPosition( selButton.x+5, selButton.y+2 )
		--menuPlayer.vis:setAni(Campaign.bandana .. "Walk")
		--func()
		menu:setPlayerPosition( submenu.x + b.x, submenu.y + b.y-3 )
	end
end

return WorldmapSubmenu
