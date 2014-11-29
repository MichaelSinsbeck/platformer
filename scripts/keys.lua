
controlKeys = require("scripts/controlKeys")

local keys = {}
keys.gamepadePressed = {}
keys.pressedLastFrame = {}
keys.currentlyAssigning = false		--holds the string of the key which is currently being changed.

keyTypes = {
	"SCREENSHOT",
	"FULLSCREEN",
	"RESTARTMAP",
	"RESTARTGAME",
	"NEXTMAP",
	"LEFT",
	"RIGHT",
	"UP",
	"DOWN",
	"JUMP",
	"ACTION",
	"DASH",
	"CHOOSE",
	"BACK",
	"PAUSE",
	"FILTERS",
	"REFRESH",
	"DELETE_LEVEL",
	"RESET",
}

-- For each key, list the keys which it may NOT be the same as.
keys.conflictList = {
	-- In game:
	{"SCEENSHOT", "FULLSCREEN", "RESTARTMAP", "RESTARTGAME", "NEXTMAP", "LEFT", "RIGHT", "UP", "DOWN", "JUMP", "ACTION", "DASH", "PAUSE"},
	-- menu:
	{"SCEENSHOT", "FULLSCREEN", "LEFT", "RIGHT", "UP", "DOWN", "CHOOSE", "BACK",},
	-- userlevel menu:
	{"SCREENSHOT", "FULLSCREEN", "CHOOSE", "BACK", "FILTERS", "REFRESH", "DELETE_LEVEL", },
	-- key assignment menu:
	{"SCREENSHOT", "FULLSCREEN", "LEFT", "RIGHT", "UP", "DOWN", "RESET", "CHOOSE", "BACK"}
	
	--{"SCREENSHOT", "FULLSCREEN", "RESTARTMAP", "RESTARTGAME", "NEXTMAP", "LEFT", "RIGHT", "UP", "DOWN", "JUMP", "ACTION", "DASH", "CHOOSE", "BACK", "PAUSE", "FILTERS", "REFRESH", "DELETE_LEVEL", "RESET" }
}
---------------------------------------------------------
-- Defaults
---------------------------------------------------------
function keys.setDefaults()
	-- keyboard defaults:
	keys.SCREENSHOT = 'f2'
	keys.FULLSCREEN = 'f9'
	keys.RESTARTMAP = 'p'
	keys.RESTARTGAME = 'o'
	keys.NEXTMAP = 'q'

	keys.LEFT = 'left'
	keys.RIGHT = 'right'
	keys.UP = 'up'
	keys.DOWN = 'down'

	keys.JUMP = 'a'
	keys.ACTION = 's'
	keys.DASH = 'd'

	keys.CHOOSE = 'return'
	keys.BACK = 'escape'

	keys.PAUSE = 'escape'

	keys.FILTERS = 'f'
	keys.REFRESH = "f5"
	keys.DELETE_LEVEL = 'x'
	keys.RESET = "r"
	
	-- gamepad defaults:
	keys.PAD = {}
	keys.PAD.SCREENSHOT = '6'
	keys.PAD.FULLSCREEN = 'none'
	keys.PAD.RESTARTMAP = 'none'
	keys.PAD.RESTARTGAME = 'none'
	keys.PAD.NEXTMAP = 'none'

	keys.PAD.LEFT = 'l'
	keys.PAD.RIGHT = 'r'
	keys.PAD.UP = 'u'
	keys.PAD.DOWN = 'd'

	keys.PAD.JUMP = '1'
	keys.PAD.ACTION = '2'
	keys.PAD.DASH = '4'

	keys.PAD.CHOOSE = '1'
	keys.PAD.BACK = '2'

	keys.PAD.PAUSE = '7'

	keys.PAD.FILTERS = '7'
	keys.PAD.REFRESH = 'none'

	keys.PAD.RESET = 'none'
	
	keys.gamepadPressed = {}

end

keys.setDefaults()


---------------------------------------------------------
-- Load settings:
---------------------------------------------------------

