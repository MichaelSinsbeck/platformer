local keys = {}

-- defaults:
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

function keys.startAssignment( keyToAssign )
	keys.waitingForKeypress = keyToAssign
end

function keys.assign( key )
	if keys.waitingForKeypress then
		if key ~= 'esc' and key ~= 'return' then
		
		end
		keys.waitingForKeypress = false
	end
end

return keys
