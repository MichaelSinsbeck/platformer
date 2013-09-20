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
	keys.PAD_SCREENSHOT = '6'
	keys.PAD_FULLSCREEN = ''
	keys.PAD_RESTARTMAP = ''
	keys.PAD_RESTARTGAME = ''
	keys.PAD_NEXTMAP = ''

	keys.PAD_LEFT = 'left'
	keys.PAD_RIGHT = 'right'
	keys.PAD_UP = 'up'
	keys.PAD_DOWN = 'down'

	keys.PAD_JUMP = '1'
	keys.PAD_ACTION = '2'	
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
	if key then keys.PAD_SCREENSHOT = key end
	key = config.getValue( "FULLSCREEN", "gamepad.txt")
	if key then keys.PAD_FULLSCREEN = key end
	key = config.getValue( "RESTARTMAP", "gamepad.txt")
	if key then keys.PAD_RESTARTMAP = key end
	key = config.getValue( "RESTARTGAME", "gamepad.txt")
	if key then keys.PAD_RESTARTGAME = key end
	key = config.getValue( "NEXTMAP", "gamepad.txt")
	if key then keys.PAD_NEXTMAP = key end
	
	key = config.getValue( "LEFT", "gamepad.txt")
	if key then keys.PAD_LEFT = key end
	key = config.getValue( "RIGHT", "gamepad.txt")
	if key then keys.PAD_RIGHT = key end
	key = config.getValue( "UP", "gamepad.txt")
	if key then keys.PAD_UP = key end
	key = config.getValue( "DOWN", "gamepad.txt")
	if key then keys.PAD_DOWN = key end
	
	key = config.getValue( "JUMP", "gamepad.txt")
	if key then keys.PAD_JUMP = key end
	key = config.getValue( "ACTION", "gamepad.txt")
	if key then keys.PAD_ACTION = key end
	
end


function keys.startAssign( keyToAssign )
	return function()
		keys.currentlyAssigning = keyToAssign
		--menu:changeText( keyToAssign, "")
		local imgOff, imgOn = getImageForKey( "", fontSmall )
		menu:changeButtonImage( "key_" .. keyToAssign, imgOff, imgOn )
		menu:changeButtonLabel( "key_" .. keyToAssign, "" )
	end
end

function keys.assign( key )
	if keys.currentlyAssigning then
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
	end
end

function getImageForKey( str, font )
	if str == " " then str = "space" end
	if #str > 1 then --font:getWidth(str) > menu.images.keyOn_IMG:getWidth()/2 then
		return "keyLargeOff_IMG", "keyLargeOn_IMG"
	end
	return "keyOff_IMG", "keyOn_IMG"
end

function getImageForPad( str )
	print("looking for", str, type(str))
	if str == "1" then
		return "gamepadA_IMG"
	elseif str == "2" then
		return "gamepadB_IMG"
	elseif str == "3" then
		return "gamepadX_IMG"
	elseif str == "4" then
		return "gamepadY_IMG"
	elseif str == "5" then
		return "gamepadLB_IMG"
	elseif str == "6" then
		return "gamepadRB_IMG"
	elseif str == "up" then
		return "gamepadUp_IMG"
	elseif str == "down" then
		return "gamepadDown_IMG"
	elseif str == "left" then
		return "gamepadLeft_IMG"
	elseif str == "right" then
		return "gamepadRight_IMG"
	else
		return "gamepadUp_IMG"
	end
end

