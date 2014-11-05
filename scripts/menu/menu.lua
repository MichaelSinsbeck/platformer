
local menu = {
	curLevelName = "",
	transitionActive = false,
	transitionPercentage = 0,
	state = "main",
}

local transition = require( "scripts/menu/transition" )

function menu:init()

end

function menu:initMain()
	mode = 'menu'
end

function menu:update( dt )
end

function menu:updateLevelName( dt )
end


function menu:draw()
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
