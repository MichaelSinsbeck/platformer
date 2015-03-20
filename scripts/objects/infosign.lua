local Infosign = object:New({
	tag = 'Infosign',
  marginx = 0.8,
  marginy = 0.8,
  z = 1,
  isInEditor = true,
  layout = 'center',
  vis = {Visualizer:New('signText'),},
	properties = {
		type = utility.newCycleProperty({'Text','Left','Right'}),
		rotation = utility.newCycleProperty({0, 1, 2, 3},{'bottom','left','top','right'}),
	},
})

function Infosign:applyOptions()
	self.vis[1].angle = self.rotation * 0.5 * math.pi
	self:setAnim('sign' .. self.type)
end

function Infosign:setAcceleration()
end

return Infosign
