local keys = {}
keys.currentlyAssigning = false		--holds the string of the key which is currently being changed.


---------------------------------------------------------
-- Defaults
---------------------------------------------------------
function keys.setDefaults()
	-- keyboard defaults:
	keys.SCREENSHOT = 't'
	keys.FULLSCREEN = 'f'
	keys.RESTARTMAP = 'p'
	keys.RESTARTGAME = 'o'
	keys.NEXTMAP = 'q'

	keys.LEFT = 'left'
	keys.RIGHT = 'right'
	keys.UP = 'up'
	keys.DOWN = 'down'

	keys.JUMP = 'a'
	keys.ACTION = 's'
	
	-- gamepad defaults:
	keys.PAD = {}
	keys.PAD.SCREENSHOT = '6'
	keys.PAD.FULLSCREEN = ''
	keys.PAD.RESTARTMAP = ''
	keys.PAD.RESTARTGAME = ''
	keys.PAD.NEXTMAP = ''

	keys.PAD.LEFT = 'l'
	keys.PAD.RIGHT = 'r'
	keys.PAD.UP = 'u'
	keys.PAD.DOWN = 'd'

	keys.PAD.JUMP = '1'
	keys.PAD.ACTION = '2'
	
	
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
	
end


function keys.startAssign( keyToAssign )
	return function()
		if menu.state == "keyboard" then
			keys.currentlyAssigning = keyToAssign
			--menu:changeText( keyToAssign, "")
			local imgOff, imgOn = getImageForKey( "", fontSmall )
			menu:changeButtonImage( "key_" .. keyToAssign, imgOff, imgOn )
			menu:changeButtonLabel( "key_" .. keyToAssign, "" )
		elseif menu.state == "gamepad" then
			keys.currentlyAssigning = keyToAssign
			local imgOff, imgOn = getImageForPad( "" )
			print("new,",imgOff,imgOn)
			menu:changeButtonImage( "key_PAD_" .. keyToAssign, imgOff, imgOn )
		end
	end
end

function keys.assign( key )
	if keys.currentlyAssigning then
		if menu.state == "keyboard" then
			print("ASSIGNING", keys.currentlyAssigning, key)
			if key ~= 'escape' and key ~= 'return' and key ~= 'backspace' then
				if keys[keys.currentlyAssigning] ~= key then
					keys.changed = true
				end
				keys[keys.currentlyAssigning] = key
				--menu:changeText( keys.currentlyAssigning, key)
			end
			--menu:changeText( keys.currentlyAssigning, keys[keys.currentlyAssigning])
		
			local imgOff, imgOn = getImageForKey( keys[keys.currentlyAssigning], fontSmall )
			print("new", imgOff, imgOn)
			menu:changeButtonImage( "key_" .. keys.currentlyAssigning, imgOff, imgOn )
			menu:changeButtonLabel( "key_" .. keys.currentlyAssigning, keys[keys.currentlyAssigning] )
			keys.currentlyAssigning = false
		elseif menu.state == "gamepad" then
			if keys.PAD[keys.currentlyAssigning] ~= key then
				keys.changed = true
			end
			keys.PAD[keys.currentlyAssigning] = key
			
			imgOff,imgOn = getImageForPad( keys.PAD[keys.currentlyAssigning] )
			menu:changeButtonImage( "key_PAD_" .. keys.currentlyAssigning, imgOff, imgOn )
			keys.currentlyAssigning = false
		end
	end
end

function getImageForKey( str, font )
	if str == "" then
		return "keyNone_IMG", "keyNone_IMG"
	end
	
	if str == " " then str = "space" end
	if #str > 1 then --font:getWidth(str) > menu.images.keyOn_IMG:getWidth()/2 then
		return "keyLargeOff_IMG", "keyLargeOn_IMG"
	end
	return "keyOff_IMG", "keyOn_IMG"
end

