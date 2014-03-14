local Door = object:New({
	tag = 'Door',
  marginx = 0.8,
  marginy = 0.8,
  isInEditor = true,
  status = 'passive',
  openTime = 0.05,
  solid = true,
  vis = {Visualizer:New('door'),},
})

function Door:setAcceleration(dt)
end

function Door:activate(args)
	if self.status == 'passive' and 
		math.abs(self.x-args.x)+math.abs(self.y-args.y) <= 1 then
		self.status = 'active'
		self.vis[1].timer = args.t
		myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
	end
end

function Door:postStep(dt)
	if self.status == 'active' then
		self.vis[1].sx = math.min((self.openTime-self.vis[1].timer)/self.openTime,1)
		self.vis[1].sy = math.min((self.openTime-self.vis[1].timer)/self.openTime,1)
		if self.vis[1].timer > self.openTime then
			local args = {t=self.vis[1].timer-self.openTime, x = self.x, y=self.y}
			spriteEngine:DoAll('activate',args)
			self:die()
		end
	end
end

function Door:die()
	myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
	self:kill()
	myMap:queueShadowUpdate()
end

return Door
