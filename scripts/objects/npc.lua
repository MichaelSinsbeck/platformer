--[[local t1 = 'A proper ninja must jump high. Wear the white bandana and learn the art of jumping.'
local t2 = 'A proper ninja masters the wall jump. Hug the wall and jump again.'
local t3 = 'This is the third text'
local t4 = 'This is the forth text'
local t5 = 'This is the fifth text']]


local Npc = object:New({
	tag = 'Npc',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  radius = 4,
  vis = {
		Visualizer:New('npc'),
		Visualizer:New( nil, {active = false,relY = -2}, '' ),
  },
	properties = {
		text = utility.newTextProperty( ),
		display = utility.newCycleProperty( {"region", "timer"},
				{"in region", "after delay"} , 1 ),
		delay = utility.newNumericTextProperty( 0, -math.huge, math.huge ),
		displayTime = utility.newNumericTextProperty( 10, 0.1, math.huge ),
		regionSize = utility.newNumericTextProperty( 10, -math.huge, math.huge ),
	}, 
})

function Npc:applyOptions()
	self.vis[2].text = self.text
	self.vis[2].ox = 0.5*fontSmall:getWidth(self.text)/Camera.scale
end

function Npc:setAcceleration(dt)
end

function Npc:postStep(dt)
	local dx = p.x - self.x
	local dy = p.y - self.y
	self.vis[2].active = (utility.pyth(dx,dy) < self.radius)
end

return Npc
