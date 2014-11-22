
local menu = {
	curLevelName = "",
	transitionActive = false,
	transitionPercentage = 0,
	state = "main",
	activeSubmenu = "Main",
	parallaxPos = 0,
	xCamera = 0,
	yCamera = 0,
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
	mainMenu:addPanel( -24, -20, 48, 80 )

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
	local switchToEditor = function()
		self:switchToSubmenu( "Editor" )
	end

	mainMenu:addButton( "startOff", "startOn", -3, -10,
		switchToWorldMap, self:setPlayerPositionEvent( -6, -5) )
	mainMenu:addButton( "downloadOff", "downloadOn", -2, 0,
		switchToUserlevels, self:setPlayerPositionEvent( -6, 5) )
	mainMenu:addButton( "settingsOff", "settingsOn", -2, 10,
		switchToSettings, self:setPlayerPositionEvent( -6, 15) )
	mainMenu:addButton( "editorOff", "editorOn", -2, 20,
		switchToEditor, self:setPlayerPositionEvent( -6, 25) )
	mainMenu:addButton( "creditsOff", "creditsOn", -2, 30,
		nil, self:setPlayerPositionEvent( -6, 35) )

	local quit = function()
		--mainMenu:startExitTransition( love.event.quit )
		love.event.quit()
	end

	mainMenu:addButton( "exitOff", "exitOn", -2, 40,
		quit, self:setPlayerPositionEvent( -6, 45) )

	mainMenu:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )

	mainMenu:addHotkey( keys.BACK, keys.PAD.BACK, "Exit",
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

	local switchToSound = function()
		menu:switchToSubmenu( "Sound" )
	end
	local switchToGraphics = function()
		menu:switchToSubmenu( "Graphics" )
	end
	local switchToKeyAssignment = function()
		menu:switchToSubmenu( "KeyAssignment" )
	end

	local settingsMenu = Submenu:new( -700, 0 )
	settingsMenu:addPanel( -32, -20, 64, 50 )
	settingsMenu:addButton( "soundOptionsOff", "soundOptionsOn", -3, -10, 
		switchToSound, self:setPlayerPositionEvent( settingsMenu.x - 10, -5 ) )
	settingsMenu:addButton( "graphicsOptionsOff", "graphicsOptionsOn", -3, 0, 
		switchToGraphics, self:setPlayerPositionEvent( settingsMenu.x - 10, 5 ) )
	settingsMenu:addButton( "keyAssignmentOff", "keyAssignmentOn", -3, 10, 
		switchToKeyAssignment, self:setPlayerPositionEvent( settingsMenu.x - 14, 15 ) )

	local backToMain = function()
		menu:switchToSubmenu( "Main" )
	end
	settingsMenu:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )
	settingsMenu:addHotkey( keys.BACK, keys.PAD.BACK, "Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		backToMain )

	submenus["Settings"] = settingsMenu

	local soundMenu = Submenu:new( -1400, 0 )
	local p = soundMenu:addPanel( -64, -20, 112, 40 )
	p:turnIntoList( 10, 1 )

	local changeEffectVolume = function( val )
		settings:setEffectVolume( (val-1)*20 )
	end
	local changeMusicVolume = function( val )
		settings:setMusicVolume( (val-1)*20 )
	end

	local backToSettingsSaveAudio = function()
		settings:saveAudio()
		menu:switchToSubmenu( "Settings" )
	end

	local s = soundMenu:addSlider( -46, -10, 40, 6,
		self:setPlayerPositionEvent( soundMenu.x - 50, -5), changeEffectVolume,
		{ "0%", "20%", "40%", "60%", "80%", "100%" }, "Effect volume: " )
	s:setValue( settings:getEffectVolume()/20+1 )
	local s = soundMenu:addSlider( -46, 0, 40, 6,
		self:setPlayerPositionEvent( soundMenu.x - 50, 5), changeMusicVolume,
		{ "0%", "20%", "40%", "60%", "80%", "100%" }, "Music volume: " )
	s:setValue( settings:getMusicVolume()/20+1 )

	soundMenu:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )
	soundMenu:addHotkey( keys.BACK, keys.PAD.BACK, "Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		backToSettingsSaveAudio )

	submenus["Sound"] = soundMenu

	local graphicsMenu = Submenu:new( -1400, 0 )
	local p = graphicsMenu:addPanel( -64, -20, 112, 50 )
	p:turnIntoList( 10, 1 )

	local backToSettingsSaveGraphics = function()
		settings:saveGraphics()
		menu:switchToSubmenu( "Settings" )
	end
	local toggleFullscreen = function( bool )
		--print(bool)
		--settings:toggleFullScreen( bool )
		settings:toggleFullScreen()
		self:switchToSubmenu( "Graphics" )
	end
	local toggleShaders = function( bool )
		settings:setShadersEnabled( bool )
	end
	local setBackgroundDetail = function( val )
		settings:setBackgroundDetail( val )
	end

	local b = graphicsMenu:addToggleButton( "toFullscreenOff", "toFullscreenOn",
		"toWindowedOff", "toWindowedOn", -32, -10, 
		toggleFullscreen, self:setPlayerPositionEvent( graphicsMenu.x - 36, -5 ),
		{[true]="Fullscreen", [false]="Windowed"} )
	b:setValue( settings:getFullscreen() )

	local b = graphicsMenu:addToggleButton( "noShadersOff", "noShadersOn",
		"shadersOff", "shadersOn", -32, 0, 
		toggleShaders, self:setPlayerPositionEvent( graphicsMenu.x - 36, 5 ),
		{[true]="on", [false]="off"}, "Shaders: " )
	b:setValue( settings:getShadersEnabled() )

	local s = graphicsMenu:addSlider( -32, 10, 20, 3,
		self:setPlayerPositionEvent( graphicsMenu.x - 36, 15), setBackgroundDetail,
		{ "No Background", "Simple Background", "Detailed background" } )
	s:setValue( settings:getBackgroundDetail() )

	graphicsMenu:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )
	graphicsMenu:addHotkey( keys.BACK, keys.PAD.BACK, "Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		backToSettingsSaveGraphics )

	submenus["Graphics"] = graphicsMenu

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


	-- initialize parallax background
	parallax:init()

	if love.joystick.getJoystickCount() ~= 0 then
		self:connectedGamepad()
	end

	--print( self.xCamera, self.yCamera )

end

function menu:initMain()
	--menu:switchToSubmenu( "Main" )
	menu:switchToSubmenu( "Main" )
end

function menu:switchToSubmenu( menuName )

	if menuName == "Pause" then menuName = "Worldmap" end	-- DEBUG

	mode = 'menu'

	self.previousSubmenu = self.activeSubmenu

	self.activeSubmenu = menuName
	submenus[self.activeSubmenu]:reselectButton()
	--submenus[menu.activeSubmenu]:startIntroTransition()

	if menuName == "Main" then
		self:slideCameraTo( 0, 0, 0.5 )
	elseif menuName == "Worldmap" then
		--self:slideCameraTo( 0, -700, 0.5 )
		WorldmapSubmenu:scroll()
	elseif menuName == "Userlevels" then
		self:slideCameraTo( 700, 0, 0.5 )
	elseif menuName == "Settings" then
		self:slideCameraTo( -700, 0, 0.5 )
	elseif menuName == "Sound" or
		menuName == "Graphics" or
		menuName == "KeyAssignment" then
		self:slideCameraTo( -1400, 0, 0.5 )
	elseif menuName == "Editor" then
		self:slideCameraTo( 0, 1000, 0.5 )
	end
end

-- Slide camera to a position over a short period of time
function menu:slideCameraTo( x, y, time )
	if not self.cameraSlideTime or 
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
end

function menu:update( dt )
	--if menu.state == "main" then
		--parallax:update(dt)
	parallax:setPosition( -self.xCamera )
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

function menu:drawTransition()
end

-- Todo: move this to GUI?
function menu:drawLevelName()
end

function menu:keypressed( key, repeated )
	if self.activeSubmenu then
		-- Don't let user control menu while a transition is active:
		--if not submenus[self.activeSubmenu]:getTransition() then
			if key == keys.LEFT then
				submenus[self.activeSubmenu]:goLeft()
			elseif key == keys.RIGHT then
				submenus[self.activeSubmenu]:goRight()
			elseif key == keys.UP then
				submenus[self.activeSubmenu]:goUp()
			elseif key == keys.DOWN then
				submenus[self.activeSubmenu]:goDown()
			elseif key == keys.CHOOSE then
				submenus[self.activeSubmenu]:startButtonEvent()
			else
				submenus[self.activeSubmenu]:hotkey( key )
			end
		--end
	end
end

function menu:gamepadpressed( button )
	if self.activeSubmenu then
		key = tostring( button )
		-- Don't let user control menu while a transition is active:
		--if not submenus[self.activeSubmenu]:getTransition() then
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
		--end
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
		config.setValue( "level", lvl )

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
		config.setValue( "level", lvl )

		gui.clearBandanas()
	end
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

return menu
