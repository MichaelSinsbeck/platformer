
local menu = {
	curLevelName = "",
	transitionActive = false,
	transitionPercentage = 0,
	state = "main",
}

local transition = require( "scripts/menu/transition" )
local Submenu = require( "scripts/menu/submenu" )

local submenus = {}

local menuPlayer = {
	x = 0,
	y = 0,
}

function menu:init()
	menuPlayer.vis = Visualizer:New( "playerWalk" )
	menuPlayer.visBandana = Visualizer:New("bandanaWalk")
	menuPlayer.vis:init()
	menuPlayer.visBandana:init()

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
	local p = mainMenu:addPanel( -24, -16, 48, 64 )
	submenus["Main"] = mainMenu

	mainMenu:addImage( "logo", -85, -78 )
end

function menu:update( dt )
	--if menu.state == "main" then
		parallax:update(dt)
	--end

	menuPlayer.vis:update(dt/2)
	menuPlayer.visBandana:update(dt/2)
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
	for i, m in pairs( submenus ) do
		m:draw()
	end

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
