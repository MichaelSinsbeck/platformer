local Npc = object:New({
	tag = 'Npc',
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  radius = 4,
  vis = {
		Visualizer:New('npc1'),
  },
	properties = {
		type = utility.newCycleProperty({'1','2','3'}),
	}, 
})

function Npc:applyOptions()
	self:setAnim('npc' .. self.type)
end

function Npc:setAcceleration(dt)
end

return Npc