function keys.load()
	local key
	
	-- Load keyboard setup:
	key = config.getValue( "SCREENSHOT", "keyboard.txt")
	if key then keys.SCREENSHOT = key end
	key = config.getValue( "FULLSCREEN", "keyboard.txt")
	if key then keys.FULLSCREEN = key end
	key = config.getValue( "RESTARTMAP", "keyboard.txt")
	if key then keys.RESTARTMAP = key end
	key = config.getValue( "RESTARTGAME", "keyboard.txt")
	if key then keys.RESTARTGAME = key end
	key = config.getValue( "NEXTMAP", "keyboard.txt")
	if key then keys.NEXTMAP = key end
	
	key = config.getValue( "LEFT", "keyboard.txt")
	if key then keys.LEFT = key end
	key = config.getValue( "RIGHT", "keyboard.txt")
	if key then keys.RIGHT = key end
	key = config.getValue( "UP", "keyboard.txt")
	if key then keys.UP = key end
	key = config.getValue( "DOWN", "keyboard.txt")
	if key then keys.DOWN = key end
	
	key = config.getValue( "JUMP", "keyboard.txt")
	if key then keys.JUMP = key end
	key = config.getValue( "ACTION", "keyboard.txt")
	if key then keys.ACTION = key end

	key = config.getValue( "BACK", "keyboard.txt")
	if key then keys.BACK = key end
	key = config.getValue( "CHOOSE", "keyboard.txt")
	if key then keys.CHOOSE = key end
	key = config.getValue( "PAUSE", "keyboard.txt")
	if key then keys.PAUSE = key end
	
	-- Load gamepad setup:
	key = config.getValue( "SCREENSHOT", "gamepad.txt")
	if key then keys.PAD.SCREENSHOT = key end
	key = config.getValue( "FULLSCREEN", "gamepad.txt")
	if key then keys.PAD.FULLSCREEN = key end
	key = config.getValue( "RESTARTMAP", "gamepad.txt")
	if key then keys.PAD.RESTARTMAP = key end
	key = config.getValue( "RESTARTGAME", "gamepad.txt")
	if key then keys.PAD.RESTARTGAME = key end
	key = config.getValue( "NEXTMAP", "gamepad.txt")
	if key then keys.PAD.NEXTMAP = key end
	
	key = config.getValue( "LEFT", "gamepad.txt")
	if key then keys.PAD.LEFT = key end
	key = config.getValue( "RIGHT", "gamepad.txt")
	if key then keys.PAD.RIGHT = key end
	key = config.getValue( "UP", "gamepad.txt")
	if key then keys.PAD.UP = key end
	key = config.getValue( "DOWN", "gamepad.txt")
	if key then keys.PAD.DOWN = key end
	
	key = config.getValue( "JUMP", "gamepad.txt")
	if key then keys.PAD.JUMP = key end
	key = config.getValue( "ACTION", "gamepad.txt")
	if key then keys.PAD.ACTION = key end

	key = config.getValue( "BACK", "gamepad.txt")
	if key then keys.PAD.BACK = key end
	key = config.getValue( "CHOOSE", "gamepad.txt")
	if key then keys.PAD.CHOOSE = key end
	key = config.getValue( "PAUSE", "gamepad.txt")
	if key then keys.PAD.PAUSE = key end

end

function keys.loadGamepad()
	print("Gamepads:")
	if love.joystick.getJoystickCount() == 0 then
		print("\tNone found.")
	else
		for k, pad in ipairs( love.joystick.getJoysticks() ) do
			print("\t",pad:getID(), pad:getName() )

			-- Important! initialize these tables, since they're
			-- usually initialized when joysticks are connected,
			-- but the first joystick is recognized only AFTER
			-- these are first neede!
			keys.gamepadPressed[pad:getID()] = {}
			keys.pressedLastFrame[pad:getID()] = {}
		end
	end
end

function nameForKey( key )
	if key == " " then
		return "space"
	elseif key == "up" then
		return "["
	elseif key == "down" then
		return "]"
	elseif key == "left" then
		return "<"
	elseif key == "right" then
		return ">"
	elseif key == "backspace" then
		return "bspace"
	elseif key == "return" then
		return "@"
	elseif key == "escape" then
		return "^"		
	else
		return key
	end
end

function getImageForKey( str, font )
	if str == "" then
		return "keyNone", "keyNone"
	end

	if str == " " then str = "space" end
	if str == "up" then str = "A" end
	if str == "down" then str = "B" end
	if str == "left" then str = "C" end
	if str == "right" then str = "D" end
	if str == "escape" then str = "^" end
	if str == "return" then str = "@" end
	if #str > 1 then --font:getWidth(str) > menu.images.keyOn:getWidth()/2 then
		return "keyLargeOff", "keyLargeOn"
	end
	return "keyOff", "keyOn"
