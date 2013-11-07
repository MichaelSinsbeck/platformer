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
	if love.joystick.getNumJoysticks() == 0 then
		InputJump.vis[1] = Visualizer:New(  getAnimationForKey( keys.JUMP ) )
		InputJump.vis[2] = Visualizer:New( nil, nil, nameForKey(keys.JUMP) )
		
		InputJump.vis[1] = Visualizer:New(  getAnimationForKey( keys.ACTION ) )
		InputAction.vis[2] = Visualizer:New( nil, nil, nameForKey(keys.ACTION) )
		
		InputJump.vis[1] = Visualizer:New(  getAnimationForKey( keys.LEFT ) )
		InputLeft.vis[2] = Visualizer:New( nil, nil, nameForKey(keys.LEFT) )
		
		InputJump.vis[1] = Visualizer:New(  getAnimationForKey( keys.RIGHT ) )
		InputRight.vis[2] = Visualizer:New( nil, nil, nameForKey(keys.RIGHT) )
	else

		InputJump.vis[1] = Visualizer:New(  getAnimationForPad( keys.PAD.JUMP ) )
		InputJump.vis[2] = nil
		
		InputAction.vis[1] = Visualizer:New(  getAnimationForPad( keys.PAD.ACTION ) )
		InputAction.vis[2] = nil
		
		InputLeft.vis[1] = Visualizer:New(  getAnimationForPad( keys.PAD.LEFT ) )
		InputLeft.vis[2] = nil
		
		InputRight.vis[1] = Visualizer:New(  getAnimationForPad( keys.PAD.RIGHT ) )
		InputRight.vis[2] = nil
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
