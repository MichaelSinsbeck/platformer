bridge = {}

function bridge:start()
	menu.initWorldMap()
	mode = 'bridge'
	
	menu.xTarget = Campaign.worldNumber*165-8
	menu.xCamera = menu.xTarget-165
	self.time = 0
	menuPlayer.vis:setAni(Campaign.bandana .. "Walk")
	menuPlayer.vis.sx = 1
	menuPlayer.vis:reset()
	menuPlayer.vis:update(0.1)
end

function bridge:draw()
	menu:draw()
end

function bridge:update(dt)
	self.time = self.time + dt
	
	-- scroll world map
	local factor = math.min(1, 3*dt)
	menu.xCamera = menu.xCamera + factor * (menu.xTarget- menu.xCamera)
	
	-- bridge building animation
	menu:easeLogs(self.time-1)
	
	if self.time > 3 then -- when finished, go to menu
		menu.AddOneWorldMap()
		mode = 'menu'
	end
end



