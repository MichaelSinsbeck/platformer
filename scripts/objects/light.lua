local Light = object:New({
	tag = 'Light',
	layout = 'center',
  marginx = 0.4,
  marginy = 0.4,
	isInEditor = true,
  vis = {
		Visualizer:New('candle'),
		},
	properties = {
		type = utility.newCycleProperty({0, 1}, {'candle', 'torch'}),
	}, 
})

function Light:applyOptions()
	if self.type == 0 then
		self:setAnim('candle')
	else
		self:setAnim('torch')
	end
	self.vis[1]:update(love.math.random())
end

function Light:setAcceleration()
end

return Light
