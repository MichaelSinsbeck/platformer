
local menu = {
	curLevelName = "",
	transitionPercentage = 0,
	activeSubmenu = "Main",
	parallaxPos = 0,
	xCamera = 0,
	yCamera = 0,
	initialized = false,
	overlaySubmenu = nil,
}

local Submenu = require( "scripts/menu/submenu" )
local UserlevelSubmenu = require( "scripts/menu/userlevelSubmenu" )
local KeyAssignmentSubmenu = require( "scripts/menu/keyAssignmentSubmenu" )
local WorldmapSubmenu = require( "scripts/menu/worldmapSubmenu" )
local RatingSubmenu = require( "scripts/menu/ratingSubmenu" )

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
	mainMenu:addPanel( -32, -20, 64, 80 )

	local switchToWorldMap = function()
		--mainMenu:startExitTransition(
				--function()
				WorldmapSubmenu:selectCurrentLevel( Campaign.current )
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
	local worldMapMenu = WorldmapSubmenu:new( 0, -1500 )
	submenus["Worldmap"] = worldMapMenu

	---------------------------------------------------------------
	-- options menu
	
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
		settings:toggleFullscreen()
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
	local resetCampaign= function()
		Campaign:reset()
		Campaign:saveState()
	end

	-- Generate the actual menu:
	local settingsMenu = Submenu:new( -700, 0 )
	
	local p = settingsMenu:addPanel( -64, -40, 128, 88 )

	p:turnIntoList( 10, 1.45 ) -- make vertical "table-like" lines for readability
	
	settingsMenu:addButton( "keyAssignmentOff", "keyAssignmentOn", -44, -26, 
		switchToKeyAssignment, self:setPlayerPositionEvent( settingsMenu.x - 51, -21 ),nil,'Key Bindings' )
	local s = settingsMenu:addBambooSlider( "soundOptionsOff", "soundOptionsOn", -44, -16, 40, 6,
		self:setPlayerPositionEvent( settingsMenu.x - 51, -11), changeEffectVolume,
		{ "0%", "20%", "40%", "60%", "80%", "100%" }, "Effect volume: " )
	s:setValue( settings:getEffectVolume()/20+1 )
	local s = settingsMenu:addBambooSlider( "musicOff", "musicOn", -44, -6, 40, 6,
		self:setPlayerPositionEvent( settingsMenu.x - 51, -1), changeMusicVolume,
		{ "0%", "20%", "40%", "60%", "80%", "100%" }, "Music volume: " )
	s:setValue( settings:getMusicVolume()/20+1 )
	
	local b = settingsMenu:addToggleButton( "toFullscreenOff", "toFullscreenOn",
		"toWindowedOff", "toWindowedOn", -44, 4, 
		toggleFullscreen, self:setPlayerPositionEvent( settingsMenu.x - 51, 9 ),
		{[true]="Fullscreen", [false]="Windowed"} )
	b:setValue( settings:getFullscreen() )

	local b = settingsMenu:addToggleButton( "noShadersOff", "noShadersOn",
		"shadersOff", "shadersOn", -44, 14, 
		toggleShaders, self:setPlayerPositionEvent( settingsMenu.x - 51, 19 ),
		{[true]="on", [false]="off"}, "Shaders: " )
	b:setValue( settings:getShadersEnabled() )

	local s = settingsMenu:addBambooSlider( "musicOff", "musicOn", -44, 24, 20, 3,
		self:setPlayerPositionEvent( settingsMenu.x - 51, 29), setBackgroundDetail,
		{ "No Background", "Simple Background", "Detailed background" } )
	s:setValue( settings:getBackgroundDetail() )	
		
	settingsMenu:addButton( "resetOff", "resetOn", -44, 34,
		resetCampaign, self:setPlayerPositionEvent( settingsMenu.x -51, 39), nil, 'Reset Campaign' )

	settingsMenu:addHotkey( "CHOOSE", "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )
	settingsMenu:addHotkey( "BACK", "Save & Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		backToMain )

	local restartNotificationVis = 
		Visualizer:New( nil, nil, "Restart game to apply changes!" )
	local curstomSettingsDrawFnc = function()
		if settings.needsRestart then
			restartNotificationVis:draw( 0,
				Camera.scale*(love.graphics.getHeight()/Camera.scale/2 - 16) )
		end
	end

	settingsMenu:addCustomDrawFunction( curstomSettingsDrawFnc )

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
	local creditsMenu = Submenu:new(700,0)
	local t
	creditsMenu:addPanel(-104, -70, 200, 120)
	
	creditsMenu:addImage( "creditsDesign", -75, -62 ) 
	creditsMenu:addImage( "creditsGraphics", -48, -32 )
	creditsMenu:addImage( "creditsProgramming", -85, 0)
	creditsMenu:addImage( "creditsMusic", 10, -62 )
	creditsMenu:addImage( "creditsSound", 52, -32 )
	creditsMenu:addImage( "creditsFramework", 8, 0 )

	creditsMenu:addText( 'Design', -55, -60, 40 ,nil,'left',colors.text,fontLarge)
	creditsMenu:addText( 'Art', -90, -28, 40 ,nil,'right',colors.text,fontLarge)
	creditsMenu:addText( 'Programming', -55, 4, 50 ,nil,'left',colors.text,fontLarge)
	creditsMenu:addText( 'Music', 53, -60, 40 ,nil,'left',colors.text,fontLarge)
	creditsMenu:addText( 'Sound', 8, -28, 40 ,nil,'right',colors.text,fontLarge)
	creditsMenu:addText( 'Framework', 53, 4, 45 ,nil,'left',colors.text,fontLarge)
	creditsMenu:addText( 'Special Thanks to', -90, 30, 100 ,nil,'left',colors.text,fontLarge)
	
	creditsMenu:addText( 'Michael Sinsbeck', -50, -52, 40 ,nil,'left',colors.blueText)
	creditsMenu:addText( 'Michael Sinsbeck\nMicha Pfeiffer', -95, -20, 40 ,nil,'right',colors.blueText)
	creditsMenu:addText( 'Michael Sinsbeck\nMicha Pfeiffer', -50, 12, 40 ,nil,'left',colors.blueText)
	creditsMenu:addText( 'Max Ackermann', 58, -52, 40 ,nil,'left',colors.blueText)
	creditsMenu:addText( 'Thomas Stötzner\nMichael Sinsbeck\nLukas Nowok', 3, -20, 40 ,nil,'right',colors.blueText)
	creditsMenu:addText( 'www.love2d.org', 58, 12, 40 ,nil,'left',colors.blueText)
	creditsMenu:addText( 'Sibel, Ramona, Kathrin', -83, 38, 40 ,nil,'left',colors.blueText)
	

	local function quitCredits()
	--	Credits:stop()
		menu:switchToSubmenu( "Main" )	
	end
	
	creditsMenu:addHotkey( "BACK", "Back to Main",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 12,
		quitCredits )
		
	submenus["Credits"] = creditsMenu

	-- Create the Rating Submenu:
	local ratingMenu = RatingSubmenu:new( 700, 0 )
	submenus["Rating"] = ratingMenu

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
	parallax:init(nil,nil,nil,2,0,nil,1)

	-- Switch to showing the menu:
	mode = 'menu'
end

function menu:switchToSubmenu( menuName )
	if menuName == "Pause" then
		menuName = "Worldmap"		-- DEBUG
	end

	self.overlaySubmenu = nil		-- Remove any possible active overlay menus

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
		self:slideCameraTo(700,0,0.5)
	--elseif menuName == "Rating" then
		--self:slideCameraTo(1400,0,0.5)
	end

	menu:setPlayerDirection( "right" )

	print("New active Submenu:", self.activeSubmenu )
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

function menu:setCameraToTarget()
	self.xCamera = self.xTarget
	self.yCamera = self.yTarget
	self.cameraSlideTime = nil
end

function menu:update( dt )
	if not self.overlaySubmenu then
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

		submenus[self.activeSubmenu]:update( dt )
	else
		submenus[self.overlaySubmenu]:update( dt )
	end

	menuPlayer.vis:update(dt/2)
	menuPlayer.visBandana:update(dt/2)
end

function menu:updateLevelName( dt )
end

function menu:draw()
	if not self.overlaySubmenu then
		parallax:draw()
	end

	love.graphics.push()
	love.graphics.translate(
	-math.floor(self.xCamera*Camera.scale)+love.graphics.getWidth()/2,
	-math.floor(self.yCamera*Camera.scale)+love.graphics.getHeight()/2 )

	if not self.overlaySubmenu then
		if self.previousSubmenu and self.previousSubmenu ~= self.activeSubmenu then
			submenus[self.previousSubmenu]:draw()
		end
		-- Draw all visible panels:
		if self.activeSubmenu then
			submenus[self.activeSubmenu]:draw()
		end
	else
		-- If there is an active overlaySubmenu, then draw this instead.
		submenus[self.overlaySubmenu]:draw()
	end

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

	love.graphics.pop()
end

-- Remove every panel
function menu:clear()
	submenus = {}
end

function menu:keypressed( key, repeated )
	if menu.lockedInBridgeAnimation then -- no keypressed during bridge animation
		return
	end
	if fader.active and 
	   (key == keys.CHOOSE or key == keys.BACK) then -- cannot start a level, when animation is running
		return
	end
	if key == keys.BACK then
		Sound:play('menuBack')
	end

	local currentMenu = self.activeSubmenu
	if self.overlaySubmenu then
		currentMenu = self.overlaySubmenu
	end

	if currentMenu then
		if currentMenu == "KeyAssignment" and
			KeyAssignmentSubmenu.keyCurrentlyAssigning ~= nil then
			-- Only assign if not taken by hotkey:
			if not submenus[currentMenu]:hotkey( key ) then
				KeyAssignmentSubmenu:assignKey( key )
			end
		else
			if key == keys.LEFT then
				submenus[currentMenu]:goLeft()
			elseif key == keys.RIGHT then
				submenus[currentMenu]:goRight()
			elseif key == keys.UP then
				submenus[currentMenu]:goUp()
			elseif key == keys.DOWN then
				submenus[currentMenu]:goDown()
			elseif key == keys.CHOOSE then
				submenus[currentMenu]:startButtonEvent()
			else
				submenus[currentMenu]:hotkey( key )
			end
		end
	end
end

function menu:gamepadpressed( button )
	if menu.lockedInBridgeAnimation then -- no keypressed during bridge animation
		return
	end

	if fader.active and
	   (button..'' == keys.PAD.CHOOSE or button..'' == keys.PAD.BACK) then
		return
	end
	
	local currentMenu = self.activeSubmenu
	if self.overlaySubmenu then
		currentMenu = self.overlaySubmenu
	end

	if currentMenu then
		key = tostring( button )
		if currentMenu == "KeyAssignment" and
			KeyAssignmentSubmenu.keyCurrentlyAssigning ~= nil then
			-- Only assign if not taken by hotkey:
			if not submenus[currentMenu]:gamepadHotkey( key ) then
				KeyAssignmentSubmenu:assignPad( key )
			end
		else
			if key == keys.PAD.LEFT then
				submenus[currentMenu]:goLeft()
			elseif key == keys.PAD.RIGHT then
				submenus[currentMenu]:goRight()
			elseif key == keys.PAD.UP then
				submenus[currentMenu]:goUp()
			elseif key == keys.PAD.DOWN then
				submenus[currentMenu]:goDown()
			elseif key == keys.PAD.CHOOSE then
				submenus[currentMenu]:startButtonEvent()
			else
				submenus[currentMenu]:gamepadHotkey( key )
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
	WorldmapSubmenu:createButtons( levelNumber )
	WorldmapSubmenu:selectCurrentLevel( levelNumber )
end

function menu:createWorldButtons()
	local lastLevel = Campaign.last
	local currentLevel = Campaign.current
	WorldmapSubmenu:createButtons( lastLevel )
end
function menu:resetWorldButtons()
	WorldmapSubmenu:resetButtons()
	--local lastLevel = Campaign.last
	--local currentLevel = Campaign.current
	--WorldmapSubmenu:createButtons( lastLevel, currentLevel )
end
function menu:selectCurrentLevel()
	WorldmapSubmenu:selectCurrentLevel( Campaign.current )
end

function menu:selectLastLevel()
	WorldmapSubmenu:selectLastLevel( )
end

function menu:nextWorld( worldNumber )
	self:switchToSubmenu( "Worldmap" )
	self:selectLastLevel()
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

---------------------------------------------------------
-- Handle Overlay Submenus
---------------------------------------------------------
-- Overlay submenus are menus which will be displayed above the current game.
-- These do NOT slide.
-- Used for Pause menu and Rating Menu

function menu:setOverlaySubmenu( name )
	self.overlaySubmenu = name
	menu:setPlayerDirection( "right" )
	if submenus[self.overlaySubmenu] then
		submenus[self.overlaySubmenu]:activate()
		submenus[self.overlaySubmenu]:reselectButton()
	end
end

return menu
