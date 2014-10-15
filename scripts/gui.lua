local gui = {}
local FullViz = Visualizer:New('guiBeanFull')
local EmptyViz = Visualizer:New('guiBeanEmpty')

local bandanaGuiViz = {
	white = Visualizer:New('guiBandanaWhite'),
	yellow = Visualizer:New('guiBandanaYellow'),
	green = Visualizer:New('guiBandanaGreen'),
	red = Visualizer:New('guiBandanaRed'),
}

local bandanas = {}

function gui.init()
	beanViz:init()
end

function gui.draw()
	local s = Camera.scale
	
	FullViz:init()
	EmptyViz:init()
	
	love.graphics.setColor(255,255,255,50)
	love.graphics.rectangle('fill',0,0,10*s*(p.maxJumps-1),10*s)
	love.graphics.setColor(255,255,255)
	
	for i = 1,p.jumpsLeft do
		FullViz:draw((10*i-5)*s,5*s)
	end
	
	for i = p.jumpsLeft+1,p.maxJumps-1 do
		EmptyViz:draw((10*i-5)*s,5*s)
	end

	for i = 1, #bandanas do
		local x = Camera.width/Camera.scale - 8
		local y = Camera.height/Camera.scale - 8 - (i-1)*15
		bandanas[i]:draw( s*x, s*y )
	end
end

function gui.addBandana( color )
	if bandanaGuiViz[color] then
		local new = bandanaGuiViz[color]
		new:init()
		table.insert( bandanas, new )
	end
end

function gui.clearBandanas()
	bandanas = {}
end

return gui
