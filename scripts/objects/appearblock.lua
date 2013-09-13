Appearblock = object:New({
	tag = 'appearblock',
  marginx = 0.8,
  marginy = 0.8,
  state = 'notThere',
  vis = {Visualizer:New('appearBlockNotThere')},
})

function Appearblock:setAcceleration(dt)
end

function Appearblock:postStep(dt)
	self.vis[1].sx = math.min(self. vis[1].sx+dt,1)
	self.vis[1].sy = self.vis[1].sx	
	
	if self.state == 'there'
			and self.vis[1]
			and self.vis[1].animation == 'appearBlockNotThere'
	    and not self:touchPlayer() then
		self:setAnim('appearBlockThere')
		self.vis[1].sx = 0.77
		self.vis[1].sy = self.vis[1].sx
	end
end

function Appearblock:buttonPress()
  self:invert()
end

function Appearblock:invert()
  if self.state == 'there' then
    self:setAnim('appearBlockNotThere')
    self.state = 'notThere'
    myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
  else
		self.state = 'there'
		myMap.collision[math.floor(self.x)][math.floor(self.y)] = 1
		if not self:touchPlayer() then
		  self:setAnim('appearBlockThere')
			self.vis[1].sx = 0.77
			self.vis[1].sy = self.vis[1].sx
		end
  end
end

Disappearblock = Appearblock:New({
	tag = 'Disappearblock',
	state = 'there',
  vis = {Visualizer:New('appearBlockThere')},	
})