end

function getAnimationForKey( str )
	str = nameForKey( str )
	if #str > 1 then --font:getWidth(str) > menu.images.keyOn:getWidth()/2 then
		return "keyboardLarge"
	end
	return "keyboardSmall"
end

function getImageForPad( str )
	if str == "1" then
		return "gamepadA","gamepadA"
	elseif str == "2" then
		return "gamepadB","gamepadB"
	elseif str == "3" then
		return "gamepadX","gamepadX"
	elseif str == "4" then
		return "gamepadY","gamepadY"
	elseif str == "5" then
		return "gamepadLB","gamepadLB"
	elseif str == "6" then
		return "gamepadRB","gamepadRB"
	elseif str == "u" then
		return "gamepadUp","gamepadUp"
	elseif str == "d" then
		return "gamepadDown","gamepadDown"
	elseif str == "l" then
		return "gamepadLeft","gamepadLeft"
	elseif str == "r" then
		return "gamepadRight","gamepadRight"
	elseif str == "8" then
		return "gamepadStart","gamepadStart"
	elseif str == "7" then
		return "gamepadBack","gamepadBack"
	else
		return "keyNone","keyNone"
	end
end

function getAnimationForPad( str )
	if str == "1" then
		return "gamepadA"
	elseif str == "2" then
		return "gamepadB"
	elseif str == "3" then
		return "gamepadX"
	elseif str == "4" then
		return "gamepadY"
	elseif str == "5" then
		return "gamepadLB"
	elseif str == "6" then
		return "gamepadRB"
	elseif str == "u" then
		return "gamepadUp"
	elseif str == "d" then
		return "gamepadDown"
	elseif str == "l" then
		return "gamepadLeft"
	elseif str == "r" then
		return "gamepadRight"
	elseif str == "8" then
		return "gamepadStart"
	elseif str == "9" then
		return "gamepadBack"
	else
		return "keyNone"
	end
end

---------------------------------------------------------
-- Handle the joysticks in-game:
---------------------------------------------------------

--[[
keys.lastFrameJoyHat = nil
keys.lastFrameKey1 = nil
keys.lastFrameKey2 = nil

function keys.catchGamepadEvents()
	for k, v in pairs( keys.PAD ) do
		keys.gamepadPressed[k] = nil	-- reset all
	end
	
	local joyHat = love.joystick.getHat( 1,1 )
	
	if joyHat == "lu" or joyHat == "ld" then
		joyHat = "l"
	elseif joyHat == "ru" or joyHat == "rd" then
		joyHat = "r"
	end

	if mode == "menu" or mode == "levelEnd" then
		if not keys.currentlyAssigning then
			if love.joystick.isDown( 1, 1 ) then
				if not keys.lastFrameKey1 then
					if mode == "menu" then
						menu:keypressed( "return" )
					else
						levelEnd:keypressed( "return" )
					end
					keys.lastFrameKey1 = true
				end
			else
				keys.lastFrameKey1 = false
			end
			if love.joystick.isDown( 1, 2 ) then
				if not keys.lastFrameKey2 then
					if mode == "menu" then
						menu:keypressed( "escape" )
					else
						levelEnd:keypressed( "escape" )
					end
					keys.lastFrameKey2 = true
				end
			else
				keys.lastFrameKey2 = false
			end
		else
			keys.lastFrameKey1 = true
			keys.lastFrameKey2 = true
		end
	
		if joyHat ~= 'c' then
			if keys.currentlyAssigning and menu.state == 'gamepad' then
				keys.assign( joyHat )
			else
				if mode == "menu" and keys.lastFrameJoyHat ~= joyHat then
					menu:keypressed( joyHat )
				end
			end
		end
		
	end
	
	if mode == 'game' then
		for k, v in pairs( keys.PAD ) do
			if v == joyHat then
				if not keys.gamepadPressed[k] then
					keys.gamepadPressed[k] = true
					game.joystickpressed(1, v)
				end
			end
			if tonumber(v) then	-- if the button is a number button, check if that one's pressed
				if love.joystick.isDown( 1, tonumber(v) ) then
					keys.gamepadPressed[k] = true
				end
			end
		end
	end
	
	keys.lastFrameJoyHat = joyHat
end]]--

