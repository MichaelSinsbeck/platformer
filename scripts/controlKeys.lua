-- Used to show the player which keys to hit in order to get to other menus,
-- continue after death and after winning a level etc:

local controlKeys = {}
local death = {}
local win = {}
local menuControl = {}
local menuUserlevels = {}
local menuUserlevelsDelete = {}
local menuFilters = {}
local rating = {}
local toDraw

function controlKeys:draw( drawMode )

	local x, y

	if drawMode == "death" then
		toDraw = death
	elseif drawMode == "win" then
		toDraw = win
	elseif drawMode == "menu" then
		if menu:getFiltersVisible() then
			toDraw = menuFilters
		elseif menu.state == "userlevels" then
			if menu:getIsDownloaded() then
				toDraw = menuUserlevelsDelete
			else
				toDraw = menuUserlevels
			end
		else
			toDraw = menuControl
		end
	elseif drawMode == "rating" then
		toDraw = rating
	end
	
	if mode == "menu" and menu.state == "pause" and toDraw ~= menuControl then return end
	love.graphics.setFont( fontSmall )
	
	y = love.graphics.getHeight() - 60
	
	if love.joystick.getJoystickCount() == 0 then
		for k = 1, #toDraw do
			x, y = toDraw[k].x, toDraw[k].y
			love.graphics.draw( toDraw[k].img, x*Camera.scale, y*Camera.scale)
			love.graphics.print( toDraw[k].txt:upper(),
							math.floor((x+toDraw[k].offset)*Camera.scale),
							math.floor((y+3)*Camera.scale) )							
			love.graphics.print( toDraw[k].label:upper(),
							math.floor((toDraw[k].labelX)*Camera.scale),
							math.floor((y-3)*Camera.scale) )
		end
	else
		for k = 1, #toDraw do
			x, y = toDraw[k].x, toDraw[k].y
			love.graphics.draw( toDraw[k].img, x*Camera.scale, y*Camera.scale)
			
			love.graphics.print( toDraw[k].label:upper(),
							math.floor((toDraw[k].labelX)*Camera.scale),
							math.floor((y-3)*Camera.scale) )
		end
	end
end