function keys.moveMenuPlayer( x, y, newAnimation )
	return function()
		menuPlayer.x = x
		menuPlayer.y = y
		print("pos:", menuPlayer.x, menuPlayer.y)
		menuPlayer.vis:setAni( newAnimation )
		local sel = menu:getSelected()
		if sel and sel.name == "key_LEFT" then
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
	
	local x,y = 0, -35
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
	--menu:addText( x+11, y+3, "LEFT", keys.LEFT)
	y = y + 7
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteWalk" )
	imgOff, imgOn = getImageForKey( keys.RIGHT, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_RIGHT",
					keys.startAssign( "RIGHT" ), hoverEvent,
					keys.RIGHT, fontSmall )
	--menu:addText( x+11, y+3, "RIGHT", keys.RIGHT)
	y = y + 7
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "moveUpWhite" )
	imgOff, imgOn = getImageForKey( keys.UP, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_UP", 
					keys.startAssign( "UP" ), hoverEvent,
					keys.UP, fontSmall )
	--menu:addText( x+11, y+3, "UP", keys.UP)
	y = y + 7
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "moveDownWhite" )
	imgOff, imgOn = getImageForKey( keys.DOWN, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_DOWN", 
					keys.startAssign( "DOWN" ), hoverEvent,
					keys.DOWN, fontSmall )
	--menu:addText( x+11, y+3, "DOWN", keys.DOWN)
	y = y + 14
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "jumpFallWhite" )
	imgOff, imgOn = getImageForKey( keys.JUMP, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_JUMP",
					keys.startAssign( "JUMP" ), hoverEvent,
					keys.JUMP, fontSmall )
	--menu:addText( x+11, y+3, "JUMP", keys.JUMP)
	y = y + 7
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "bandanaColor" )
	imgOff, imgOn = getImageForKey( keys.ACTION, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_ACTION",
					keys.startAssign( "ACTION" ), hoverEvent,
					keys.ACTION, fontSmall )
	--menu:addText( x+11, y+3, "ACTION", keys.ACTION)
	y = y + 14
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForKey( keys.SCREENSHOT, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_SCREENSHOT",
					keys.startAssign( "SCREENSHOT" ), hoverEvent,
					keys.SCREENSHOT, fontSmall )
	--menu:addText( x+11, y+3, "SCREENSHOT", keys.SCREENSHOT)
	y = y + 7
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForKey( keys.FULLSCREEN, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_FULLSCREEN",
					keys.startAssign( "FULLSCREEN" ), hoverEvent,
					keys.FULLSCREEN, fontSmall )
	--menu:addText( x+11, y+3, "FULLSCREEN", keys.FULLSCREEN)
	y = y + 7
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOff, imgOn = getImageForKey( keys.RESTARTMAP, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_RESTARTMAP",
					keys.startAssign( "RESTARTMAP" ), hoverEvent,
					keys.RESTARTMAP, fontSmall )
	--menu:addText( x+11, y+3, "RESTARTMAP", keys.RESTARTMAP)
	
	
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
	imgOn = getImageForPad( keys.PAD_LEFT )
	local startButton = menu:addButton( x, y,
					imgOn, imgOn, "key_PAD_LEFT",
					keys.startAssign( "PAD_LEFT" ), hoverEvent )
	--menu:addText( x+11, y+3, "LEFT", keys.LEFT)
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteWalk" )
	imgOn = getImageForPad( keys.PAD_RIGHT )
	menu:addButton( x, y,
					imgOn, imgOn, "key_PAD_RIGHT",
					keys.startAssign( "PAD_RIGHT" ), hoverEvent )
	--menu:addText( x+11, y+3, "RIGHT", keys.RIGHT)
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "moveUpWhite" )
	imgOn = getImageForPad( keys.PAD_UP )
	menu:addButton( x, y,
					imgOn, imgOn, "key_PAD_UP", 
					keys.startAssign( "PAD_UP" ), hoverEvent )
	--menu:addText( x+11, y+3, "UP", keys.UP)
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "moveDownWhite" )
	imgOn = getImageForPad( keys.PAD_DOWN )
	menu:addButton( x, y,
					imgOn, imgOn, "key_PAD_DOWN", 
					keys.startAssign( "PAD_DOWN" ), hoverEvent )
	--menu:addText( x+11, y+3, "DOWN", keys.DOWN)
	
	y = -35
	x = 30
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "jumpFallWhite" )
	imgOn = getImageForPad( keys.PAD_JUMP )
	menu:addButton( x, y,
					imgOn, imgOn, "key_PAD_JUMP",
					keys.startAssign( "PAD_JUMP" ), hoverEvent )
	--menu:addText( x+11, y+3, "JUMP", keys.JUMP)
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "bandanaColor" )
	imgOn = getImageForPad( keys.PAD_ACTION )
	menu:addButton( x, y,
					imgOn, imgOn, "key_PAD_ACTION",
					keys.startAssign( "PAD_ACTION" ), hoverEvent )
	--menu:addText( x+11, y+3, "ACTION", keys.ACTION)
	y = y + 14
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOn = getImageForPad( keys.PAD_SCREENSHOT )
	menu:addButton( x, y,
					imgOn, imgOn, "key_PAD_SCREENSHOT",
					keys.startAssign( "PAD_SCREENSHOT" ), hoverEvent )
	--menu:addText( x+11, y+3, "SCREENSHOT", keys.SCREENSHOT)
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOn = getImageForPad( keys.PAD_FULLSCREEN )
	menu:addButton( x, y,
					imgOn, imgOn, "key_PAD_FULLSCREEN",
					keys.startAssign( "PAD_FULLSCREEN" ), hoverEvent )
	--menu:addText( x+11, y+3, "FULLSCREEN", keys.FULLSCREEN)
	y = y + 10
	
	hoverEvent = keys.moveMenuPlayer( x - ninjaDistX, y - ninjaDistY, "whiteStand" )
	imgOn = getImageForPad( keys.PAD_RESTARTMAP, fontSmall )
	menu:addButton( x, y,
					imgOn, imgOn, "key_PAD_RESTARTMAP",
					keys.startAssign( "PAD_RESTARTMAP" ), hoverEvent )
	--menu:addText( x+11, y+3, "RESTARTMAP", keys.RESTARTMAP)
	
	
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
