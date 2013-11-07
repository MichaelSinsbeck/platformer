InputJump = object:New({
	tag = 'inputJump',
	layout = 'center',
  marginx = 0.4,
  marginy = 0.4,
  vis = {
		Visualizer:New('keyboardSmall'),
		--Visualizer:New('candle'),
		},
})

function InputJump:setAcceleration(dt)
end

InputAction = object:New({
	tag = 'inputAction',
	layout = 'center',
  marginx = 0.4,
  marginy = 0.4,
  vis = {
		Visualizer:New('keyboardSmall'),
		--Visualizer:New('candle'),
		},
})

function InputAction:setAcceleration(dt)
end

InputLeft = object:New({
	tag = 'InputLeft',
	layout = 'center',
  marginx = 0.4,
  marginy = 0.4,
  vis = {
		Visualizer:New('keyboardSmall'),
		--Visualizer:New('candle'),
		},
})

function InputLeft:setAcceleration(dt)
end


InputRight = object:New({
	tag = 'InputRight',
	layout = 'center',
  marginx = 0.4,
  marginy = 0.4,
  vis = {
		Visualizer:New('keyboardSmall'),
		--Visualizer:New('candle'),
		},
})

function InputRight:setAcceleration(dt)
end

function updateInputDisplays()
	if love.joystick.getNumJoysticks() > 0 then
	else
		local imgName = getImageForKey( keys.JUMP )
		if imgName == "keyLargeOff_IMG" then
			InputJump.vis[1] = Visualizer:New('keyboardLarge')
		else
			InputJump.vis[1] = Visualizer:New('keyboardSmall')
		end
		InputJump.vis[2] = Visualizer:New( nil, nil, nameForKey(keys.JUMP) )
		
		imgName = getImageForKey( keys.ACTION )
		if imgName == "keyLargeOff_IMG" then
			InputAction.vis[1] = Visualizer:New('keyboardLarge')
		else
			InputAction.vis[1] = Visualizer:New('keyboardSmall')
		end
		InputAction.vis[2] = Visualizer:New( nil, nil, nameForKey(keys.ACTION) )
		
		imgName = getImageForKey( keys.LEFT )
		if imgName == "keyLargeOff_IMG" then
			InputLeft.vis[1] = Visualizer:New('keyboardLarge')
		else
			InputLeft.vis[1] = Visualizer:New('keyboardSmall')
		end
		InputLeft.vis[2] = Visualizer:New( nil, nil, nameForKey(keys.LEFT) )
		
		imgName = getImageForKey( keys.RIGHT )
		if imgName == "keyLargeOff_IMG" then
			InputRight.vis[1] = Visualizer:New('keyboardLarge')
		else
			InputRight.vis[1] = Visualizer:New('keyboardSmall')
		end
		InputRight.vis[2] = Visualizer:New( nil, nil, nameForKey(keys.RIGHT) )
		
	end
end
--[[
function Input:postStep(dt)
	if self:touchPlayer() then
		if self.on then
			self:switch(false)
			--print("TURNED OFF")
			--myMap:setShadowActive( self.x, self.y, false )
		end
	end
end]]--
