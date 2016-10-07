local Input = object:New({
	tag = 'Input',
  marginx = 0.8,
  marginy = 0.8,
  layout = 'center',
  isInEditor = true,
  vis = {
		Visualizer:New('keyboardSmall'),
  },
	properties = {
		button = utility.newCycleProperty({'RIGHT', 'LEFT', 'JUMP', 'DASH', 'ACTION'}, {'right', 'left', 'jump', 'dash','rope'}),
	},
})

function Input:applyOptions()
	local visName, text
	if love.joystick.getJoystickCount() == 0 then
		visName = getAnimationForKey(keys[self.button])
		text = nameForKey(keys[self.button])
	else
		visName = getAnimationForPad( keys.PAD[self.button])
		text = nil
	end
	self.vis[1] = Visualizer:New(visName,nil,text:upper())
	self.vis[1]:init()
end


function Input:setAcceleration(dt)
end
 
return Input