-- calls events in case a gamepad button has been pressed this frame:
-- Must be called every frame!
function keys.handleGamepad( ID )
	ID = ID or 1 -- default to joystick 1
	if not keys.gamepadPressed[ID] then return end
	-- check for released events:
	for k, v in pairs( keys.pressedLastFrame[ID] ) do
		if not keys.gamepadPressed[ID][k] then
			keys.pressedLastFrame[ID][k] = nil
			if mode == "game" then
				game.joystickreleased( ID, k )
			elseif mode == "menu" then
			end
		end
	end

	-- check for newly pressed buttons:
	for k, v in pairs( keys.gamepadPressed[ ID ]) do
		if not keys.pressedLastFrame[ID][k] then
			if keys.currentlyAssigning then
				if menu.state == 'gamepad' then
					keys.assign( k )
				else
					keys.abortAssigning()
				end
			else

				if mode == "game" then
					game.joystickpressed( ID, k )
				elseif mode == "menu" then
					--menu:keypressed( k )
				elseif mode == "levelEnd" then
					levelEnd:keypressed( k )
				end
			end
		end
		keys.pressedLastFrame[ID][k] = true
	end
end

function keys.pressGamepadKey( joystick, button )
	button = tostring(button)
	keys.gamepadPressed[joystick:getID()][button] = true
end

function keys.releaseGamepadKey( joystick, button )
	button = tostring(button)
	keys.gamepadPressed[joystick:getID()][button] = nil
end

function keys.getGamepadIsDown( ID, str )
	ID = ID or 1
	return keys.gamepadPressed[ID] and keys.gamepadPressed[ID][str] or false
end

-- called when new joystick has been connected:
function keys.joystickadded( j )
	-- if this is the first joystick, switch menu keys to
	-- be displayed in joystick-mode
	keys.gamepadPressed[j:getID()] = {}
	keys.pressedLastFrame[j:getID()] = {}
	if love.joystick.getJoystickCount() == 1 then
		--controlKeys:setup()
	end
end

-- called when new joystick has been disconnected:
function keys.joystickremoved( j )
	-- if, with the removal of this joystick, the last one
	-- has been removed, switch to keyboard:
	if love.joystick.getJoystickCount() == 0 then
		--controlKeys:setup()
	end

	keys.gamepadPressed[j:getID()] = nil
	keys.pressedLastFrame[j:getID()] = nil
end

---------------------------------------------------------
-- Display key setting menus:
---------------------------------------------------------

function keys.moveMenuPlayer( x, y, newAnimation )
	return function()
		menuPlayer.x = x
		menuPlayer.y = y
		menuPlayer.vis:setAni( newAnimation )
		local sel = menu:getSelected()
		if sel and (sel.name == "key_LEFT" or sel.name == "key_PAD_LEFT") then
			menuPlayer.vis.sx = -1
		else
			menuPlayer.vis.sx = 1
		end
	end
end


