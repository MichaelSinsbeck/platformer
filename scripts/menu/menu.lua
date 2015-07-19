
local menu = {
	curLevelName = "",
	transitionActive = false,
	transitionPercentage = 0,
	state = "main",
	activeSubmenu = "Main",
	parallaxPos = 0,
	xCamera = 0,
	yCamera = 0,
	initialized = false,
}

local Submenu = require( "scripts/menu/submenu" )
local UserlevelSubmenu = require( "scripts/menu/userlevelSubmenu" )
local KeyAssignmentSubmenu = require( "scripts/menu/keyAssignmentSubmenu" )
local WorldmapSubmenu = require( "scripts/menu/worldmapSubmenu" )

local submenus = {}

local menuPlayer = {
	x = 0,
	y = 0,
}

function menu:init()

	-- Create the menu ninja:
	menuPlayer.vis = Visualizer:New( "playerWalk" )
	menuPlayer.visBandana = Visualizer:New("bandanaWalk")
	menuPlayer.vis:init()
	menuPlayer.visBandana:init()

	-- Create the ninja's Bandana
	menuPlayer.vis:setAni("playerWalk")
	menuPlayer.vis.sx = 1
	menuPlayer.visBandana:setAni("bandanaWalk")
	menuPlayer.visBandana.sx = 1

	-- Create the main menu:
	local mainMenu = Submenu:new()
	mainMenu:addImage( "logo", -85, -78 )
	mainMenu:addPanel( -30, -20, 50, 80 )

	local switchToWorldMap = function()
		--mainMenu:startExitTransition(
				--function()
					self:switchToSubmenu( "Worldmap" )
				--end )
	end
	local switchToUserlevels = function()
		--mainMenu:startExitTransition(
				--function()
					self:switchToSubmenu( "Userlevels" )
				--end )
	end
	local switchToSettings = function()
		--mainMenu:startExitTransition(
				--function()
					self:switchToSubmenu( "Settings" )
				--end )
	end
	local switchToCredits = function()
		self:switchToSubmenu( "Credits")
	end
	local switchToEditor = function()
		self:switchToSubmenu( "Editor" )
	end

	local quit = function()
		--mainMenu:startExitTransition( love.event.quit )
		love.event.quit()
	end

	mainMenu:addButton( "startOff", "startOn", -11, -10,
		switchToWorldMap, self:setPlayerPositionEvent( -17, -5), nil, 'Start Game' )
	mainMenu:addButton( "downloadOff", "downloadOn", -11, 0,
		switchToUserlevels, self:setPlayerPositionEvent( -17, 5), nil, 'User Levels' )
	mainMenu:addButton( "settingsOff", "settingsOn", -11, 10,
		switchToSettings, self:setPlayerPositionEvent( -17, 15), nil, 'Settings' )
	mainMenu:addButton( "editorOff", "editorOn", -11, 20,
		switchToEditor, self:setPlayerPositionEvent( -17, 25), nil, 'Leveleditor' )
	mainMenu:addButton( "creditsOff", "creditsOn", -11, 30,
		switchToCredits, self:setPlayerPositionEvent( -17, 35), nil, 'Credits' )
	mainMenu:addButton( "exitOff", "exitOn", -11, 40,
		quit, self:setPlayerPositionEvent( -17, 45), nil, 'Quit' )

	mainMenu:addHotkey( "CHOOSE", "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )

	mainMenu:addHotkey( "BACK", "Exit",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		quit )
	
	submenus["Main"] = mainMenu

	-- Create userlevel submenu:
	local userlevelsMenu = UserlevelSubmenu:new( 700, 0 )

	submenus["Userlevels"] = userlevelsMenu

	-- Create World map menu:
	local worldMapMenu = WorldmapSubmenu:new( 0, -700 )
	submenus["Worldmap"] = worldMapMenu

	-- functions needed in options menu
	local switchToKeyAssignment = function()
		menu:switchToSubmenu( "KeyAssignment" )
	end
	local changeEffectVolume = function( val )
		settings:setEffectVolume( (val-1)*20 )
	end
	local changeMusicVolume = function( val )
		settings:setMusicVolume( (val-1)*20 )
	end
	local toggleFullscreen = function( bool )
		settings:toggleFullScreen()
	end
	local toggleShaders = function( bool )
		settings:setShadersEnabled( bool )
	end
	local setBackgroundDetail = function( val )
		settings:setBackgroundDetail( val )
	end	
	local backToMain = function()
		settings:saveAudio()
		settings:saveGraphics()		
		menu:switchToSubmenu( "Main" )
	end	
	-- options menu
	local settingsMenu = Submenu:new( -700, 0 )
	
	local p = settingsMenu:addPanel( -52, -40, 122, 80 )

	p:turnIntoList( 10, 1.1 ) -- make vertical "table-like" lines for readability
	
	local s = settingsMenu:addSlider( "soundOptionsOff", "soundOptionsOn", -32, -30, 40, 6,
		self:setPlayerPositionEvent( settingsMenu.x - 38, -25), changeEffectVolume,
		{ "0%", "20%", "40%", "60%", "80%", "100%" }, "Effect volume: " )
	s:setValue( settings:getEffectVolume()/20+1 )
	local s = settingsMenu:addSlider( "musicOff", "musicOn", -32, -20, 40, 6,
		self:setPlayerPositionEvent( settingsMenu.x - 38, -15), changeMusicVolume,
		{ "0%", "20%", "40%", "60%", "80%", "100%" }, "Music volume: " )
	s:setValue( settings:getMusicVolume()/20+1 )
	
local b = settingsMenu:addToggleButton( "toFullscreenOff", "toFullscreenOn",
		"toWindowedOff", "toWindowedOn", -32, -10, 
		toggleFullscreen, self:setPlayerPositionEvent( settingsMenu.x - 38, -5 ),
		{[true]="Fullscreen", [false]="Windowed"} )
	b:setValue( settings:getFullscreen() )

	local b = settingsMenu:addToggleButton( "noShadersOff", "noShadersOn",
		"shadersOff", "shadersOn", -32, 0, 
		toggleShaders, self:setPlayerPositionEvent( settingsMenu.x - 38, 5 ),
		{[true]="on", [false]="off"}, "Shaders: " )
	b:setValue( settings:getShadersEnabled() )

	local s = settingsMenu:addSlider( "musicOff", "musicOn", -32, 10, 20, 3,
		self:setPlayerPositionEvent( settingsMenu.x - 38, 15), setBackgroundDetail,
		{ "No Background", "Simple Background", "Detailed background" } )
	s:setValue( settings:getBackgroundDetail() )	
		
	settingsMenu:addButton( "keyAssignmentOff", "keyAssignmentOn", -32, 20, 
		switchToKeyAssignment, self:setPlayerPositionEvent( settingsMenu.x - 38, 25 ),nil,'Key Bindings' )



	settingsMenu:addHotkey( "CHOOSE", "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )
	settingsMenu:addHotkey( "BACK", "Save & back\n to main menu",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		backToMain )

	submenus["Settings"] = settingsMenu


	local width = love.graphics.getWidth()/Camera.scale - 16
	local height = love.graphics.getHeight()/Camera.scale - 32
	local keyAssignment = KeyAssignmentSubmenu:new( -1400, 0 )

	submenus["KeyAssignment"] = keyAssignment


	-- Dummy menu for editor (doesn't actually display anything)
	local editorMenu = Submenu:new( 0, 1000 )

	local function showEditor()
		editor.start()
	end

	editorMenu:setActivateFunction( showEditor )
	submenus["Editor"] = editorMenu
	
	-- Dummy menu for credits (doesn't display anything)
	local creditsMenu = Submenu:new(0,1000)
	local function showCredits()
		Credits:start()
	end
	creditsMenu.update = Credits.update
	creditsMenu.draw = Credits.draw
	creditsMenu:setActivateFunction( showCredits)
	local function quitCredits()
		Credits:stop()
		menu:switchToSubmenu( "Main" )
		
	end
	creditsMenu:addHotkey( "BACK", "Exit",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		quitCredits )
	submenus["Credits"] = creditsMenu

	if love.joystick.getJoystickCount() ~= 0 then
		self:connectedGamepad()
	end

	menu.initialized = true

end

--function menu:initMain()
	--menu:switchToSubmenu( "Main" )
--	menu:switchToSubmenu( "Main" )
--end

function menu:show()
	-- initialize parallax background
	parallax:init(nil,nil,nil,nil,nil,nil,1)

	-- Switch to showing the menu:
	mode = 'menu'
end

function menu:switchToSubmenu( menuName )
	if menuName == "Pause" then
		menuName = "Worldmap"		-- DEBUG
	end

	self.previousSubmenu = self.activeSubmenu
	-- Clean up sub menu:
	if submenus[self.previousSubmenu] then
		submenus[self.previousSubmenu]:deactivate()
	end

	self.activeSubmenu = menuName
	submenus[self.activeSubmenu]:reselectButton()
	--submenus[menu.activeSubmenu]:startIntroTransition()

	if menuName == "Main" then
		self:slideCameraTo( 0, 0, 0.5 )
		menu.currentlyPlayingUserlevels = false
	elseif menuName == "Worldmap" then
		--self:slideCameraTo( 0, -700, 0.5 )
		WorldmapSubmenu:scroll()
	elseif menuName == "Userlevels" then
		self:slideCameraTo( 700, 0, 0.5 )
		menu.currentlyPlayingUserlevels = true
	elseif menuName == "Settings" then
		self:slideCameraTo( -700, 0, 0.5 )
	elseif menuName == "Sound" or
		menuName == "Graphics" or
		menuName == "KeyAssignment" then
		self:slideCameraTo( -1400, 0, 0.5 )
	elseif menuName == "Editor" then
		self:slideCameraTo( 0, 1000, 0.5 )
	elseif menuName == "Credits" then
		self:slideCameraTo(1000,0,0.5)
	end

	menu:setPlayerDirection( "right" )
end

-- Slide camera to a position over a short period of time
function menu:slideCameraTo( x, y, time )
	if (not self.cameraSlideTime) or 
		self.xTarget ~= x or self.yTarget ~= y then
		self.xTarget = x
		self.yTarget = y
		self.xCameraStart = self.xCamera
		self.yCameraStart = self.yCamera
		self.cameraSlideTime = time
		self.cameraPassedTime = 0
	end
end

-- Instantaneously move camera to a position
function menu:setCameraTo( x, y )
	self.xTarget = x
	self.yTarget = y
	self.xCamera = x
	self.yCamera = y
	self.cameraSlideTime = nil
end

function menu:update( dt )
	--if menu.state == "main" then
		--parallax:update(dt)
	
	--end
	if self.cameraSlideTime then
		self.cameraPassedTime = self.cameraPassedTime + dt
		if self.cameraPassedTime < self.cameraSlideTime then
			local amount = utility.interpolateCos( self.cameraPassedTime/self.cameraSlideTime )
			self.xCamera = self.xCameraStart + 
				(self.xTarget - self.xCameraStart)*amount
			self.yCamera = self.yCameraStart + 
				(self.yTarget - self.yCameraStart)*amount
		else
			self.xCamera = self.xTarget
			self.yCamera = self.yTarget
			self.cameraSlideTime = nil
			submenus[self.activeSubmenu]:activate()
		end
	end
	parallax:setPosition( -self.xCamera )

	menuPlayer.vis:update(dt/2)
	menuPlayer.visBandana:update(dt/2)

	submenus[self.activeSubmenu]:update(dt)
end

function menu:updateLevelName( dt )
end

function menu:draw()

	--if menu.state == 'main' then
		parallax:draw()
	--end

	love.graphics.push()
	love.graphics.translate(
		-math.floor(self.xCamera*Camera.scale)+love.graphics.getWidth()/2,
		-math.floor(self.yCamera*Camera.scale)+love.graphics.getHeight()/2 )

	if self.previousSubmenu then
		submenus[self.previousSubmenu]:draw()
	end

	-- Draw all visible panels:
	if self.activeSubmenu then
		submenus[self.activeSubmenu]:draw()

		-- If there's no transition in progress...
		--if not submenus[self.activeSubmenu]:getTransition() then
			-- Draw the menu ninja:
			local x = menuPlayer.x*Camera.scale
			local y = menuPlayer.y*Camera.scale
			menuPlayer.vis:draw(x,y,true)

			local color = utility.bandana2color[Campaign.bandana]
			if color then
				local r,g,b = love.graphics.getColor()
				love.graphics.setColor(color[1],color[2],color[3],255)
				menuPlayer.visBandana:draw(x,y,true)
				love.graphics.setColor(r,g,b)
			end
		--end
	end

	love.graphics.pop()
end

-- Remove every panel
function menu:clear()
	submenus = {}
end

function menu:keypressed( key, repeated )
	if key == 'escape' then
		Sound:play('menuBack')
	end
	if self.activeSubmenu then
		if self.activeSubmenu == "KeyAssignment" and
			KeyAssignmentSubmenu.keyCurrentlyAssigning ~= nil then
			-- Only assign if not taken by hotkey:
			if not submenus[self.activeSubmenu]:hotkey( key ) then
				KeyAssignmentSubmenu:assignKey( key )
			end
		else

			if key == keys.LEFT then
				submenus[self.activeSubmenu]:goLeft()
				Sound:play('menuMove')
			elseif key == keys.RIGHT then
				submenus[self.activeSubmenu]:goRight()
				Sound:play('menuMove')
			elseif key == keys.UP then
				submenus[self.activeSubmenu]:goUp()
				Sound:play('menuMove')
			elseif key == keys.DOWN then
				submenus[self.activeSubmenu]:goDown()
				Sound:play('menuMove')
			elseif key == keys.CHOOSE then
				submenus[self.activeSubmenu]:startButtonEvent()
				Sound:play('menuEnter')
			else
				submenus[self.activeSubmenu]:hotkey( key )
			end
		end
	end
end

function menu:gamepadpressed( button )
	if self.activeSubmenu then
		key = tostring( button )
		if self.activeSubmenu == "KeyAssignment" and
			KeyAssignmentSubmenu.keyCurrentlyAssigning ~= nil then
			-- Only assign if not taken by hotkey:
			if not submenus[self.activeSubmenu]:gamepadHotkey( key ) then
				KeyAssignmentSubmenu:assignPad( key )
			end
		else
			if key == keys.PAD.LEFT then
				submenus[self.activeSubmenu]:goLeft()
			elseif key == keys.PAD.RIGHT then
				submenus[self.activeSubmenu]:goRight()
			elseif key == keys.PAD.UP then
				submenus[self.activeSubmenu]:goUp()
			elseif key == keys.PAD.DOWN then
				submenus[self.activeSubmenu]:goDown()
			elseif key == keys.PAD.CHOOSE then
				submenus[self.activeSubmenu]:startButtonEvent()
			else
				submenus[self.activeSubmenu]:gamepadHotkey( key )
			end
		end
	end
end

function menu:textinput( letter )
end

function menu:downloadedVersionInfo( info )
end

function menu:setPlayerPosition( x, y )
	menuPlayer.x = x
	menuPlayer.y = y
end

function menu:setPlayerPositionEvent( x, y )
	return function()
		menuPlayer.x = x
		menuPlayer.y = y
	end
end

function menu:setPlayerDirection( dir )
	if dir == "left" then
		menuPlayer.vis.sx = -1
		menuPlayer.visBandana.sx = -1
	else
		menuPlayer.vis.sx = 1
		menuPlayer.visBandana.sx = 1
	end
end

function menu:setPlayerAnimation( animation )
end

---------------------------------------------------------
-- Creates and returns an annonymous function
-- which will start the given level:
---------------------------------------------------------

function menu:startCampaignLevel( lvlNum )
	local lvl = "levels/" .. Campaign[lvlNum]
	return function()
		initAll()
		Campaign.current = lvlNum		
		--p = spriteFactory('Player')
		mode = 'game'
		
		gravity = 22
		--Campaign.current = lvlNum
		myMap = Map:loadFromFile( lvl )
		levelEnd:reset()		-- resets the counters of all deaths etc
		myMap:start()
		config.setValue( "level", Campaign[lvlNum] )

		-- Add all bandans the user has already received:
		gui.clearBandanas()
		local bandanas = {"white","yellow","green","blue","red"}
		local noShow = true
		for i, col in ipairs( bandanas ) do
			gui.addBandana( col, noShow )
			if col == Campaign.bandana then
				break
			end
		end
	end
end

function menu:startGame( lvl )
	return function ()
		initAll()
		--p = spriteFactory('Player')
		mode = 'game'
		gravity = 22
		--Campaign.current = lvlNum
		myMap = Map:loadFromFile( lvl )
		levelEnd:reset()		-- resets the counters of all deaths etc
		myMap:start()		
		

		gui.clearBandanas()
	end
end

function menu:proceedToNextLevel( levelNumber )
	WorldmapSubmenu:createButtons( levelNumber, levelNumber )
end

function menu:createWorldButtons()
	local lastLevel = Campaign.last
	local currentLevel = Campaign.current
	WorldmapSubmenu:createButtons( lastLevel, currentLevel)
end

function menu:nextWorld( worldNumber )
	self:switchToSubmenu( "Worldmap" )
	WorldmapSubmenu:addBridge( worldNumber-1 )
	--WorldmapSubmenu:scroll()
	WorldmapSubmenu:halfScroll()
end
---------------------------------------------------------
-- Handle connecting/disconnecting joysticks:
---------------------------------------------------------

function menu:connectedGamepad()
	for k, submenu in pairs( submenus ) do
		submenu:connectedGamepad()
	end
end
function menu:disconnectedGamepad()
	for k, submenu in pairs( submenus ) do
		submenu:disconnectedGamepad()
	end
end

---------------------------------------------------------
-- Handle changes of hotkeys
---------------------------------------------------------

function menu:updateHotkeys()
	for k, submenu in pairs( submenus ) do
		submenu:updateHotkeys()
	end
end

return menu
