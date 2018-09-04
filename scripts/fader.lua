local fader = {}

local timer = 0
local timeIn = 0.2
local timeOut = 0.6
local middleFunction
local levelNumber
local phase = 1
local startTime

function fader:fadeTo(lvlNum)
	timer = 0
	phase = 1
	levelNumber = lvlNum
	self.active = true
	startTime = love.timer.getTime()
end

function fader:switchFunction(lvlNum)
	local fcn = function()
		fader:fadeTo(lvlNum)
	end
	return fcn
end

function fader:update(dt)
	timer = love.timer.getTime() - startTime
	if phase == 1 and timer>timeIn then
		menu:setCameraToTarget()
		self.switchToLevel(levelNumber)
		phase = 2
		startTime = love.timer.getTime()
	elseif phase == 2 and timer >timeOut then
		self.active = false
			
	end
end

function fader:draw()
	timer = love.timer.getTime() - startTime
	if phase == 1 then
		local progress = math.min(timer/timeIn,1)
		love.graphics.setColor(0,0,0,progress)
		love.graphics.rectangle('fill',0,0,Camera.width,Camera.height)
	elseif phase == 2 then
		local progress = timer/timeOut
		--local radius = math.max(Camera.width*(1-progress),0)
		local x = p.x*8*Camera.scale+Camera.xWorld
		local y = p.y*8*Camera.scale+Camera.yWorld
		local radius = 2*Camera.width*math.exp(-5*(1-progress))
		local stencilFunction = function()
			love.graphics.circle('fill',x,y,radius)
		end
		love.graphics.stencil( stencilFunction, "replace", 1)
		--love.graphics.setInvertedStencil( stencilFunction)
		love.graphics.setStencilTest("equal", 0)
		
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle('fill',0,0,Camera.width,Camera.height)
		--love.graphics.circle('fill',x,y,radius)
		
		love.graphics.setStencilTest()
		love.graphics.circle('line',x,y,radius)
	end
end

function fader.switchToLevel(lvlNum)
	Campaign.current = lvlNum		
	--p = spriteFactory('Player')
	mode = 'game'

	gravity = 22
	local lvl = "levels/" .. Campaign[lvlNum]
	myMap = Map:loadFromFile( lvl )
	levelEnd:reset()		-- resets the counters of all deaths etc
	collectgarbage() -- run garbage collection to delete old level
	myMap:start()
	config.setValue( "level", Campaign[lvlNum] )
	
	-- Add all bandans the user has already received:
	gui.clearBandanas()
	if Campaign.names[Campaign[lvlNum]] then
		gui:newLevelName( Campaign.names[Campaign[lvlNum]] )
	end
	
	local bandanas = {"white","yellow","green","blue","red"}
	local noShow = true
	if Campaign.bandana ~= 'blank' then
		gui.addBandana ( Campaign.bandana, noShow)
	end
end

return fader
