--[[bridge = {}

function bridge:start()
	menu.initWorldMap()
	mode = 'bridge'
	
	menu.xTarget = Campaign.worldNumber*165-8
	menu.xCamera = menu.xTarget-165
	self.time = 0
	menuPlayer.vis[1]:setAni("playerWalk")
	menuPlayer.vis[1].sx = 1
	menuPlayer.vis[1]:reset()
	menuPlayer.vis[1]:update(0.1)
	
	menuPlayer.vis[2]:setAni("bandanaWalk")
	menuPlayer.vis[2].sx = 1
	menuPlayer.vis[2]:reset()
	menuPlayer.vis[2]:update(0.1)
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
end]]

local Bridge = {}
Bridge.__index = Bridge
local nLogs = 10

function Bridge:new( x, y )
	local o = {}
	setmetatable( o, self )
	o.x = x
	o.y = y
	o.time = 0
	o.logs = {}

	local wx = 1.5
	for i = 1,nLogs do
		local thisVis = Visualizer:New('log')
		thisVis:init()
		local wy = 5 - math.sin(math.pi * (i-1)/(nLogs-1))				
		table.insert(o.logs, {vis = thisVis, x = wx, y = wy})
		wx = wx + 2.1
	end

	return o
end

function Bridge:draw()
	for k,log in ipairs(self.logs) do
		log.vis:draw((self.x + log.x)*Camera.scale,(self.y + log.y)*Camera.scale)
	end
end

function Bridge:update(dt)
	self.time = self.time + dt
	
	-- scroll world map
	--local factor = math.min(1, 3*dt)
	--menu.xCamera = menu.xCamera + factor * (menu.xTarget- menu.xCamera)
	
	-- bridge building animation
	self:easeLogs(self.time-1)
	
	--[[if self.time > 3 then -- when finished, go to menu
		menu.AddOneWorldMap()
		mode = 'menu'
	end]]
end

-- changes scales of Logs, if existant
function Bridge:easeLogs(t)
	for k,log in ipairs(self.logs) do
	--	if k > (Campaign.worldNumber-1) * nLogs and k <= Campaign.worldNumber * nLogs then
	--		local i = k - Campaign.worldNumber * nLogs -1
	--		local tEase = t-(i-1)/(nLogs-1)-1
			log.vis.sx = self:easing(self.time)
			log.vis.sy = log.vis.sx
		--end
	end
end

-- simple easing function with "overshoot"
function Bridge:easing(t)
	if t <= 0 then
		return 0
	elseif t >= 1 then
		return 1
	else
		return 1-(1-3*t)*((1-t)^2)
	end
end

return Bridge