function controlKeys:setup()
	if love.joystick.getJoystickCount() == 0 then
		death = {}
		death[1] = {}
		death[1].label = "Retry"
		death[1].txt = nameForKey( keys.CHOOSE )
		death[1].img = menu:getImage(getImageForKey( keys.CHOOSE ))
		death[1].offset = (death[1].img:getWidth() - fontSmall:getWidth(death[1].txt))/2/Camera.scale
		death[1].x = (love.graphics.getWidth()-death[1].img:getWidth())/Camera.scale - 6
		death[1].labelX = (death[1].x*Camera.scale + death[1].img:getWidth() -
						fontSmall:getWidth(death[1].label))/Camera.scale
		death[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		death[2] = {}
		death[2].label = "Leave"
		death[2].txt = nameForKey( keys.BACK )
		death[2].img = menu:getImage(getImageForKey( keys.BACK ))
		death[2].offset = (death[2].img:getWidth() - fontSmall:getWidth(death[2].txt))/2/Camera.scale
		death[2].x = 6
		death[2].labelX = death[2].x
		death[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win = {}
		win[1] = {}
		win[1].label = "Continue"
		win[1].txt = nameForKey( keys.CHOOSE )
		win[1].img = menu:getImage(getImageForKey( keys.CHOOSE ))
		win[1].offset = (win[1].img:getWidth() - fontSmall:getWidth(win[1].txt))/2/Camera.scale
		win[1].x = (love.graphics.getWidth()-win[1].img:getWidth())/Camera.scale - 6
		win[1].labelX = (win[1].x*Camera.scale + win[1].img:getWidth() -
						fontSmall:getWidth(win[1].label))/Camera.scale
		win[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win[2] = {}
		win[2].label = "Leave"
		win[2].txt = nameForKey( keys.BACK )
		win[2].img = menu:getImage(getImageForKey( keys.BACK ))
		win[2].offset = (win[2].img:getWidth() - fontSmall:getWidth(win[2].txt))/2/Camera.scale
		win[2].x = 6
		win[2].labelX = win[2].x
		win[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl = {}
		menuControl[1] = {}
		menuControl[1].label = "Choose"
		menuControl[1].txt = nameForKey( keys.CHOOSE )
		menuControl[1].img = menu:getImage(getImageForKey( keys.CHOOSE ))
		menuControl[1].offset = (menuControl[1].img:getWidth() - fontSmall:getWidth(menuControl[1].txt))/2/Camera.scale
		menuControl[1].x = (love.graphics.getWidth()-menuControl[1].img:getWidth())/Camera.scale - 6
		menuControl[1].labelX = (menuControl[1].x*Camera.scale + menuControl[1].img:getWidth() -
						fontSmall:getWidth(menuControl[1].label))/Camera.scale
		menuControl[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl[2] = {}
		menuControl[2].label = "Back"
		menuControl[2].txt = nameForKey( keys.BACK )
		menuControl[2].img = menu:getImage(getImageForKey( keys.BACK ))
		menuControl[2].offset = (menuControl[2].img:getWidth() - fontSmall:getWidth(menuControl[2].txt))/2/Camera.scale
		menuControl[2].x = 6
		menuControl[2].labelX = menuControl[2].x
		menuControl[2].y = (love.graphics.getHeight())/Camera.scale - 20

		menuUserlevels = {}
		menuUserlevels[1] = {}
		menuUserlevels[1].label = "Choose"
		menuUserlevels[1].txt = nameForKey( keys.CHOOSE )
		menuUserlevels[1].img = menu:getImage(getImageForKey( keys.CHOOSE ))
		menuUserlevels[1].offset = (menuUserlevels[1].img:getWidth() - fontSmall:getWidth(menuUserlevels[1].txt))/2/Camera.scale
		menuUserlevels[1].x = (love.graphics.getWidth()-menuUserlevels[1].img:getWidth())/Camera.scale - 6
		menuUserlevels[1].labelX = (menuUserlevels[1].x*Camera.scale + menuUserlevels[1].img:getWidth() -
						fontSmall:getWidth(menuUserlevels[1].label))/Camera.scale
		menuUserlevels[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuUserlevels[2] = {}
		menuUserlevels[2].label = "Back"
		menuUserlevels[2].txt = nameForKey( keys.BACK )
		menuUserlevels[2].img = menu:getImage(getImageForKey( keys.BACK ))
		menuUserlevels[2].offset = (menuUserlevels[2].img:getWidth() - fontSmall:getWidth(menuUserlevels[2].txt))/2/Camera.scale
		menuUserlevels[2].x = 6
		menuUserlevels[2].labelX = menuUserlevels[2].x
		menuUserlevels[2].y = (love.graphics.getHeight())/Camera.scale - 20

		menuUserlevels[3] = {}
		menuUserlevels[3].label = "Filters and Sorting"
		menuUserlevels[3].txt = nameForKey( keys.FILTERS )
		menuUserlevels[3].img = menu:getImage(getImageForKey( keys.FILTERS ))
		menuUserlevels[3].offset = (menuUserlevels[3].img:getWidth() - fontSmall:getWidth(menuUserlevels[3].txt))/2/Camera.scale
		menuUserlevels[3].x = 0.75*(love.graphics.getWidth()-menuUserlevels[3].img:getWidth())/Camera.scale
		menuUserlevels[3].labelX = menuUserlevels[3].x +menuUserlevels[3].offset- fontSmall:getWidth(menuUserlevels[3].label)/2/Camera.scale
		menuUserlevels[3].y = (love.graphics.getHeight())/Camera.scale - 20

		menuUserlevels[4] = {}
		menuUserlevels[4].label = "REFRESH"
		menuUserlevels[4].txt = nameForKey( keys.REFRESH )
		menuUserlevels[4].img = menu:getImage(getImageForKey( keys.REFRESH ))
		menuUserlevels[4].offset = (menuUserlevels[4].img:getWidth() - fontSmall:getWidth(menuUserlevels[4].txt))/2/Camera.scale
		menuUserlevels[4].x = 0.25*(love.graphics.getWidth()-menuUserlevels[4].img:getWidth())/Camera.scale
		menuUserlevels[4].labelX = menuUserlevels[4].x +menuUserlevels[4].offset- fontSmall:getWidth(menuUserlevels[4].label)/2/Camera.scale
		menuUserlevels[4].y = (love.graphics.getHeight())/Camera.scale - 20

		menuUserlevelsDelete = {}
		menuUserlevelsDelete[1] = {}
		menuUserlevelsDelete[1].label = "Choose"
		menuUserlevelsDelete[1].txt = nameForKey( keys.CHOOSE )
		menuUserlevelsDelete[1].img = menu:getImage(getImageForKey( keys.CHOOSE ))
		menuUserlevelsDelete[1].offset = (menuUserlevelsDelete[1].img:getWidth() - fontSmall:getWidth(menuUserlevelsDelete[1].txt))/2/Camera.scale
		menuUserlevelsDelete[1].x = (love.graphics.getWidth()-menuUserlevelsDelete[1].img:getWidth())/Camera.scale - 6
		menuUserlevelsDelete[1].labelX = (menuUserlevelsDelete[1].x*Camera.scale + menuUserlevelsDelete[1].img:getWidth() -
						fontSmall:getWidth(menuUserlevelsDelete[1].label))/Camera.scale
		menuUserlevelsDelete[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuUserlevelsDelete[2] = {}
		menuUserlevelsDelete[2].label = "Back"
		menuUserlevelsDelete[2].txt = nameForKey( keys.BACK )
		menuUserlevelsDelete[2].img = menu:getImage(getImageForKey( keys.BACK ))
		menuUserlevelsDelete[2].offset = (menuUserlevelsDelete[2].img:getWidth() - fontSmall:getWidth(menuUserlevelsDelete[2].txt))/2/Camera.scale
		menuUserlevelsDelete[2].x = 6
		menuUserlevelsDelete[2].labelX = menuUserlevelsDelete[2].x
		menuUserlevelsDelete[2].y = (love.graphics.getHeight())/Camera.scale - 20

		menuUserlevelsDelete[3] = {}
		menuUserlevelsDelete[3].label = "Filters and Sorting"
		menuUserlevelsDelete[3].txt = nameForKey( keys.FILTERS )
		menuUserlevelsDelete[3].img = menu:getImage(getImageForKey( keys.FILTERS ))
		menuUserlevelsDelete[3].offset = (menuUserlevelsDelete[3].img:getWidth() - fontSmall:getWidth(menuUserlevelsDelete[3].txt))/2/Camera.scale
		menuUserlevelsDelete[3].x = 0.75*(love.graphics.getWidth()-menuUserlevelsDelete[3].img:getWidth())/Camera.scale
		menuUserlevelsDelete[3].labelX = menuUserlevelsDelete[3].x +menuUserlevelsDelete[3].offset- fontSmall:getWidth(menuUserlevelsDelete[3].label)/2/Camera.scale
		menuUserlevelsDelete[3].y = (love.graphics.getHeight())/Camera.scale - 20

		menuUserlevelsDelete[4] = {}
		menuUserlevelsDelete[4].label = "REFRESH"
		menuUserlevelsDelete[4].txt = nameForKey( keys.REFRESH )
		menuUserlevelsDelete[4].img = menu:getImage(getImageForKey( keys.REFRESH ))
		menuUserlevelsDelete[4].offset = (menuUserlevelsDelete[4].img:getWidth() - fontSmall:getWidth(menuUserlevelsDelete[4].txt))/2/Camera.scale
		menuUserlevelsDelete[4].x = 0.25*(love.graphics.getWidth()-menuUserlevelsDelete[4].img:getWidth())/Camera.scale
		menuUserlevelsDelete[4].labelX = menuUserlevelsDelete[4].x +menuUserlevelsDelete[4].offset- fontSmall:getWidth(menuUserlevelsDelete[4].label)/2/Camera.scale
		menuUserlevelsDelete[4].y = (love.graphics.getHeight())/Camera.scale - 20

		menuUserlevelsDelete[5] = {}
		menuUserlevelsDelete[5].label = "Delete locally"
		menuUserlevelsDelete[5].txt = nameForKey( keys.DELETE_LEVEL )
		menuUserlevelsDelete[5].img = menu:getImage(getImageForKey( keys.DELETE_LEVEL ))
		menuUserlevelsDelete[5].offset = (menuUserlevelsDelete[5].img:getWidth() - fontSmall:getWidth(menuUserlevelsDelete[5].txt))/2/Camera.scale
		menuUserlevelsDelete[5].x = 0.5*(love.graphics.getWidth()-menuUserlevelsDelete[5].img:getWidth())/Camera.scale
		menuUserlevelsDelete[5].labelX = menuUserlevelsDelete[5].x +menuUserlevelsDelete[5].offset- fontSmall:getWidth(menuUserlevelsDelete[5].label)/2/Camera.scale
		menuUserlevelsDelete[5].y = (love.graphics.getHeight())/Camera.scale - 20

		menuFilters = {}
		--[[menuFilters[1] = {}
		menuFilters[1].label = "Apply"
		menuFilters[1].txt = nameForKey( keys.CHOOSE )
		menuFilters[1].img = menu:getImage(getImageForKey( keys.CHOOSE ))
		menuFilters[1].offset = (menuFilters[1].img:getWidth() - fontSmall:getWidth(menuFilters[1].txt))/2/Camera.scale
		menuFilters[1].x = (love.graphics.getWidth()-menuFilters[1].img:getWidth())/Camera.scale - 24
		menuFilters[1].labelX = (menuFilters[1].x*Camera.scale + menuFilters[1].img:getWidth() -
						fontSmall:getWidth(menuFilters[1].label))/Camera.scale
		menuFilters[1].y = (love.graphics.getHeight())/Camera.scale - 32
		
		menuFilters[2] = {}
		menuFilters[2].label = "Cancel"
		menuFilters[2].txt = nameForKey( keys.BACK )
		menuFilters[2].img = menu:getImage(getImageForKey( keys.BACK ))
		menuFilters[2].offset = (menuFilters[2].img:getWidth() - fontSmall:getWidth(menuFilters[2].txt))/2/Camera.scale
		menuFilters[2].x = 24
		menuFilters[2].labelX = menuFilters[2].x
		menuFilters[2].y = (love.graphics.getHeight())/Camera.scale - 32]]

		rating = {}
		rating[1] = {}
		rating[1].label = "Send Rating"
		rating[1].txt = nameForKey( keys.CHOOSE )
		rating[1].img = menu:getImage(getImageForKey( keys.CHOOSE ))
		rating[1].offset = (rating[1].img:getWidth() - fontSmall:getWidth(rating[1].txt))/2/Camera.scale
		rating[1].x = (love.graphics.getWidth()-rating[1].img:getWidth())/Camera.scale - 6
		rating[1].labelX = (rating[1].x*Camera.scale + rating[1].img:getWidth() -
						fontSmall:getWidth(rating[1].label))/Camera.scale
		rating[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		rating[2] = {}
		rating[2].label = "Skip"
		rating[2].txt = nameForKey( keys.BACK )
		rating[2].img = menu:getImage(getImageForKey( keys.BACK ))
		rating[2].offset = (rating[2].img:getWidth() - fontSmall:getWidth(rating[2].txt))/2/Camera.scale
		rating[2].x = 6
		rating[2].labelX = rating[2].x
		rating[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
	else
		death[1] = {}
		death[1].label = "Retry"
		--death[1].txt = nameForKey( keys.JUMP )
		death[1].img = menu:getImage(getImageForPad( keys.PAD.CHOOSE ))
		death[1].x = (love.graphics.getWidth()-death[1].img:getWidth())/Camera.scale - 6
		death[1].labelX = (death[1].x*Camera.scale + death[1].img:getWidth() -
						fontSmall:getWidth(death[1].label))/Camera.scale
		death[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		death[2] = {}
		death[2].label = "Leave"
		--death[2].txt = "esc"
		death[2].img = menu:getImage(getImageForPad( keys.PAD.BACK ))
		death[2].x = 6
		death[2].labelX = death[2].x
		death[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win = {}
		win[1] = {}
		win[1].label = "Continue"
		win[1].img = menu:getImage(getImageForPad( keys.PAD.CHOOSE ))
		win[1].x = (love.graphics.getWidth()-win[1].img:getWidth())/Camera.scale - 6
		win[1].labelX = (win[1].x*Camera.scale + win[1].img:getWidth() -
						fontSmall:getWidth(win[1].label))/Camera.scale
		win[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win[2] = {}
		win[2].label = "Leave"
		win[2].img = menu:getImage(getImageForPad( keys.PAD.BACK ))
		win[2].x = 6
		win[2].labelX = win[2].x
		win[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl = {}
		menuControl[1] = {}
		menuControl[1].label = "Choose"
		menuControl[1].img = menu:getImage(getImageForPad( keys.PAD.CHOOSE ))
		menuControl[1].x = (love.graphics.getWidth()-menuControl[1].img:getWidth())/Camera.scale - 6
		menuControl[1].labelX = (menuControl[1].x*Camera.scale + menuControl[1].img:getWidth() -
						fontSmall:getWidth(menuControl[1].label))/Camera.scale
		menuControl[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl[2] = {}
		menuControl[2].label = "Back"
		menuControl[2].img = menu:getImage(getImageForPad( keys.PAD.BACK ))
		menuControl[2].x = 6
		menuControl[2].labelX = menuControl[2].x
		menuControl[2].y = (love.graphics.getHeight())/Camera.scale - 20

		rating = {}
		rating[1] = {}
		rating[1].label = "Send Rating"
		rating[1].img = menu:getImage(getImageForPad( keys.PAD.CHOOSE ))
		rating[1].x = (love.graphics.getWidth()-rating[1].img:getWidth())/Camera.scale - 6
		rating[1].labelX = (rating[1].x*Camera.scale + rating[1].img:getWidth() -
						fontSmall:getWidth(rating[1].label))/Camera.scale
		rating[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		rating[2] = {}
		rating[2].label = "Skip"
		rating[2].img = menu:getImage(getImageForPad( keys.PAD.BACK ))
		rating[2].x = 6
		rating[2].labelX = rating[2].x
		rating[2].y = (love.graphics.getHeight())/Camera.scale - 20
	end
end

return controlKeys
