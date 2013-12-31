-- contains a list of all images displayed at level end:
local tileSize = 48 -- fallback
local slotHeight = 5	-- height of each slot (in screen space)

Pic = {}
Pic.__index = Pic


local function generateSlots( num, width, yPos )
	num = math.ceil(num)
	local slots = {}
	local startX = - (width*(num-1))/2
	print("generate", num, startX, width, yPos )
	for k = 1, num do
		slots[k] = { x = startX + width*(k-1), y = yPos, taken = {} }
--		slots[k] = { x = 0, y = 0, taken = {} }
	end
	return slots
end


local function generateCountList( num, tileSize )
	local full5 = math.floor( num / 5 )	-- how many images should show 5 lines
	local rest = num - full5*5	-- the rest of lines will be on the last image
	local images = full5
	if rest > 0 then
		images = images + 1
	end
	local list = {}
	
	local listStartX = -images*tileSize/2+ tileSize/2
	
	for k = 1, full5 do
		local lNum = #list+1
		list[lNum] = Visualizer:New( 'listCount5' )
		list[lNum]:init()
		list[lNum].posX = listStartX + tileSize*(lNum-1)
		list[lNum].posY = (-3.5 + math.random(10)/40)*tileSize
	end
	if rest > 0 then
		local lNum = #list+1
		list[lNum] = Visualizer:New( 'listCount' .. rest )
		list[lNum]:init()
		list[lNum].posX = listStartX + tileSize*(lNum-1)
		list[lNum].posY = (-3.5 + math.random(10)/40)*tileSize-- + math.random(2)
	end

	return list -- return the images and the x and y positions
end

