local keys = {}
keys.currentlyAssigning = false		--holds the string of the key which is currently being changed.


---------------------------------------------------------
-- Defaults
---------------------------------------------------------
function keys.setDefaults()
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
end
keys.setDefaults()


---------------------------------------------------------
-- Load settings:
---------------------------------------------------------

function keys.load()
	local key
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

function keys.moveMenuPlayer( x, y, newAnimation )

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
	
	imgOff, imgOn = getImageForKey( keys.LEFT, fontSmall )
	local startButton = menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_LEFT",
					keys.startAssign( "LEFT" ), nil,
					keys.LEFT, fontSmall )
	--menu:addText( x+11, y+3, "LEFT", keys.LEFT)
	y = y + 7
	
	imgOff, imgOn = getImageForKey( keys.RIGHT, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_RIGHT",
					keys.startAssign( "RIGHT" ), nil,
					keys.RIGHT, fontSmall )
	--menu:addText( x+11, y+3, "RIGHT", keys.RIGHT)
	y = y + 7
	imgOff, imgOn = getImageForKey( keys.UP, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_UP", 
					keys.startAssign( "UP" ), nil,
					keys.UP, fontSmall )
	--menu:addText( x+11, y+3, "UP", keys.UP)
	y = y + 7
	imgOff, imgOn = getImageForKey( keys.DOWN, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_DOWN", 
					keys.startAssign( "DOWN" ), nil,
					keys.DOWN, fontSmall )
	--menu:addText( x+11, y+3, "DOWN", keys.DOWN)
	
	y = y + 14
	imgOff, imgOn = getImageForKey( keys.JUMP, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_JUMP",
					keys.startAssign( "JUMP" ), nil,
					keys.JUMP, fontSmall )
	--menu:addText( x+11, y+3, "JUMP", keys.JUMP)
	y = y + 7
	imgOff, imgOn = getImageForKey( keys.ACTION, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_ACTION",
					keys.startAssign( "ACTION" ), nil,
					keys.ACTION, fontSmall )
	--menu:addText( x+11, y+3, "ACTION", keys.ACTION)
	
	y = y + 14
	imgOff, imgOn = getImageForKey( keys.SCREENSHOT, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_SCREENSHOT",
					keys.startAssign( "SCREENSHOT" ), nil,
					keys.SCREENSHOT, fontSmall )
	--menu:addText( x+11, y+3, "SCREENSHOT", keys.SCREENSHOT)
	y = y + 7
	imgOff, imgOn = getImageForKey( keys.FULLSCREEN, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_FULLSCREEN",
					keys.startAssign( "FULLSCREEN" ), nil,
					keys.FULLSCREEN, fontSmall )
	--menu:addText( x+11, y+3, "FULLSCREEN", keys.FULLSCREEN)
	y = y + 7
	imgOff, imgOn = getImageForKey( keys.RESTARTMAP, fontSmall )
	menu:addButtonLabeled( x, y,
					imgOff, imgOn, "key_RESTARTMAP",
					keys.startAssign( "RESTARTMAP" ), nil,
					keys.RESTARTMAP, fontSmall )
	--menu:addText( x+11, y+3, "RESTARTMAP", keys.RESTARTMAP)
	
	
	-- start of with the first button selected:
	selectButton(startButton)
end


function keys.initGamepad()
	menu.state = "gamepad"
	menu:clear()
	
	keys.changed = false -- don't save configuration unless new key has been assigned
	-- TODO: Add gamepad buttons here...
	
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