function getImageForPad( str )
	if str == "1" then
		return "gamepadA_IMG","gamepadA_IMG"
	elseif str == "2" then
		return "gamepadB_IMG","gamepadB_IMG"
	elseif str == "3" then
		return "gamepadX_IMG","gamepadX_IMG"
	elseif str == "4" then
		return "gamepadY_IMG","gamepadY_IMG"
	elseif str == "5" then
		return "gamepadLB_IMG","gamepadLB_IMG"
	elseif str == "6" then
		return "gamepadRB_IMG","gamepadRB_IMG"
	elseif str == "u" then
		return "gamepadUp_IMG","gamepadUp_IMG"
	elseif str == "d" then
		return "gamepadDown_IMG","gamepadDown_IMG"
	elseif str == "l" then
		return "gamepadLeft_IMG","gamepadLeft_IMG"
	elseif str == "r" then
		return "gamepadRight_IMG","gamepadRight_IMG"
	else
		return "keyNone_IMG","keyNone_IMG"
	end
end

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
				keys.gamepadPressed[k] = true
			end
			if tonumber(v) then	-- if the button is a number button, check if that one's pressed
				if love.joystick.isDown( 1, tonumber(v) ) then
					keys.gamepadPressed[k] = true
				end
			end
		end
	end
	
	keys.lastFrameJoyHat = joyHat
end

function keys.getGamepadIsDown( str )
	return keys.gamepadPressed[str]
end

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

---------------------------------------------------------
-- Display key setting menus:
---------------------------------------------------------

--[[
function keys.initKeyboard()
	menu.state = "keyboard"
	menu:clear()
	
	keys.changed = false -- don't save configuration unless new key has been assigned
	
	local x,y = -25, -45
	
	local startButton = menu:addButtonAnimated( x+5, y+5,
						'whiteWalk', 'whiteWalk', "left",
						keys.startAssign( "LEFT" ), nil,
						-.9, .9 )
	menu:addText( x+11, y+3, "LEFT", keys.LEFT)
	
	y = y + 10
	
	local hoverAction
	
	menu:addButtonAnimated( x+5, y+5, 'whiteWalk', 'whiteWalk', "right", keys.startAssign( "RIGHT" ), nil, .9, .9 )
	menu:addText( x+11, y+3, "RIGHT", keys.RIGHT)
	y = y + 10
	menu:addButtonAnimated( x+5, y+5, 'moveUpWhite', 'moveUpWhite', "up", keys.startAssign( "UP" ), nil, .9, .9 )
	menu:addText( x+11, y+3, "UP", keys.UP)
	y = y + 10
	menu:addButtonAnimated( x+5, y+5, 'moveDownWhite', 'moveDownWhite', "down", keys.startAssign( "DOWN" ), nil, .9, .9 )
	menu:addText( x+11, y+3, "DOWN", keys.DOWN)
	
	y = y + 17
	menu:addButtonAnimated( x+5, y+5, 'jumpFallWhite', 'jumpFallWhite', "jump", keys.startAssign( "JUMP" ), nil, .9, .9 )
	menu:addText( x+11, y+3, "JUMP", keys.JUMP)
	y = y + 10
	menu:addButtonAnimated( x+5, y+5, 'bandanaColor', 'bandanaColor', "use bandana", keys.startAssign( "ACTION" ), nil,.9,.9 )
	menu:addText( x+11, y+3, "ACTION", keys.ACTION)
	
	y = y + 17
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "screenshot", keys.startAssign( "SCREENSHOT" ), nil )
	menu:addText( x+11, y+3, "SCREENSHOT", keys.SCREENSHOT)
	y = y + 10
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "fullscreen", keys.startAssign( "FULLSCREEN" ), nil )
	menu:addText( x+11, y+3, "FULLSCREEN", keys.FULLSCREEN)
	y = y + 10
	menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "restart map", keys.startAssign( "RESTARTMAP" ), nil )
	menu:addText( x+11, y+3, "RESTARTMAP", keys.RESTARTMAP)
	
	
	-- start of with the first button selected:
	selectButton(startButton)
end
]]--


