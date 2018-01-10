local Dragonmarker = object:New({
	tag = 'Dragonmarker',
	layout = 'center',
	category = "Interactive",
	isInEditor = true,
	marginx = 1,
	marginy = 1,
	vis = {
		Visualizer:New('windmillpreview'),
	},
	properties = {
		phase = utility.newCycleProperty({1,2,3,4,5,6,7,8,9}),
	}
})

function Dragonmarker:setAcceleration(dt)
end

function Dragonmarker:postStep(dt)
	self.vis[1].alpha = 0
end

return Dragonmarker
