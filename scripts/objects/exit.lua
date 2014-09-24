local Exit = object:New({
	tag = 'Exit',
	category = 'Essential',
  marginx = 0.3,
  marginy = 0.6,
  isInEditor = true,
  unique = true,		-- only allow one per map
  vis = {Visualizer:New( 'exit'),},
})

function Exit:setAcceleration(dt)
end

function Exit:postStep(dt)
	if self:touchPlayer() then
		game.won = true
		self:playSound('win')
	end
end

return Exit
