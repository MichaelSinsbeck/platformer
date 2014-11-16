local Winddot = object:New({
	tag = 'Winddot',
  marginx = 0,
  marginy = 1,
	--animation = 'wind1',
	vx = 0,
	vy = -20, -- should be the same value as in player.lua
	vis = {Visualizer:New('wind1')},
	yDeath = 0,
})

function Winddot:setAcceleration(dt)
end

function Winddot:collision()
	return 0
end

function Winddot:step(dt)
  self.x = self.newX
  self.y = self.newY
end

function Winddot:postStep(dt)
	if self.y < self.yDeath then
		self:kill()
	end
end

return Winddot
