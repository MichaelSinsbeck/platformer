local gui = {}
local FullViz = Visualizer:New('guiBeanFull')
local EmptyViz = Visualizer:New('guiBeanEmpty')

local LevelNameDisplay = require("scripts/levelNameDisplay")
local bandanaTimer = 0
local levelNameDisplay
local bandanaDuration = 4
local bandanaReveal
local newBandana

local bandana2num = {white=1,yellow=2,green=3,blue=4,red=5}

local bandanaGuiViz = {
	Visualizer:New('guiBandanaWhite'),
	Visualizer:New('guiBandanaYellow'),
	Visualizer:New('guiBandanaGreen'),
	Visualizer:New('guiBandanaBlue'),
	Visualizer:New('guiBandanaRed'),
	Visualizer:New('guiBandanaNone'),
}

local bandanas = {false,false,false,false,false}

function gui.init() 
	for k,v in pairs(bandanaGuiViz) do
		v:init()
	end
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
			Camera.height/Camera.scale - 12 )
	end
	if levelNameDisplay then
		levelNameDisplay:draw()
	end
end

function gui.update( dt )
	if bandanaTimer > 0 then
		bandanaTimer = bandanaTimer - dt
		if bandanaReveal and bandanaTimer < 0.75*bandanaDuration - 0.1*bandanaReveal then
			bandanas[bandanaReveal] = true
			newBandana = bandanaReveal
			bandanaReveal = nil
			-- todo: play a sound for the upgrade
		end
	end
	if levelNameDisplay then
		local result = levelNameDisplay:update( dt )
		if result == false then
			levelNameDisplay = nil
		end
	end
end

-- Display the bandanas at the given position
function gui.drawBandanas( x, y )
	-- Left to right:
	for idx,v  in ipairs(bandanas) do
		-- calculate position
		local lX = x - (5-1)/2*16 + (idx-1)*16-40
		local lY
		if bandanaDuration - bandanaTimer < 1 then
			lY = y + 20*(1-utility.easingOvershoot(3*(bandanaDuration-bandanaTimer-0.1*idx)))
		else
			lY = y + 20*(1-utility.easingOvershoot(3*bandanaTimer-0.5+0.1*idx))
		end
		-- calculate scaling factor
		local s = 1
		if idx ==newBandana then
		  s = 1 + 0.5*math.exp(20* (bandanaTimer - 0.75*bandanaDuration + 0.1*newBandana))
		end
		local thisVis
		-- draw
		if v then	
			thisVis = bandanaGuiViz[idx]
		else
			thisVis = bandanaGuiViz[6]
		end
		thisVis.sx = s
		thisVis.sy = s
		thisVis:draw(Camera.scale*lX,Camera.scale*lY)
		
	end
end

function gui.addBandana( color, noShow )
	print("Adding bandana: ".. color )
	newBandana = nil
	local number = bandana2num[color]
	if noShow then -- silently set bandana
		bandanas[number] = true
	else -- start animation and remember number
		bandanaReveal = number
		bandanaTimer = bandanaDuration
	end
end

function gui.clearBandanas()
	print("Clearing all bandanas")
	bandanas = {false,false,false,false,false}
	bandanaTimer = 0
end

function gui:newLevelName( name )
	-- Create a new level-name-display box and show for 5 seconds:
	levelNameDisplay = LevelNameDisplay:new( name, 5 )
end

return gui
