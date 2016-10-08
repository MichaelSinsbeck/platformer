local gui = {}
local FullViz = Visualizer:New('guiBeanFull')
local EmptyViz = Visualizer:New('guiBeanEmpty')

local LevelNameDisplay = require("scripts/levelNameDisplay")
local bandanaTimer = 0 -- time until bandana icons fade away
local levelNameDisplay
local bandanaDuration = 4
local iconState = 0

local bandana2num = {white=1,yellow=2,green=3,blue=4,red=5}
local bandanaTimes = {math.huge,math.huge,math.huge,math.huge,math.huge} -- time until icon appears

local bandanaGuiViz = {
	Visualizer:New('guiBandanaWhite'),
	Visualizer:New('guiBandanaYellow'),
	Visualizer:New('guiBandanaGreen'),
	Visualizer:New('guiBandanaBlue'),
	Visualizer:New('guiBandanaRed'),
	Visualizer:New('guiBandanaNone'),
}

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
	
	-- draw beans
	for i = 1,p.jumpsLeft do
		FullViz:draw((10*i-5)*s,5*s)
	end
	
	for i = p.jumpsLeft+1,p.maxJumps-1 do
		EmptyViz:draw((10*i-5)*s,5*s)
	end

	-- draw bandanas
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
		for i = 1,5 do
			bandanaTimes[i] = math.max(bandanaTimes[i] - dt,0)
		end
		if bandanaTimer > 1 then
			iconState = math.min(iconState + dt,1)
		else
			iconState = math.max(bandanaTimer,0)
		end

		-- todo: play a sound for the upgrade
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
	for idx, thisTime  in ipairs(bandanaTimes) do
		-- calculate position
		local lX = x - (5-1)/2*16 + (idx-1)*16-40
		local lY = y + 20*(1-utility.easingOvershoot(3*iconState-0.1*idx))

		-- calculate scaling factor
		local s = 1
		if thisTime > 0 and thisTime < 0.1 then
		s = 0.5 + 0.5*math.exp(20*bandanaTimes[idx])
		end

		-- draw
		local thisVis
		if thisTime < 0.1 then	
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
	--print("Adding bandana: ".. color )
	newBandana = nil
	local number = bandana2num[color]
	if number == nil then 
		bandanaTimer = bandanaDuration
		return
	end
	if noShow then -- silently set bandana
		for i = 1,number do
			bandanaTimes[i] = 0
		end
	else -- start animation and remember number
		local needToShow = false
		print(number)
		for i = 1,number do
			if bandanaTimes[i] == math.huge then
				needToShow = true
				bandanaTimes[i] = 1+0.1*i
			end
		end
		if needToShow then
			bandanaTimer = bandanaDuration
		end
	end
end

function gui.clearBandanas()
	--print("Clearing all bandanas")
	bandanaTimes = {math.huge,math.huge,math.huge,math.huge,math.huge}
	bandanaTimer = 0
	iconState = 0
end

function gui:newLevelName( name )
	-- Create a new level-name-display box and show for 5 seconds:
	levelNameDisplay = LevelNameDisplay:new( name, 5 )
end

return gui