function keys.initKeyboard()
	menu.state = "keyboard"
	menu:clear()
	
	keys.changed = false -- don't save configuration unless new key has been assigned
	
	local x,y = -30, -35
	local imgOff, imgOn
	local hoverEvent
	local ninjaDistX = 3
	local ninjaDistY = -4
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteWalk" )
	imgOff, imgOn = getImageForKey( keys.LEFT, fontSmall )
	local startButton = menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_LEFT",
					keys.startAssign( "LEFT" ), hoverEvent,
					keys.LEFT, fontSmall )
	menu:addText( x-8 - fontSmall:getWidth("left")/Camera.scale, y+3, "LEFT", "left")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteWalk" )
	imgOff, imgOn = getImageForKey( keys.RIGHT, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_RIGHT",
					keys.startAssign( "RIGHT" ), hoverEvent,
					keys.RIGHT, fontSmall )
	menu:addText( x-8 - fontSmall:getWidth("right")/Camera.scale, y+3, "RIGHT", "right")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "moveUpWhite" )
	imgOff, imgOn = getImageForKey( keys.UP, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_UP", 
					keys.startAssign( "UP" ), hoverEvent,
					keys.UP, fontSmall )
	menu:addText( x-8 - fontSmall:getWidth("up")/Camera.scale, y+3, "UP", "up")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "moveDownWhite" )
	imgOff, imgOn = getImageForKey( keys.DOWN, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_DOWN", 
					keys.startAssign( "DOWN" ), hoverEvent,
					keys.DOWN, fontSmall )
	menu:addText( x-8 - fontSmall:getWidth("down")/Camera.scale, y+3, "DOWN", "down")
	
	y = -35
	x = 30
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "jumpFallWhite" )
	imgOff, imgOn = getImageForKey( keys.JUMP, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_JUMP",
					keys.startAssign( "JUMP" ), hoverEvent,
					keys.JUMP, fontSmall )
	menu:addText( x-8 - fontSmall:getWidth("jump")/Camera.scale, y+3, "JUMP", "jump")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "bandanaColor" )
	imgOff, imgOn = getImageForKey( keys.ACTION, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_ACTION",
					keys.startAssign( "ACTION" ), hoverEvent,
					keys.ACTION, fontSmall )
	menu:addText( x-8 - fontSmall:getWidth("action")/Camera.scale, y+3,	"ACTION", "action")

	local x,y = 0, 20

	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForKey( keys.SCREENSHOT, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_SCREENSHOT",
					keys.startAssign( "SCREENSHOT" ), hoverEvent,
					keys.SCREENSHOT, fontSmall )
	menu:addText( x-8 - fontSmall:getWidth("screenshot")/Camera.scale, y+3,
					"SCREENSHOT", "screenshot")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForKey( keys.FULLSCREEN, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_FULLSCREEN",
					keys.startAssign( "FULLSCREEN" ), hoverEvent,
					keys.FULLSCREEN, fontSmall )
	menu:addText( x-8 - fontSmall:getWidth("fullscreen")/Camera.scale, y+3,
					"FULLSCREEN", "fullscreen")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForKey( keys.RESTARTMAP, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_RESTARTMAP",
					keys.startAssign( "RESTARTMAP" ), hoverEvent,
					keys.RESTARTMAP, fontSmall )
	menu:addText( x-8 - fontSmall:getWidth("restart map")/Camera.scale, y+3,
					"RESTARTMAP", "restart map")
	
	
	-- start of with the first button selected:
	selectButton(startButton)
end


function keys.initGamepad()
	menu.state = "gamepad"
	menu:clear()
	
	keys.changed = false -- don't save configuration unless new key has been assigned
	
	local x,y = -30, -35
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
	
	y = -35
	x = 30
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "jumpFallWhite" )
	imgOff,imgOn = getImageForPad( keys.PAD.JUMP )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_JUMP",
					keys.startAssign( "JUMP" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("jump")/Camera.scale, y+3, "JUMP", "jump")
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "bandanaColor" )
	imgOff,imgOn = getImageForPad( keys.PAD.ACTION )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_ACTION",
					keys.startAssign( "ACTION" ), hoverEvent )
	menu:addText( x-8 - fontSmall:getWidth("use bandana")/Camera.scale, y+3, "ACTION", "use bandana")
	y = y + 14
	
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
	imgOff,imgOn = getImageForPad( keys.PAD.RESTARTMAP, fontSmall )
	menu:addButton( x, y,
					imgOff, imgOn, "key_PAD_RESTARTMAP",
					keys.startAssign( "RESTARTMAP" ), hoverEvent )
	menu:addText( x-20, y+3, "RESTARTMAP", "restart map")
	]]--
	
	-- start of with the first button selected:
	selectButton(startButton)
	
end

function keys:exitSubMenu()
	if not keys.currentlyAssigning then
		if keys.changed then
			if menu.state == "keyboard" then	-- save keyboard layout:
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
			end
		end
		settings.init()
	end
end

return keys