function keys.initKeyboard()
	menu.state = "keyboard"
	menu:clear()
	
	keys.changed = false -- don't save configuration unless new key has been assigned
	
	local x,y = -26, -55
	local imgOff, imgOn
	local hoverEvent
	local ninjaDistX = 3
	local ninjaDistY = -4
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteWalk" )
	imgOff, imgOn = getImageForKey( keys.LEFT, 'fontSmall' )
	local startButton = menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_LEFT",
					keys.startAssign( "LEFT" ), hoverEvent,
					nameForKey(keys.LEFT), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("left")/Camera.scale, y+3, "LEFT", "left")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteWalk" )
	imgOff, imgOn = getImageForKey( keys.RIGHT, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_RIGHT",
					keys.startAssign( "RIGHT" ), hoverEvent,
					nameForKey(keys.RIGHT), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("right")/Camera.scale, y+3, "RIGHT", "right")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "moveUpWhite" )
	imgOff, imgOn = getImageForKey( keys.UP, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_UP", 
					keys.startAssign( "UP" ), hoverEvent,
					nameForKey(keys.UP), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("up")/Camera.scale, y+3, "UP", "up")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "moveDownWhite" )
	imgOff, imgOn = getImageForKey( keys.DOWN, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_DOWN", 
					keys.startAssign( "DOWN" ), hoverEvent,
					nameForKey(keys.DOWN), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("down")/Camera.scale, y+3, "DOWN", "down")
	
	x = 34
	y = -55
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "jumpFallWhite" )
	imgOff, imgOn = getImageForKey( keys.JUMP, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_JUMP",
					keys.startAssign( "JUMP" ), hoverEvent,
					nameForKey(keys.JUMP), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("jump")/Camera.scale, y+3, "JUMP", "jump")
	y = y + 10
		
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "blueGliding" )
	imgOff, imgOn = getImageForKey( keys.ACTION, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_ACTION",
					keys.startAssign( "ACTION" ), hoverEvent,
					nameForKey(keys.ACTION), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("use bandana")/Camera.scale, y+3,	"ACTION", "use bandana")
	y = y + 10

	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForKey( keys.PAUSE, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_PAUSE",
					keys.startAssign( "PAUSE" ), hoverEvent,
					nameForKey(keys.PAUSE), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("pause")/Camera.scale, y+3, "PAUSE", "pause")

	local x,y = 3, 10

	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "playerScreenshot" )
	imgOff, imgOn = getImageForKey( keys.SCREENSHOT, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_SCREENSHOT",
					keys.startAssign( "SCREENSHOT" ), hoverEvent,
					nameForKey(keys.SCREENSHOT), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("screenshot")/Camera.scale, y+3,
					"SCREENSHOT", "screenshot")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "playerFullscreen" )
	imgOff, imgOn = getImageForKey( keys.FULLSCREEN, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_FULLSCREEN",
					keys.startAssign( "FULLSCREEN" ), hoverEvent,
					nameForKey(keys.FULLSCREEN), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("fullscreen")/Camera.scale, y+3,
					"FULLSCREEN", "fullscreen")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForKey( keys.RESTARTMAP, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_RESTARTMAP",
					keys.startAssign( "RESTARTMAP" ), hoverEvent,
					nameForKey(keys.RESTARTMAP), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("restart map")/Camera.scale, y+3,
			"RESTARTMAP", "restart map")

	y = y + 10

	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForKey( keys.CHOOSE, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_CHOOSE",
					keys.startAssign( "CHOOSE" ), hoverEvent,
					nameForKey(keys.CHOOSE), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("choose")/Camera.scale, y+3,
					"CHOOSE", "choose")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForKey( keys.BACK, 'fontSmall' )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_BACK",
					keys.startAssign( "BACK" ), hoverEvent,
					nameForKey(keys.BACK), 'fontSmall' )
	menu:addText( x-8 - fontSmall:getWidth("back")/Camera.scale, y+3,
					"BACK", "back")
	y = y + 10
	
	menu:addBox(-63,-64,126,50)
	menu:addBox(-63, 2,126,60)
	-- start of with the first button selected:
	selectButton(startButton)
end


