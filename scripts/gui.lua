local gui = {}
local FullViz = Visualizer:New('guiBeanFull')
local EmptyViz = Visualizer:New('guiBeanEmpty')
local bandanaTimer = 0

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

	if mode == 'game' and bandanaTimer > 0 then
		gui.drawBandanas( Camera.width/Camera.scale - 8,
			Camera.height/Camera.scale - 8 )
	end
end

function gui.update( dt )
	if bandanaTimer > 0 then
		bandanaTimer = bandanaTimer - dt
	end
end

-- Display the bandanas at the given position
function gui.drawBandanas( x, y, dir )
	-- Left to right:
	if dir == "horizontal" then
		num = #bandanas
		for i = 1, #bandanas do
			local lX = x - (num-1)/2*16 + (i-1)*16
			bandanas[i].viz:draw( Camera.scale*lX, Camera.scale*y )
		end
	else	-- bottom to top:
		for i = 1, #bandanas do
			local lY = y - (i-1)*16
			bandanas[i].viz:draw( Camera.scale*x, Camera.scale*lY )
		end
	end
end

function gui.addBandana( color, noShow )

	print("Adding bandana:", color )

	if not noShow then
		bandanaTimer = 4		-- show for 4 seconds
	end

	-- Check if a bandana with the color is already in the list.
	-- If so, don't add it again.
	for i = 1, #bandanas do
		if bandanas[i].color == color then
			return
		end
	end

	if bandanaGuiViz[color] then
		local new = bandanaGuiViz[color]
		new:init()
		local container = {viz = new, color = color}
		table.insert( bandanas, container )
	end
end

function gui.clearBandanas()
	print("Clearing all bandanas")
	bandanas = {}
	bandanaTimer = 0
end

return gui
