-- Used to show the player which keys to hit in order to get to other menus,
-- continue after death and after winning a level etc:

local controlKeys = {}
local death = {}
local win = {}
local menuControl = {}
local toDraw

function controlKeys:draw( mode )
	local x, y

	if mode == "death" then
		toDraw = death
	elseif mode == "win" then
		toDraw = win
	elseif mode == "menu" then
		toDraw = menuControl
	end
	love.graphics.setFont( fontSmall )
	
	y = love.graphics.getHeight() - 60
	
	if love.joystick.getNumJoysticks() == 0 then
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
	if love.joystick.getNumJoysticks() == 0 then
		death = {}
		death[1] = {}
		death[1].label = "retry"
		death[1].txt = nameForKey( keys.JUMP )
		death[1].img = menu:getImage(getImageForKey( keys.JUMP ))
		death[1].offset = (death[1].img:getWidth() - fontSmall:getWidth(death[1].txt))/2/Camera.scale
		death[1].x = (love.graphics.getWidth()-death[1].img:getWidth())/Camera.scale - 6
		death[1].labelX = (death[1].x*Camera.scale + death[1].img:getWidth() -
						fontSmall:getWidth(death[1].label))/Camera.scale
		death[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		death[2] = {}
		death[2].label = "leave"
		death[2].txt = "esc"
		death[2].img = menu:getImage(getImageForKey( "esc" ))
		death[2].offset = (death[2].img:getWidth() - fontSmall:getWidth(death[2].txt))/2/Camera.scale
		death[2].x = 6
		death[2].labelX = death[2].x
		death[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win = {}
		win[1] = {}
		win[1].label = "continue"
		win[1].txt = nameForKey( keys.RIGHT )
		win[1].img = menu:getImage(getImageForKey( keys.RIGHT ))
		win[1].offset = (win[1].img:getWidth() - fontSmall:getWidth(win[1].txt))/2/Camera.scale
		win[1].x = (love.graphics.getWidth()-win[1].img:getWidth())/Camera.scale - 6
		win[1].labelX = (win[1].x*Camera.scale + win[1].img:getWidth() -
						fontSmall:getWidth(win[1].label))/Camera.scale
		win[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win[2] = {}
		win[2].label = "leave"
		win[2].txt = "esc"
		win[2].img = menu:getImage(getImageForKey( "esc" ))
		win[2].offset = (win[2].img:getWidth() - fontSmall:getWidth(win[2].txt))/2/Camera.scale
		win[2].x = 6
		win[2].labelX = win[2].x
		win[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl = {}
		menuControl[1] = {}
		menuControl[1].label = "choose"
		menuControl[1].txt = "enter"
		menuControl[1].img = menu:getImage(getImageForKey( "enter" ))
		menuControl[1].offset = (menuControl[1].img:getWidth() - fontSmall:getWidth(menuControl[1].txt))/2/Camera.scale
		menuControl[1].x = (love.graphics.getWidth()-menuControl[1].img:getWidth())/Camera.scale - 6
		menuControl[1].labelX = (menuControl[1].x*Camera.scale + menuControl[1].img:getWidth() -
						fontSmall:getWidth(menuControl[1].label))/Camera.scale
		menuControl[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl[2] = {}
		menuControl[2].label = "back"
		menuControl[2].txt = "esc"
		menuControl[2].img = menu:getImage(getImageForKey( "esc" ))
		menuControl[2].offset = (menuControl[2].img:getWidth() - fontSmall:getWidth(menuControl[2].txt))/2/Camera.scale
		menuControl[2].x = 6
		menuControl[2].labelX = menuControl[2].x
		menuControl[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
	else
		death[1] = {}
		death[1].label = "retry"
		--death[1].txt = nameForKey( keys.JUMP )
		death[1].img = menu:getImage(getImageForPad( keys.PAD.JUMP ))
		death[1].x = (love.graphics.getWidth()-death[1].img:getWidth())/Camera.scale - 6
		death[1].labelX = (death[1].x*Camera.scale + death[1].img:getWidth() -
						fontSmall:getWidth(death[1].label))/Camera.scale
		death[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		death[2] = {}
		death[2].label = "leave"
		--death[2].txt = "esc"
		death[2].img = menu:getImage(getImageForPad( "7" ))
		death[2].x = 6
		death[2].labelX = death[2].x
		death[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win = {}
		win[1] = {}
		win[1].label = "continue"
		win[1].img = menu:getImage(getImageForPad( keys.PAD.RIGHT ))
		win[1].x = (love.graphics.getWidth()-win[1].img:getWidth())/Camera.scale - 6
		win[1].labelX = (win[1].x*Camera.scale + win[1].img:getWidth() -
						fontSmall:getWidth(win[1].label))/Camera.scale
		win[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		win[2] = {}
		win[2].label = "leave"
		win[2].img = menu:getImage(getImageForPad( "7" ))
		win[2].x = 6
		win[2].labelX = win[2].x
		win[2].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl = {}
		menuControl[1] = {}
		menuControl[1].label = "choose"
		menuControl[1].img = menu:getImage(getImageForPad( "1" ))
		menuControl[1].x = (love.graphics.getWidth()-menuControl[1].img:getWidth())/Camera.scale - 6
		menuControl[1].labelX = (menuControl[1].x*Camera.scale + menuControl[1].img:getWidth() -
						fontSmall:getWidth(menuControl[1].label))/Camera.scale
		menuControl[1].y = (love.graphics.getHeight())/Camera.scale - 20
		
		menuControl[2] = {}
		menuControl[2].label = "back"
		menuControl[2].img = menu:getImage(getImageForPad( "2" ))
		menuControl[2].x = 6
		menuControl[2].labelX = menuControl[2].x
		menuControl[2].y = (love.graphics.getHeight())/Camera.scale - 20
	end
end

return controlKeys
