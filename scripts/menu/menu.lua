
local menu = {
	curLevelName = "",
	transitionActive = false,
	transitionPercentage = 0,
	state = "main",
	activeSubmenu = "Main",
	parallaxPos = 0
}

local Submenu = require( "scripts/menu/submenu" )
local UserlevelSubmenu = require( "scripts/menu/userlevelsubmenu" )

local submenus = {}

local menuPlayer = {
	x = 0,
	y = 0,
}

function menu:init()

	self.xCamera = 0
	self.yCamera = 0
	self.xTarget = 0
	self.yTarget = 0

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

	mainMenu:addButton( "startOff", "startOn", -3, -10,
		switchToWorldMap, self:setPlayerPositionEvent( -6, -5) )
	mainMenu:addButton( "downloadOff", "downloadOn", -2, 0,
		switchToUserlevels, self:setPlayerPositionEvent( -6, 5) )
	mainMenu:addButton( "settingsOff", "settingsOn", -2, 10,
		switchToSettings, self:setPlayerPositionEvent( -6, 15) )
	mainMenu:addButton( "editorOff", "editorOn", -2, 20,
		nil, self:setPlayerPositionEvent( -6, 25) )
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
	local worldMapMenu = Submenu:new( 0, -700 )
	submenus["Worldmap"] = worldMapMenu
	local backToMain = function()
		menu:switchToSubmenu( "Main" )
	end
	worldMapMenu:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )
	worldMapMenu:addHotkey( keys.BACK, keys.PAD.BACK, "Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		backToMain )

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
	soundMenu:addPanel( -64, -20, 112, 50 )

	soundMenu:addSlider( -16, -10, 40, 6,
		self:setPlayerPositionEvent( soundMenu.x - 20, -5), nil,
		{ "0%", "20%", "40%", "60%", "80%", "100%" }, "Effect volume:" )
	soundMenu:addSlider( -16, 0, 40, 6,
		self:setPlayerPositionEvent( soundMenu.x - 20, 5), nil,
		{ "0%", "20%", "40%", "60%", "80%", "100%" }, "Music volume:" )

	local backToSettings = function()
		menu:switchToSubmenu( "Settings" )
	end
	soundMenu:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )
	soundMenu:addHotkey( keys.BACK, keys.PAD.BACK, "Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		backToSettings )

	submenus["Sound"] = soundMenu

	local graphicsMenu = Submenu:new( -1400, 0 )
	graphicsMenu:addPanel( -64, -20, 112, 50 )

	graphicsMenu:addToggleButton( "toFullscreenOff", "toFullscreenOn",
		"toWindowedOff", "toWindowedOn", -19, -10, 
		toggleFullscreen, self:setPlayerPositionEvent( graphicsMenu.x - 23, -5 ),
		{[true]="Fullscreen", [false]="windowed"}, "Fullscreen:" )

	graphicsMenu:addSlider( -19, 0, 20, 3,
		self:setPlayerPositionEvent( graphicsMenu.x - 23, 5), nil,
		{ "Simple", "Detailed", "Very detailed" }, "Graphics:" )

	local backToSettings = function()
		menu:switchToSubmenu( "Settings" )
	end
	graphicsMenu:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		nil )
	graphicsMenu:addHotkey( keys.BACK, keys.PAD.BACK, "Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 24,
		backToSettings )

	submenus["Graphics"] = graphicsMenu

	local width = love.graphics.getWidth()/Camera.scale - 16
	local height = love.graphics.getHeight()/Camera.scale - 32
	local keyAssignment = Submenu:new( -1400, 0 )
	local p = keyAssignment:addPanel( -width/2, -height/2 - 8, width, height )
	p:turnIntoList( 16, 1 )

	keyAssignment:addHotkey( keys.CHOOSE, keys.PAD.CHOOSE, "Choose",
		love.graphics.getWidth()/Camera.scale/2 - 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		nil )
	keyAssignment:addHotkey( keys.BACK, keys.PAD.BACK, "Back",
		-love.graphics.getWidth()/Camera.scale/2 + 24,
		love.graphics.getHeight()/Camera.scale/2 - 16,
		backToSettings )

	submenus["KeyAssignment"] = keyAssignment

	-- initialize parallax background
	parallax:init()
end

function menu:initMain()
	mode = 'menu'

	--menu:switchToSubmenu( "Main" )
	menu:switchToSubmenu( "Main" )
end

function menu:switchToSubmenu( menuName )

	print(menuName)
	print(submenus[menuName])
	self.previousSubmenu = self.activeSubmenu

	self.activeSubmenu = menuName
	submenus[self.activeSubmenu]:reselectButton()
	submenus[self.activeSubmenu]:activate()
	--submenus[menu.activeSubmenu]:startIntroTransition()

	if menuName == "Main" then
		self.xTarget = 0
		self.yTarget = 0
		self.xCameraStart = self.xCamera
		self.yCameraStart = self.yCamera
		self.cameraSlideTime = 0.5
		self.cameraPassedTime = 0
	elseif menuName == "Worldmap" then
		self.xTarget = 0
		self.yTarget = -700
		self.xCameraStart = self.xCamera
		self.yCameraStart = self.yCamera
		self.cameraSlideTime = 0.5
		self.cameraPassedTime = 0
	elseif menuName == "Userlevels" then
		self.xTarget = 700
		self.yTarget = 0
		self.xCameraStart = self.xCamera
		self.yCameraStart = self.yCamera
		self.cameraSlideTime = 0.5
		self.cameraPassedTime = 0
	elseif menuName == "Settings" then
		self.xTarget = -700
		self.yTarget = 0
		self.xCameraStart = self.xCamera
		self.yCameraStart = self.yCamera
		self.cameraSlideTime = 0.5
		self.cameraPassedTime = 0
	elseif menuName == "Sound" or
		menuName == "Graphics" or
		menuName == "KeyAssignment" then
		self.xTarget = -1400
		self.yTarget = 0
		self.xCameraStart = self.xCamera
		self.yCameraStart = self.yCamera
		self.cameraSlideTime = 0.5
		self.cameraPassedTime = 0
	end
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
		-math.floor(self.yCamera*Camera.scale)+love.graphics.getHeight()/2)

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

return menu