function keys.initGamepad()
	menu.state = "gamepad"
	menu:clear()
	
	keys.changed = false -- don't save configuration unless new key has been assigned
	
	local x,y = -26, -55
	local imgOff, imgOn
	local hoverEvent
	local ninjaDistX = 3
	local ninjaDistY = -4
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteWalk" )
	imgOff,imgOn = getImageForPad( keys.PAD.LEFT )
	local startButton = menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_LEFT",
					keys.startAssign( "LEFT" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("left")/Camera.scale, y+3, "LEFT", "left")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteWalk" )
	imgOff,imgOn = getImageForPad( keys.PAD.RIGHT )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_RIGHT",
					keys.startAssign( "RIGHT" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("right")/Camera.scale, y+3, "RIGHT", "right")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "moveUpWhite" )
	imgOff,imgOn = getImageForPad( keys.PAD.UP )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_UP", 
					keys.startAssign( "UP" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("up")/Camera.scale, y+3, "UP", "up")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "moveDownWhite" )
	imgOff,imgOn = getImageForPad( keys.PAD.DOWN )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_DOWN", 
					keys.startAssign( "DOWN" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("down")/Camera.scale, y+3, "DOWN", "down")
	
	y = -55
	x = 34
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "jumpFallWhite" )
	imgOff,imgOn = getImageForPad( keys.PAD.JUMP )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_JUMP",
					keys.startAssign( "JUMP" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("jump")/Camera.scale, y+3, "JUMP", "jump")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "blueGliding" )
	imgOff,imgOn = getImageForPad( keys.PAD.ACTION )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_ACTION",
					keys.startAssign( "ACTION" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("use bandana")/Camera.scale, y+3, "ACTION", "use bandana")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff,imgOn = getImageForPad( keys.PAD.PAUSE )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_PAUSE",
					keys.startAssign( "PAUSE" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("pause")/Camera.scale, y+3, "PAUSE", "pause")
	y = y + 14
	


	local x,y = 3, 10

	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForPad( keys.PAD.CHOOSE, 'fontSmall' )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_CHOOSE",
					keys.startAssign( "CHOOSE" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("choose")/Camera.scale, y+3,
					"CHOOSE", "choose")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForPad( keys.PAD.BACK, 'fontSmall' )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_BACK",
					keys.startAssign( "BACK" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("back")/Camera.scale, y+3,
					"BACK", "back")
	y = y + 10

	--[[
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff,imgOn = getImageForPad( keys.PAD.SCREENSHOT )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_SCREENSHOT",
					keys.startAssign( "SCREENSHOT" ), hoverEvent )
	menu:addText( x-20, y+3, "SCREENSHOT", "screenshot")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff,imgOn = getImageForPad( keys.PAD.FULLSCREEN )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_FULLSCREEN",
					keys.startAssign( "FULLSCREEN" ), hoverEvent )
	menu:addText( x-20, y+3, "FULLSCREEN", "fullscreen")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff,imgOn = getImageForPad( keys.PAD.RESTARTMAP, 'fontSmall' )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_RESTARTMAP",
					keys.startAssign( "RESTARTMAP" ), hoverEvent )
	menu:addText( x-20, y+3, "RESTARTMAP", "restart map")
	]]--
	
	-- start of with the first button selected:
	--menu:addBox(-55,-50,110,50)
	--menu:addBox(-55, 5,110,40)
	menu:addBox(-63,-64,126,50)
	menu:addBox(-63, 2,126,42)
	
	selectButton(startButton)
	
end

-- check for double assignments or empty keys.
function keys:checkInvalid()
	if menu.state == "keyboard" then
		for k = 1, #keyTypes-1 do
			for k2 = k+1, #keyTypes do
				if keyTypes[k] ~= "CHOOSE" and keyTypes[k2] ~= "CHOOSE" and keyTypes[k] ~= "BACK" and keyTypes[k2] ~= "BACK" then
				if keys[keyTypes[k]] == keys[keyTypes[k2]] then
					menu.text = string.lower("Keys for " .. keyTypes[k] .. " and " .. keyTypes[k2] .. " are the same. Please change one of them.")
					return true
				end
			end
			end
		end
	else
		for k = 1, #keyTypes-1 do
			for k2 = k+1, #keyTypes do
				-- handle "choose" and "back" seperately:
				if keyTypes[k] ~= "CHOOSE" and keyTypes[k2] ~= "CHOOSE" and keyTypes[k] ~= "BACK" and keyTypes[k2] ~= "BACK" then
					if keys.PAD[keyTypes[k]] == keys.PAD[keyTypes[k2]] then
						menu.text = string.lower("Keys for " .. keyTypes[k] .. " and " .. keyTypes[k2] .. " are the same. Please change one of them.")
						return true
					end
				end
			end
		end
		if keys.PAD.CHOOSE == keys.PAD.BACK then
			menu.text = string.lower("Keys for CHOOOSE and BACK are the same. Please change one of them.")
			return true
		end
	end
	return false
end

