local Bridge = {}
Bridge.__index = Bridge
local nLogs = 10

function Bridge:new( x, y, noAnimation )
	local o = {}
	setmetatable( o, self )
	o.x = x
	o.y = y
	o.time = 0
	if noAnimation then
		o.time = 1
	end
	o.logs = {}
	o.animationFinished = false

	local wx = 1.5
	for i = 1,nLogs do
		local thisVis = Visualizer:New('log')
		thisVis:init()
		local wy = 5 - math.sin(math.pi * (i-1)/(nLogs-1))				
		table.insert(o.logs, {vis = thisVis, x = wx, y = wy})
		wx = wx + 2.1
	end

	self.update( o, o.time*2 )

	return o
end

function Bridge:draw()
	for k,log in ipairs(self.logs) do
		log.vis:draw((self.x + log.x)*Camera.scale,(self.y + log.y)*Camera.scale)
	end
end

function Bridge:update(dt)
	self.time = self.time + dt*0.5
	
	-- bridge building animation
	self:easeLogs(self.time-1)
	
	--[[if self.time > 3 then -- when finished, go to menu
		menu.AddOneWorldMap()
		mode = 'menu'
	end]]

	if self.time >= 1.4 then
		for k,log in ipairs(self.logs) do
			log.vis.sx = 1
			log.vis.sy = 1
		end
		self.animationFinished = true
	end
end

-- changes scales of Logs, if existant
function Bridge:easeLogs(t)
	for k,log in ipairs(self.logs) do
	--	if k > (Campaign.worldNumber-1) * nLogs and k <= Campaign.worldNumber * nLogs then
	--		local i = k - Campaign.worldNumber * nLogs -1
	--		local tEase = t-(i-1)/(nLogs-1)-1
		local tEase = (self.time - (k-1)/nLogs)*2
			log.vis.sx = self:easing(tEase)
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
