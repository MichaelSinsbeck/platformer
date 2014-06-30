-- pictures for level end display:
local Pic = require("scripts/levelEndPic")

levelEnd = {
	levels = {}
}

local statList = {}
local boxes = {}
local statBoxes = {}
local picList = {}

local STAT_TIME = 0.5

function levelEnd:init()
	-- preload all the levels which could be needed:
	self.levels["end_fall"] = Map:loadFromFile( "levels/end_fall.dat" )
	self.levels["end_wall"] = Map:loadFromFile( "levels/end_wall.dat" )
	self.levels["end_dirt"] = Map:loadFromFile( "levels/end_dirt.dat" )
	self.levels["end_air"] = Map:loadFromFile( "levels/end_air.dat" )
	self.levels["end_spikes"] = Map:loadFromFile( "levels/end_spikes.dat" )
	self.levels["end"] = Map:loadFromFile( "levels/end.dat" )
end

function levelEnd:reset()
	statList["death_fall"] = 0
	statList["death_shuriken"] = 0
	statList["death_goalie"] = 0
	statList["death_imitator"] = 0
	statList["death_missile"] = 0
	statList["death_spikey"] = 0
	statList["death_runner"] = 0
	statList["death_walker"] = 0
	statList["death_water"] = 0
	statList["death_medusa"] = 0

	statList["noDeaths"] = 0

	self:levelRestart()
	
	self.timer = 0
end

-- If a death occurred, then don't reset the deaths!
-- Only reset the other values:
function levelEnd:levelRestart()
	statList["highestJump"] = 0
	statList["farthestJump"] = 0 
	statList["timeInAir"] = 0
	statList["idleTime"] = 0
	statList["numberOfJumps"] = 0
	statList["longestWallHang"] = 0
	statList["numberOfButtons"] = 0
	statList["fastestVelocity"] = 0
	statList["time"] = 0
	statList["distWalked"] = 0
	self.jump = nil
	self.wallHang = nil
end

function levelEnd:addDeath( deathType )
	print("new death:", deathType )
	statList[deathType] = statList[deathType] + 1

	levelEnd:levelRestart()	 -- reset other stats, but not the deaths.
end

function levelEnd:update( dt )
	self.timer = self.timer + dt
	for k, p in pairs( picList ) do
		if boxes[k].timer <= self.timer then
			p:update( dt )
		end
	end
end

