local gui = {}
local FullViz = Visualizer:New('guiBeanFull')
local EmptyViz = Visualizer:New('guiBeanEmpty')

function gui.init()
	beanViz:init()
end

function gui.draw()
	local s = Camera.scale
	
	FullViz:init()
	EmptyViz:init()
	
	love.graphics.setColor(255,255,255,50)
	love.graphics.rectangle('fill',0,0,10*s*(p.maxJumps-1),10*s)
	
	
	for i = 1,p.jumpsLeft do
		FullViz:draw((10*i-5)*s,5*s)
	end
	
	for i = p.jumpsLeft+1,p.maxJumps-1 do
		EmptyViz:draw((10*i-5)*s,5*s)
	end
end
  --jumpsLeft = 0,
  --maxJumps = 1,

return gui
