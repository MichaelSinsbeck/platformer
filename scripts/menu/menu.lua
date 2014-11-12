
local menu = {
	curLevelName = "",
	transitionActive = false,
	transitionPercentage = 0,
	state = "main",
	activeSubmenu = "Main"
}

local transition = require( "scripts/menu/transition" )
local Submenu = require( "scripts/menu/submenu" )

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
end

function menu:initMain()
	mode = 'menu'

	self.xCamera = 0
	self.yCamera = 0
	self.xTarget = 0
	self.yTarget = 0

	-- initialize parallax background
	parallax:init()

	local mainMenu = Submenu:new()
	mainMenu:addImage( "logo", -85, -78 )
	local p = mainMenu:addPanel( -24, -17, 48, 80 )
	local b = mainMenu:addButton( "startOff", "startOn", -3, -7 )
	mainMenu:setSelectedButton( b )
	
	mainMenu:addButton( "downloadOff", "downloadOn", -2, 0 )
	mainMenu:addButton( "settingsOff", "settingsOn", -2, 10 )
	mainMenu:addButton( "editorOff", "editorOn", -2, 20 )
	mainMenu:addButton( "creditsOff", "creditsOn", -2, 30 )
	mainMenu:addButton( "exitOff", "exitOn", -2, 40 )
	
	--[[for k = 1, 25 do
		x = love.math.random( -40, 40 )
		y = love.math.random( -40, 40 )
		mainMenu:addButton( "startOff", "startOn", x, y )
	end]]
	mainMenu:linkButtons( "MainLayer")

	submenus["Main"] = mainMenu

	menu:switchToSubmenu( "Main" )
end

function menu:switchToSubmenu( menuName )
	menu.activeSubmenu = menuName
end

function menu:update( dt )
	--if menu.state == "main" then
		parallax:update(dt)
	--end

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

	-- Draw all visible panels:
	submenus[self.activeSubmenu]:draw()

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

function menu:drawTransition()
end

-- Todo: move this to GUI?
function menu:drawLevelName()
end

function menu:keypressed( key, repeated )
	if key == "escape" then
		love.event.quit()
	end
	if self.activeSubmenu then
		if key == "left" then
			submenus[self.activeSubmenu]:goLeft()
		elseif key == "right" then
			submenus[self.activeSubmenu]:goRight()
		elseif key == "up" then
			submenus[self.activeSubmenu]:goUp()
		elseif key == "down" then
			submenus[self.activeSubmenu]:goDown()
		end
	end
end

function menu:textinput( letter )
end

function menu:downloadedVersionInfo( info )
end

function menu:setPlayerPosition( x, y )
end

function menu:setPlayerAnimation( animation )
	menuPlayer.x = x
	menuPlayer.y = y
end

return menu