function keys:exitSubMenu()
	--if not keys.currentlyAssigning then
		if keys.changed then
			--if menu.state == "keyboard" then	-- save keyboard layout:
				config.setValue( "SCREENSHOT", keys.SCREENSHOT, "keyboard.txt")
				config.setValue( "FULLSCREEN", keys.FULLSCREEN, "keyboard.txt")
				config.setValue( "RESTARTMAP", keys.RESTARTMAP, "keyboard.txt")
				config.setValue( "RESTARTGAME", keys.RESTARTGAME, "keyboard.txt")
				config.setValue( "NEXTMAP", keys.NEXTMAP, "keyboard.txt")

				config.setValue( "LEFT", keys.LEFT, "keyboard.txt")
				config.setValue( "RIGHT", keys.RIGHT, "keyboard.txt")
				config.setValue( "UP", keys.UP, "keyboard.txt")
				config.setValue( "DOWN", keys.DOWN, "keyboard.txt")
			
				config.setValue( "JUMP", keys.JUMP, "keyboard.txt")
				config.setValue( "ACTION", keys.ACTION, "keyboard.txt")

				config.setValue( "CHOOSE", keys.CHOOSE, "keyboard.txt")
				config.setValue( "BACK", keys.BACK, "keyboard.txt")
				config.setValue( "PAUSE", keys.PAUSE, "keyboard.txt")
			--else
				config.setValue( "SCREENSHOT", keys.PAD.SCREENSHOT, "gamepad.txt")
				config.setValue( "FULLSCREEN", keys.PAD.FULLSCREEN, "gamepad.txt")
				config.setValue( "RESTARTMAP", keys.PAD.RESTARTMAP, "gamepad.txt")
				config.setValue( "RESTARTGAME", keys.PAD.RESTARTGAME, "gamepad.txt")
				config.setValue( "NEXTMAP", keys.PAD.NEXTMAP, "gamepad.txt")
			
				config.setValue( "LEFT", keys.PAD.LEFT, "gamepad.txt")
				config.setValue( "RIGHT", keys.PAD.RIGHT, "gamepad.txt")
				config.setValue( "UP", keys.PAD.UP, "gamepad.txt")
				config.setValue( "DOWN", keys.PAD.DOWN, "gamepad.txt")
			
				config.setValue( "JUMP", keys.PAD.JUMP, "gamepad.txt")
				config.setValue( "ACTION", keys.PAD.ACTION, "gamepad.txt")

				config.setValue( "CHOOSE", keys.PAD.CHOOSE, "gamepad.txt")
				config.setValue( "BACK", keys.PAD.BACK, "gamepad.txt")
				config.setValue( "PAUSE", keys.PAD.PAUSE, "gamepad.txt")
			--end
			keys.changed = false
		end
		--[[if not keys:checkInvalid() then
			menu.startTransition(settings.init, false)()		-- exit the submenu and return to parent menu
		end]]
	--end
end

function keys.startAssign( keyToAssign )
	return function()
		if menu.state == "keyboard" then
			keys.currentlyAssigning = keyToAssign
			--menu:changeText( keyToAssign, "")
			local imgOff, imgOn = getImageForKey( "", 'fontSmall' )
			menu:changeButtonImage( "key_" .. keyToAssign, imgOff, imgOn )
			menu:changeButtonLabel( "key_" .. keyToAssign, "" )
		elseif menu.state == "gamepad" then
			keys.currentlyAssigning = keyToAssign
			local imgOff, imgOn = getImageForPad( "" )
			menu:changeButtonImage( "key_PAD_" .. keyToAssign, imgOff, imgOn )
		end
	end
end

function keys.assign( key )
	if keys.currentlyAssigning then
		if menu.state == "keyboard" then
				if keys[keys.currentlyAssigning] ~= key then
					keys.changed = true
				end
				keys[keys.currentlyAssigning] = key

				--menu:changeText( keys.currentlyAssigning, key)
			local imgOff,imgOn = getImageForKey( keys[keys.currentlyAssigning] )
			menu:changeButtonImage( "key_" .. keys.currentlyAssigning, imgOff, imgOn )
			menu:changeButtonLabel( "key_" .. keys.currentlyAssigning,
						nameForKey(keys[keys.currentlyAssigning]))
			if keys.currentlyAssigning == "BACK" or keys.currentlyAssigning == "CHOOSE" then
				controlKeys:setup()
			end

			keys.currentlyAssigning = false

		elseif menu.state == "gamepad" then
			if keys.PAD[keys.currentlyAssigning] ~= key then
				keys.changed = true
			end
			keys.PAD[keys.currentlyAssigning] = key

			local imgOff,imgOn = getImageForPad( keys.PAD[keys.currentlyAssigning] )
			menu:changeButtonImage( "key_PAD_" .. keys.currentlyAssigning, imgOff, imgOn )

			if keys.currentlyAssigning == "BACK" or keys.currentlyAssigning == "CHOOSE" then
				controlKeys:setup()
			end
			keys.currentlyAssigning = false
		end
	end
end

function keys.abortAssigning()
	keys.changed = true

	imgOff,imgOn = getImageForPad( keys.PAD[keys.currentlyAssigning] )
	menu:changeButtonImage( "key_PAD_" .. keys.currentlyAssigning, imgOff, imgOn )
	keys.currentlyAssigning = false
end

function keys.setChanged()
	keys.changed = true
end

return keys