function Pic:new( x, y, statType, num )

	-- round down at third digit behind the decimal point:
	num = math.floor(num*1000)/1000
	tileSize = Camera.scale*8

	local newPic = { x=x, y=y, statType = statType,
					visFG = {}, visBG = {},
					list = {},
				}
	setmetatable( newPic, self )

	print(statType)
					
	if statType == "death_fall" then
		newPic.title = "falls"
		local width = tileSize
		local randomWidth = tileSize/4
		-- generate positions so that they overlap, but each position is unique:
		local freeSlots = generateSlots( math.min(num/2, 6), width/2, 1.4*tileSize )


		newPic.slots = freeSlots
		local found = false
		local tries = 0

		newPic.map = levelEnd.levels["end_fall"]
		
		-- fill 'num' of these slots with images:
		for k = num, 1, -1 do
			newPic.visFG[k] = Visualizer:New( 'deathFall' .. math.random(4) )
			newPic.visFG[k]:init()
			if math.random(2) == 1 then
				newPic.visFG[k].sx = -1
			end
			
			found = false
			tries = 0
			repeat
				local id = math.random( #freeSlots )
				if not freeSlots[id].taken[1] then
					found = true
					freeSlots[id].taken[1] = true
					newPic.visFG[k].posX = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.visFG[k].posY = freeSlots[id].y
				elseif not freeSlots[id].taken[2] then
					found = true
					freeSlots[id].taken[2] = true
					newPic.visFG[k].posX = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.visFG[k].posY = freeSlots[id].y - slotHeight
				elseif not freeSlots[id].taken[3] then
					found = true
					freeSlots[id].taken[3] = true
					newPic.visFG[k].posX = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.visFG[k].posY = freeSlots[id].y - slotHeight*2
				end
				tries = tries + 1
			until (found == true or tries > num*5)
			if not found then
				local id = math.random(#freeSlots)
				newPic.visFG[k].posX = freeSlots[id].x
				newPic.visFG[k].posY = freeSlots[id].y
			end
		end
		
		newPic.list = generateCountList( num, tileSize )
	elseif statType == "death_spikey" then
		newPic.title = "pierced"
		local width = tileSize*1.4
		local randomWidth = tileSize/4
		-- generate positions so that they overlap, but each position is unique:
		local freeSlots = generateSlots( math.min(num/2, 4), width/2, 1.4*tileSize )
		newPic.slots = freeSlots
		local found = false
		local tries = 0
		
		newPic.map = levelEnd.levels["end_spikes"]

		-- fill 'num' of these slots with images:
		for k = num, 1, -1 do
			newPic.visFG[k] = Visualizer:New( 'deathSpikes' .. math.random(4) )
			newPic.visFG[k]:init()
			if math.random(2) == 1 then
				newPic.visFG[k].sx = -1
			end
			
			found = false
			tries = 0
			repeat
				local id = math.random( #freeSlots )
				if not freeSlots[id].taken[1] then
					found = true
					freeSlots[id].taken[1] = true
					newPic.visFG[k].posX = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.visFG[k].posY = freeSlots[id].y
				elseif not freeSlots[id].taken[2] then
					found = true
					freeSlots[id].taken[2] = true
					newPic.visFG[k].posX = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.visFG[k].posY = freeSlots[id].y - slotHeight
				elseif not freeSlots[id].taken[3] then
					found = true
					freeSlots[id].taken[3] = true
					newPic.visFG[k].posX = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.visFG[k].posY = freeSlots[id].y - slotHeight*2
				end
				tries = tries + 1
			until (found == true or tries > num*5)
			if not found then
				local id = math.random(#freeSlots)
				newPic.visFG[k].posX = freeSlots[id].x
				newPic.visFG[k].posY = freeSlots[id].y
			end
		end
		
		newPic.list = generateCountList( num, tileSize )
	elseif statType == "death_walker" then
		newPic.title = "collision"
		local width = tileSize*2.5
		local randomWidth = tileSize/3
		-- generate positions so that they overlap, but each position is unique:
		local freeSlots = generateSlots( math.min(num/2, 5), width/2, -tileSize )
		newPic.slots = freeSlots
		local found = false
		local tries = 0
		
		newPic.map = levelEnd.levels["end_dirt"]

		-- fill 'num' of these slots with images:
		for k = num, 1, -1 do
			newPic.visFG[k] = Visualizer:New( 'deathWalker' .. math.random(4) )
			newPic.visFG[k]:init()
			if math.random(2) == 1 then
				newPic.visFG[k].sx = -1
			end
			
			found = false
			tries = 0
			repeat
				local id = math.random( #freeSlots )
				if not freeSlots[id].taken[1] then
					found = true
					freeSlots[id].taken[1] = true
					newPic.visFG[k].posX = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.visFG[k].posY = freeSlots[id].y
				elseif not freeSlots[id].taken[2] then
					found = true
					freeSlots[id].taken[2] = true
					newPic.visFG[k].posX = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.visFG[k].posY = freeSlots[id].y - slotHeight
				elseif not freeSlots[id].taken[3] then
					found = true
					freeSlots[id].taken[3] = true
					newPic.visFG[k].posX = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.visFG[k].posY = freeSlots[id].y - slotHeight*2
				end
				tries = tries + 1
			until (found == true or tries > num*5)
			if not found then
				local id = math.random(#freeSlots)
				newPic.visFG[k].posX = freeSlots[id].x
				newPic.visFG[k].posY = freeSlots[id].y
			end
		end
		
		newPic.list = generateCountList( num, tileSize )
	elseif statType == "timeInAir" then
		newPic.title = "time in air:"
		newPic.subTitle = num .. " s"
		newPic.map = levelEnd.levels["end_air"]
		newPic.visFG[1] = Visualizer:New( 'statTimeInAir' )
		newPic.visFG[1]:init()
		newPic.visFG[1].posX = -tileSize/4
		newPic.visFG[1].posY = -tileSize*1.5
	elseif statType == "farthestJump" then
		newPic.title = "longest jump:"
		newPic.subTitle = num .. " m"
		newPic.map = levelEnd.levels["end_air"]
		newPic.visBG[1] = Visualizer:New( 'statLongestJump' )
		newPic.visBG[1]:init()
		newPic.visBG[1].posX = -tileSize/2
		newPic.visBG[1].posY = -tileSize*1.5
	elseif statType == "numberOfButtons" then
		newPic.title = "buttons:"
		newPic.list, newPic.listPosX, newPic.listPosY = generateCountList( num, tileSize )
		newPic.map = levelEnd.levels["end_air"]
		newPic.visBG[1] = Visualizer:New( 'statNumberOfButtons' )
		newPic.visBG[1]:init()
		newPic.visBG[1].posX = 0
		newPic.visBG[1].posY = tileSize*0.55
	elseif statType == "numberOfJumps" then
		newPic.title = "jumps:"
		newPic.list, newPic.listPosX, newPic.listPosY = generateCountList( num, tileSize )
		newPic.map = levelEnd.levels["end"]
		newPic.visBG[1] = Visualizer:New( 'statNumberOfJumps' )
		newPic.visBG[1]:init()
		newPic.visBG[1].posX = 0
		newPic.visBG[1].posY = tileSize*(-1.1)
	elseif statType == "highestJump" then
		newPic.title = "highest jump:"
		newPic.subTitle = num .. " m"
		newPic.map = levelEnd.levels["end_air"]
		newPic.visBG[1] = Visualizer:New( 'statHighestJump' )
		newPic.visBG[1]:init()
		newPic.visBG[1].posX = 0
		newPic.visBG[1].posY = tileSize*0.7
	elseif statType == "fastestVelocity" then
		newPic.title = "max speed:"
		newPic.subTitle = num .. " m/s"
		newPic.map = levelEnd.levels["end_dirt"]
		newPic.visBG[1] = Visualizer:New( 'statVelocity' )
		newPic.visBG[1]:init()
		newPic.visBG[1].posX = -tileSize*2
		newPic.visBG[1].posY = -tileSize*0.8
	elseif statType == "distWalked" then
		newPic.title = "walked:"
		newPic.subTitle = num .. " m" 
		newPic.map = levelEnd.levels["end_dirt"]
		newPic.visBG[1] = Visualizer:New( 'statVelocity' )
		newPic.visBG[1]:init()
		newPic.visBG[1].posX = -tileSize*2
		newPic.visBG[1].posY = -tileSize*0.8
	elseif statType == "longestWallHang" then

		newPic.title = "longest wall hang"
		newPic.subTitle = num .. " s"
		newPic.map = levelEnd.levels["end_wall"]
		newPic.visFG[1] = Visualizer:New( 'statWallHang' )
		newPic.visFG[1]:init()
		newPic.visFG[1].posX = tileSize/2
		newPic.visFG[1].posY = tileSize*0.4
	elseif statType == "idleTime" then

		newPic.title = "idle for:"
		newPic.subTitle = num .. " s"
		newPic.map = levelEnd.levels["end"]
		newPic.visBG[1] = Visualizer:New( 'statIdle' )
		newPic.visBG[1]:init()
		newPic.visBG[1].posX = 0
		newPic.visBG[1].posY = tileSize*(-1.2)
	elseif statType == "noDeaths" then

		newPic.title = "survived"
		newPic.map = levelEnd.levels["end"]
		newPic.visBG[1] = Visualizer:New( 'statNoDeath' .. math.random(2) )
		newPic.visBG[1]:init()
		newPic.visBG[1].posX = 0
		newPic.visBG[1].posY = tileSize*(-1.8)
	elseif statType == "time" then
		newPic.title = "level time"
		newPic.subTitle = num .. " s"
		newPic.map = levelEnd.levels["end_air"]
		newPic.visBG[1] = Visualizer:New( 'statTime' )
		newPic.visBG[1]:init()
		newPic.visBG[1].posX = 0
		newPic.visBG[1].posY = tileSize*( 0.6 )
	else
		newPic.title = string.lower(statType)
		newPic.subTitle = num
		newPic.map = levelEnd.levels["end"]
	end
	return newPic
end

function Pic:update( dt )
	for k, v in pairs( self.visBG )do
		v:update( dt )
	end
	for k, v in pairs( self.visFG )do
		v:update( dt )
	end
end

function Pic:draw()
	local x,y

	love.graphics.push()
	love.graphics.translate( Camera.scale*self.x, Camera.scale*self.y )
	
	for k = 1, #self.visBG do
		self.visBG[k]:draw( self.visBG[k].posX, self.visBG[k].posY )
	end
	
	if self.map then
		love.graphics.push()
		love.graphics.translate( -(self.map.width + 2)/2*Camera.scale*8,
		-(self.map.height + 2)/2*Camera.scale*8)
		self.map:drawBG()
		self.map:drawWalls()
		love.graphics.pop()
	end

	for k = 1, #self.visFG do
		self.visFG[k]:draw( self.visFG[k].posX, self.visFG[k].posY )
	end
	for k = 1, #self.list do
		self.list[k]:draw( self.list[k].posX, self.list[k].posY )
	end

	if self.title then
		love.graphics.setFont(fontSmall)
		love.graphics.print( self.title,
		-fontSmall:getWidth( self.title )/2,
		-tileSize*4.5 )
		if self.subTitle then

			love.graphics.print( self.subTitle,
			-fontSmall:getWidth( self.subTitle )/2,
			-tileSize*3.5 )
		end
	end
--[[	for k = 1, #self.slots do
		love.graphics.circle("fill", self.slots[k].x, self.slots[k].y, 5)
	end
	love.graphics.setColor(255,255,255)
		love.graphics.circle("fill", 0, 0, 6) --]]

	--love.graphics.print( self.statType, 0, 0 )
	--self.map:drawFG()
	love.graphics.pop()
	love.graphics.setColor(255,255,255)
end

