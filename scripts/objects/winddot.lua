Winddot = object:New({
	tag = 'winddot',
  marginx = 0,
  marginy = 1,
	--animation = 'wind1',
	vx = 0,
	vy = Player.windMaxSpeed,
	vis = {Visualizer:New('wind1')},
})

function Winddot:setAcceleration(dt)
end

function Winddot:step(dt)
  self.x = self.newX
  self.y = self.newY
end

function Winddot:postStep(dt)
	local thisTile = 0
	if myMap.collision[math.floor(self.x)] then
		thisTile = myMap.collision[math.floor(self.x)][math.floor(self.y)]
	end
if thisTile~=4 or self.collisionResult > 0 then
		self:kill()
	end
end
