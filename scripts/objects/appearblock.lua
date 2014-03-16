local Appearblock = object:New({
	tag = 'Appearblock',
  marginx = 0.8,
  marginy = 0.8,
  isInEditor = true,
  vis = {Visualizer:New('redBlockPassable')},
	properties = {
		state = utility.newCycleProperty({'passable','solid'}, {"passable", "solid"}),
		color = utility.newCycleProperty({'red','blue','green','yellow'}),
	},  
})

function Appearblock:setAcceleration(dt)
end

function Appearblock:postStep(dt)
	self.vis[1].sx = math.min(self. vis[1].sx+dt,1)
	self.vis[1].sy = self.vis[1].sx	
	
	if self.state == 'solid'
			and self.vis[1]
			and self.vis[1].animation:sub(-8) == 'Passable'
	    and not self:touchPlayer() then
		self:setAnim(self.color .. 'BlockSolid')
		self.vis[1].sx = 0.77
		self.vis[1].sy = self.vis[1].sx
	end
end

function Appearblock:buttonPress(color)
	if self.color == color then
		self:invert()
  end
end

function Appearblock:invert()
	if self.state == 'solid' then
		self:setAnim(self.color .. 'BlockPassable')
		self.state = 'passable'
		if myMap then
			if myMap.collision and myMap.collision[math.floor(self.x)] then
				myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
			end
			myMap:queueShadowUpdate()
		end
	else
		self.state = 'solid'
		if myMap then
			if myMap.collision and myMap.collision[math.floor(self.x)] then
				myMap.collision[math.floor(self.x)][math.floor(self.y)] = 1
			end
			myMap:queueShadowUpdate()
		end
		if not self:touchPlayer() then
			self:setAnim(self.color .. 'BlockSolid')
			self.vis[1].sx = 0.77
			self.vis[1].sy = self.vis[1].sx
		end
	end
end

function Appearblock:setState( newState )
	if newState == 'passable' then
		self:setAnim(self.color .. 'BlockPassable')
		self.state = 'passable'
		if myMap then
			if myMap.collision and myMap.collision[math.floor(self.x)] then
				myMap.collision[math.floor(self.x)][math.floor(self.y)] = nil
			end
			myMap:queueShadowUpdate()
		end
	else
		self.state = 'solid'
		if myMap then
			if myMap.collision and myMap.collision[math.floor(self.x)] then
				myMap.collision[math.floor(self.x)][math.floor(self.y)] = 1
			end
			myMap:queueShadowUpdate()
		end
		self:setAnim(self.color .. 'BlockSolid')
		self.vis[1].sx = 1
		self.vis[1].sy = self.vis[1].sx
	end
end

function Appearblock:applyOptions()
	self:setState(self.state)
end

--[[
Disappearblock = Appearblock:New({
tag = 'Disappearblock',
state = 'there',
vis = {Visualizer:New('appearBlockThere')},	
})]]
return Appearblock