function levelEnd:draw()
	shaders:setDeathEffect( .8 )
	--shaders.grayScale:send( "amount", .8 )
	--love.graphics.setPixelEffect( shaders.grayScale )
	--game:draw()
	--love.graphics.setPixelEffect()
	love.graphics.push()
	love.graphics.translate(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
	-- for now, just show a simple list:
	
	-- draw boxes:	
	for k,element in pairs(boxes) do
		if element.timer <= self.timer then
			-- scale box coordinates according to scale
			local scaled = {}
			for i = 1,#element.points do
				scaled[i] = element.points[i] * Camera.scale
			end
			-- draw
			love.graphics.setColor(44,90,160)
			love.graphics.setLineWidth(Camera.scale*0.5)
			love.graphics.rectangle('fill',
			element.left*Camera.scale,
			element.top*Camera.scale,
			element.width*Camera.scale,
			element.height*Camera.scale)
			love.graphics.setColor(0,0,10)
			love.graphics.line(scaled)

			picList[k]:draw()
		end
	end

	--[[love.graphics.setFont( fontSmall )
	local font = love.graphics.getFont()
	local i = 0
	for k, v in pairs( statList ) do
		love.graphics.setColor(110,168,213)
		love.graphics.print(string.lower(k), - font:getWidth(string.lower(k)) + 70, - font:getHeight()*(12 -i))
		love.graphics.setColor(255,255,255)
		love.graphics.print(v, 75, - font:getHeight()*(12-i))
		i = i+1
	end]]--


	love.graphics.pop()

	controlKeys:draw("win")
end

function levelEnd:display( )	-- called when level is won:
	mode = 'levelEnd'
	love.graphics.setBackgroundColor(40,40,40)
	boxes = {}
	picList = {}
	--self:addBox(-30,-60,60,80)

	local deaths =
		statList["death_fall"] + 
		statList["death_shuriken"] + statList["death_goalie"] +
		statList["death_imitator"] + statList["death_missile"] +
		statList["death_spikey"] + statList["death_runner"] +
		statList["death_walker"] + statList["death_medusa"]
		print(deaths, "deaths")

	if deaths == 0 then
		statList["noDeaths"] = 1
	end

	--statList["death_fall"] = math.random(10)
	--statList["death_spikey"] = math.random(10)
	--[[
	for k,v in pairs( statList ) do
		statList[k] = 0
	end]]--
	--statList["numberOfButtons"] = math.random(5)
	--[[
	statList["death_walker"] = math.random(5)
	statList["death_spikey"] = math.random(5)
	statList["death_fall"] = math.random(5)]]

	-- create a list which holds all the values which were relevant for this
	-- level (i.e. their values are not zero - the event happened)
	--print("Level Statistics:")
	local relevantList = {}
	for statType, num in pairs(statList) do
		--print( "\t", statType, num )
		if num > 0 then
			table.insert( relevantList, {num=num, statType=statType} )
		end
	end

	-- don't try to display more pictures than possible:
	self.numOfStats = math.min( 3, #relevantList )

	-- width of the area a slot can use up:
	local fullWidth = 300
	local width = fullWidth/(self.numOfStats + 1)

	if self.numOfStats == 0 then
		return
	end

	local pos

	for i = 1,self.numOfStats do
		-- randomly choose a stat to display:
		k = math.random(#relevantList)
		pos = -fullWidth/2 + width*i
		
		self:addBox(pos - 30,-40,60,70, (i-1)*STAT_TIME )
		picList[#picList + 1] = 
			Pic:new( pos, 0, relevantList[k].statType, relevantList[k].num, (i-1)*2 + 1 )

		-- don't display a second time:
		table.remove( relevantList, k )
	end
end

function levelEnd:keypressed( key, unicode )
	if key == keys.BACK or key == keys.PAD.BACK then
		print("state", menu.state)
		if editor.active then
			editor.resume()
		elseif menu.currentlyPlayingUserlevels then
			menu.startTransition(menu.initUserlevels)()	-- start the transition and fade into world map
		else
			Campaign:setLevel(Campaign.current+1)
			Campaign:saveState()
			menu.startTransition(menu.initWorldMap)()	-- start the transition and fade into world map
		end
	elseif key == keys.CHOOSE or key == keys.PAD.CHOOSE then
		-- if you're not displaying all stats yet,then display them now
		-- otherwise, proceed to next level.
		if self.timer < (self.numOfStats -1)*STAT_TIME then
			self.timer = self.timer + self.numOfStats*STAT_TIME
		else
			if editor.active then
				editor.resume()
			elseif menu.currentlyPlayingUserlevels then
				menu.startTransition(menu.initUserlevels)()	-- start the transition and fade into world map
			else
				menu.startTransition(function () Campaign:proceed() end)()
			end
		end
	end
end

function levelEnd:addBox( left,top,width,height, time)
	local new = {}
	new.points = {}
	new.left = left
	new.top = top
	new.width = width
	new.height = height
	new.timer = time
	local index = 1
	local stepsize = 0
	table.insert(new.points, left)
	table.insert(new.points, top)
	for i = 1,math.floor(.2*width) do
		stepsize = width/math.floor(.2*width)
		table.insert(new.points, left + i*stepsize)
		table.insert(new.points, top)
	end
	
	for i = 1,math.floor(.2*height) do
		stepsize = height/math.floor(.2*height)
		table.insert(new.points, left+width)
		table.insert(new.points, top + i*stepsize)
	end
	
	for i = 1,math.floor(.2*width) do
		stepsize = width/math.floor(.2*width)
		table.insert(new.points, left + width - i*stepsize)
		table.insert(new.points, top + height)
	end
		
	for i = 1,math.floor(.2*height) do
		stepsize = height/math.floor(.2*height)
		table.insert(new.points, left)
		table.insert(new.points, top + height - i*stepsize)
	end
	
	for i = 1,#new.points-2 do
		new.points[i] = new.points[i] + 0.4*math.random() - 0.4*math.random()
	end
	new.points[#new.points-1] = new.points[1]
	new.points[#new.points] = new.points[2]

	table.insert(boxes, new)
end

function levelEnd:registerJumpStart( x, y )
	levelEnd.jump = {x=x, y=y, time=love.timer.getTime()}
	statList["numberOfJumps"] = statList["numberOfJumps"] + 1
end
function levelEnd:registerJumpPeak( x, y )
	if levelEnd.jump and not levelEnd.jump.reachedHighestPoint then
		levelEnd.jump.reachedHighestPoint = true
		if levelEnd.jump.y - y > statList["highestJump"] then
			statList["highestJump"] = levelEnd.jump.y - y
		end
	end
end
function levelEnd:registerJumpEnd( x, y )
	if levelEnd.jump then
		if math.abs(levelEnd.jump.x - x) > statList["farthestJump"] then
			statList["farthestJump"] = math.abs(levelEnd.jump.x - x)
		end
		statList["timeInAir"] = statList["timeInAir"] +
					love.timer.getTime() - levelEnd.jump.time
		levelEnd.jump = nil
	end
end

function levelEnd:registerButtonPress()
	statList["numberOfButtons"] = statList["numberOfButtons"] + 1
end

function levelEnd:registerStart()
	statList["time"] = love.timer.getTime()
end

function levelEnd:registerEnd()
	if p then
		self:registerJumpEnd( p.x, p.y )
	end

	statList["time"] = love.timer.getTime() - statList["time"]
end

function levelEnd:registerVelocity( vx, vy)
	local v2 = vx^2 + vy^2
	if v2 > statList["fastestVelocity"]^2 then
		statList["fastestVelocity"] = math.sqrt(v2)
	end
end

function levelEnd:registerWallHangStart()
	self.wallHang = {time = love.timer.getTime()}
end

function levelEnd:registerWallHangEnd()
	if levelEnd.wallHang then
		local time = love.timer.getTime() - levelEnd.wallHang.time
		if time > statList["longestWallHang"] then
			statList["longestWallHang"] = time
		end
	end
end

function levelEnd:registerIdle( dt )
	statList["idleTime"] = statList["idleTime"] + dt
end

function levelEnd:registerWalkedDist( dist )
	statList["distWalked"] = statList["distWalked"] + dist
end
