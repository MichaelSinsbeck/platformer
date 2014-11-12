
local menu = {
	curLevelName = "",
	transitionActive = false,
	transitionPercentage = 0,
	state = "main",
}

local transition = require( "scripts/menu/transition" )
local Submenu = require( "scripts/menu/submenu" )

local submenus = {}

function menu:init()

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
	if menu.state == "main" then
		parallax:update(dt)
	end
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

return menu
