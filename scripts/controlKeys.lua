-- Used to show the player which keys to hit in order to get to other menus,
-- continue after death and after winning a level etc:

local controlKeys = {}
local death = {}
local win = {}
local menuControl = {}
local toDraw

function controlKeys:draw( drawMode )

	local x, y

	if drawMode == "death" then
		toDraw = death
	elseif drawMode == "win" then
		toDraw = win
	elseif drawMode == "menu" then
		toDraw = menuControl
	end
	
	
	if mode == "menu" and menu.state == "pause" and toDraw ~= menuControl then return end
	love.graphics.setFont( fontSmall )
	
	y = love.graphics.getHeight() - 60
	
	if love.joystick.getJoystickCount() == 0 then
		for k = 1, #toDraw do
			x, y = toDraw[k].x, toDraw[k].y
			love.graphics.draw( toDraw[k].img, x*Camera.scale, y*Camera.scale)
			love.graphics.print( toDraw[k].txt,
							(x+toDraw[k].offset)*Camera.scale,
							(y+3)*Camera.scale )
			love.graphics.print( toDraw[k].label,
							(toDraw[k].labelX)*Camera.scale,
							(y-3)*Camera.scale )
		end
	else
		for k = 1, #toDraw do
			x, y = toDraw[k].x, toDraw[k].y
			love.graphics.draw( toDraw[k].img, x*Camera.scale, y*Camera.scale)
			
			love.graphics.print( toDraw[k].label,
							(toDraw[k].labelX)*Camera.scale,
							(y-3)*Camera.scale )
		end
	end
		
end

function controlKeys:setup()
	if love.joystick.getJoystickCount() == 0 then
		death = {}
		death[1] = {}
		death[1].label = "retry"
		death[1].txt = nameForKey( keys.CHOOSE )
		death[1].img = menu:getImage(getImageForKey( keys.CHOOSE ))
		death[1].offset = (death[1].img:getWidth() - fontSmall:getWidth(death[1].txt))/2/Camera.scale
		death[1].x = (love.graphics.getWidth()-death[1].img:getWidth())/Camera.scale - 6
		death[1].labelX = (death[1].x*Camera.scale + death[1].img:getWidth() -
						fontSmall:getWidth(death[1].label))/Camera.scale
		death[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		death[2] = {}
		death[2].label = "leave"
		death[2].txt = nameForKey( keys.BACK )
		death[2].img = menu:getImage(getImageForKey( keys.BACK ))
		death[2].offset = (death[2].img:getWidth() - fontSmall:getWidth(death[2].txt))/2/Camera.scale
		death[2].x = 6
		death[2].labelX = death[2].x
		death[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win = {}
		win[1] = {}
		win[1].label = "continue"
		win[1].txt = nameForKey( keys.CHOOSE )
		win[1].img = menu:getImage(getImageForKey( keys.CHOOSE ))
		win[1].offset = (win[1].img:getWidth() - fontSmall:getWidth(win[1].txt))/2/Camera.scale
		win[1].x = (love.graphics.getWidth()-win[1].img:getWidth())/Camera.scale - 6
		win[1].labelX = (win[1].x*Camera.scale + win[1].img:getWidth() -
						fontSmall:getWidth(win[1].label))/Camera.scale
		win[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win[2] = {}
		win[2].label = "leave"
		win[2].txt = keys.BACK
		win[2].img = menu:getImage(getImageForKey( keys.BACK ))
		win[2].offset = (win[2].img:getWidth() - fontSmall:getWidth(win[2].txt))/2/Camera.scale
		win[2].x = 6
		win[2].labelX = win[2].x
		win[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl = {}
		menuControl[1] = {}
		menuControl[1].label = "choose"
		menuControl[1].txt = keys.CHOOSE
		menuControl[1].img = menu:getImage(getImageForKey( keys.CHOOSE ))
		menuControl[1].offset = (menuControl[1].img:getWidth() - fontSmall:getWidth(menuControl[1].txt))/2/Camera.scale
		menuControl[1].x = (love.graphics.getWidth()-menuControl[1].img:getWidth())/Camera.scale - 6
		menuControl[1].labelX = (menuControl[1].x*Camera.scale + menuControl[1].img:getWidth() -
						fontSmall:getWidth(menuControl[1].label))/Camera.scale
		menuControl[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl[2] = {}
		menuControl[2].label = "back"
		menuControl[2].txt = keys.BACK
		menuControl[2].img = menu:getImage(getImageForKey( keys.BACK ))
		menuControl[2].offset = (menuControl[2].img:getWidth() - fontSmall:getWidth(menuControl[2].txt))/2/Camera.scale
		menuControl[2].x = 6
		menuControl[2].labelX = menuControl[2].x
		menuControl[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
	else
		death[1] = {}
		death[1].label = "retry"
		--death[1].txt = nameForKey( keys.JUMP )
		death[1].img = menu:getImage(getImageForPad( keys.PAD.CHOOSE ))
		death[1].x = (love.graphics.getWidth()-death[1].img:getWidth())/Camera.scale - 6
		death[1].labelX = (death[1].x*Camera.scale + death[1].img:getWidth() -
						fontSmall:getWidth(death[1].label))/Camera.scale
		death[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		death[2] = {}
		death[2].label = "leave"
		--death[2].txt = "esc"
		death[2].img = menu:getImage(getImageForPad( keys.PAD.BACK ))
		death[2].x = 6
		death[2].labelX = death[2].x
		death[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win = {}
		win[1] = {}
		win[1].label = "continue"
		win[1].img = menu:getImage(getImageForPad( keys.PAD.CHOOSE ))
		win[1].x = (love.graphics.getWidth()-win[1].img:getWidth())/Camera.scale - 6
		win[1].labelX = (win[1].x*Camera.scale + win[1].img:getWidth() -
						fontSmall:getWidth(win[1].label))/Camera.scale
		win[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win[2] = {}
		win[2].label = "leave"
		win[2].img = menu:getImage(getImageForPad( keys.PAD.BACK ))
		win[2].x = 6
		win[2].labelX = win[2].x
		win[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl = {}
		menuControl[1] = {}
		menuControl[1].label = "choose"
		menuControl[1].img = menu:getImage(getImageForPad( keys.PAD.CHOOSE ))
		menuControl[1].x = (love.graphics.getWidth()-menuControl[1].img:getWidth())/Camera.scale - 6
		menuControl[1].labelX = (menuControl[1].x*Camera.scale + menuControl[1].img:getWidth() -
						fontSmall:getWidth(menuControl[1].label))/Camera.scale
		menuControl[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl[2] = {}
		menuControl[2].label = "back"
		menuControl[2].img = menu:getImage(getImageForPad( keys.PAD.BACK ))
		menuControl[2].x = 6
		menuControl[2].labelX = menuControl[2].x
		menuControl[2].y = (love.graphics.getHeight())/Camera.scale - 20
	end
end

return controlKeys
