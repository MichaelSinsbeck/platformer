-- contains a list of all images displayed at level end:
local pics = {}
local picList = {}
local tileSize = 48 -- fallback
local slotHeight = 2	-- height of each slot (in screen space)

function pics:reset()
	picList = {}
	tileSize = Camera.scale*8
end

local function generateSlots( num, width )
	num = math.ceil(num)
	local slots = {}
	local slotWidth = width/num
	local startX = - width/2 --+ tileSize/Camera.scale/2
	for k = 1, num do
		slots[k] = { x = startX + slotWidth*(k-1), y = tileSize/Camera.scale*1.4, taken = {} }
	end
	return slots
end

function pics:generateCountList( num )
	
	local full5 = math.floor( num / 5 )	-- how many images should show 5 lines
	local rest = num - full5*5	-- the rest of lines will be on the last image
	local images = full5
	if rest > 0 then
		images = images + 1
	end
	local list = {}
	local listX = {}
	local listY = {}
	
	local listStartX = -images*tileSize/2/Camera.scale + tileSize/Camera.scale/2
	
	for k = 1, full5 do
		local lNum = #list+1
		list[lNum] = Visualizer:New( 'listCount5' )
		list[lNum]:init()
		listX[lNum] = listStartX + tileSize*(lNum-1)/Camera.scale
		listY[lNum] = (-3.5 + math.random(10)/40)*tileSize/Camera.scale
	end
	if rest > 0 then
		local lNum = #list+1
		list[lNum] = Visualizer:New( 'listCount' .. rest )
		list[lNum]:init()
		listX[lNum] = listStartX + tileSize*(lNum-1)/Camera.scale
		listY[lNum] = (-3.5 + math.random(10)/40)*tileSize/Camera.scale -- + math.random(2)
	end
	
	return list, listX, listY -- return the images and the x and y positions
end

function pics:new( x, y, statType, num )

	-- round down at third digit behind the decimal point:
	num = math.floor(num*1000)/1000

	local newPic = { x=x, y=y, statType = statType,
					vis = {}, posX = {}, posY = {},
					list = {}, listPosX = {}, listPosY = {}}
					
	if statType == "death_fall" then
		newPic.title = "falls"
		local width = math.min(num*3, tileSize*2 )
		local randomWidth = 3
		-- generate positions so that they overlap, but each position is unique:
		local freeSlots = generateSlots( num/2, width )
		newPic.slots = freeSlots
		local found = false
		local tries = 0

		newPic.map = Map:LoadFromFile( 'end_fall.dat' )
		
		-- fill 'num' of these slots with images:
		for k = num, 1, -1 do
			newPic.vis[k] = Visualizer:New( 'deathFall' .. math.random(4) )
			newPic.vis[k]:init()
			if math.random(2) == 1 then
				newPic.vis[k].sx = -1
			end
			
			found = false
			tries = 0
			repeat
				local id = math.random( #freeSlots )
				if not freeSlots[id].taken[1] then
					found = true
					freeSlots[id].taken[1] = true
					newPic.posX[k] = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.posY[k] = freeSlots[id].y
				elseif not freeSlots[id].taken[2] then
					found = true
					freeSlots[id].taken[2] = true
					newPic.posX[k] = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.posY[k] = freeSlots[id].y - slotHeight
				elseif not freeSlots[id].taken[3] then
					found = true
					freeSlots[id].taken[3] = true
					newPic.posX[k] = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.posY[k] = freeSlots[id].y - slotHeight*2
				end
				tries = tries + 1
			until (found == true or tries > num*5)
		end
		
		newPic.list, newPic.listPosX, newPic.listPosY = pics:generateCountList( num )
	elseif statType == "death_spikes" then
		newPic.title = "pierced"
		local width = math.min(num*3, tileSize*2 )
		local randomWidth = 3
		-- generate positions so that they overlap, but each position is unique:
		local freeSlots = generateSlots( num/2, width )
		newPic.slots = freeSlots
		local found = false
		local tries = 0
		
		newPic.map = Map:LoadFromFile( 'end_spikes.dat' )

		-- fill 'num' of these slots with images:
		for k = num, 1, -1 do
			newPic.vis[k] = Visualizer:New( 'deathSpikes' .. math.random(4) )
			newPic.vis[k]:init()
			if math.random(2) == 1 then
				newPic.vis[k].sx = -1
			end
			
			found = false
			tries = 0
			repeat
				local id = math.random( #freeSlots )
				if not freeSlots[id].taken[1] then
					found = true
					freeSlots[id].taken[1] = true
					newPic.posX[k] = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.posY[k] = freeSlots[id].y
				elseif not freeSlots[id].taken[2] then
					found = true
					freeSlots[id].taken[2] = true
					newPic.posX[k] = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.posY[k] = freeSlots[id].y - slotHeight
				elseif not freeSlots[id].taken[3] then
					found = true
					freeSlots[id].taken[3] = true
					newPic.posX[k] = freeSlots[id].x + math.random(randomWidth*2)-randomWidth
					newPic.posY[k] = freeSlots[id].y - slotHeight*2
				end
				tries = tries + 1
			until (found == true or tries > num*5)
		end
		
		newPic.list, newPic.listPosX, newPic.listPosY = pics:generateCountList( num )
	elseif statType == "timeInAir" then

		newPic.title = "time in air:"
		newPic.subTitle = num .. " s"
		newPic.map = Map:LoadFromFile( 'end.dat' )
		newPic.vis[1] = Visualizer:New( 'statTimeInAir' )
		newPic.vis[1]:init()
		newPic.posX[1] = 0
		newPic.posY[1] = -tileSize/Camera.scale*2
	elseif statType == "farthestJump" then

		newPic.title = "longest jump:"
		newPic.subTitle = num .. " m"
		newPic.map = Map:LoadFromFile( 'end.dat' )
		newPic.vis[1] = Visualizer:New( 'statHighestJump' )
		newPic.vis[1]:init()
		newPic.posX[1] = 0
		newPic.posY[1] = tileSize/Camera.scale*1.4
	elseif statType == "idleTime" then

		newPic.title = "idle for:"
		newPic.subTitle = num .. " s"
		newPic.map = Map:LoadFromFile( 'end.dat' )
		newPic.vis[1] = Visualizer:New( 'statIdleTime' )
		newPic.vis[1]:init()
		newPic.posX[1] = 0
		newPic.posY[1] = tileSize/Camera.scale*1.4
	elseif statType == "highestJump" then

		newPic.title = "highest jump:"
		newPic.subTitle = num .. " m"
		newPic.map = Map:LoadFromFile( 'end_air.dat' )
		newPic.vis[1] = Visualizer:New( 'statHighestJump' )
		newPic.vis[1]:init()
		newPic.posX[1] = 0
		newPic.posY[1] = tileSize/Camera.scale*0.4
	elseif statType == "noDeaths" then

		newPic.title = "survived"
		newPic.map = Map:LoadFromFile( 'end.dat' )
		newPic.vis[1] = Visualizer:New( 'statNoDeath' .. math.random(2) )
		newPic.vis[1]:init()
		newPic.posX[1] = 0
		newPic.posY[1] = tileSize/Camera.scale*1.4
	else
		newPic.title = string.lower(statType)
		newPic.map = Map:LoadFromFile( 'end.dat' )
	end

	picList[#picList+1] = newPic
end

function pics:draw( i )
	local x,y

	local pic = picList[i]
		love.graphics.push()
		love.graphics.translate( Camera.scale*pic.x, Camera.scale*pic.y )

		if pic.map then
			love.graphics.push()
			love.graphics.translate( -(pic.map.width + 2)/2*Camera.scale*8,
			-(pic.map.height + 2)/2*Camera.scale*8)
			pic.map:drawBG()
			pic.map:drawWalls()
			love.graphics.pop()
		end

		for k = 1, #pic.vis do
			x = pic.posX[k]
			y = pic.posY[k]
			pic.vis[k]:draw( x*Camera.scale, y*Camera.scale )
		end
		for k = 1, #pic.list do
			x = pic.listPosX[k]
			y = pic.listPosY[k]
			pic.list[k]:draw( x*Camera.scale, y*Camera.scale )
		end

		if pic.title then
			love.graphics.print( pic.title,
								-fontSmall:getWidth( pic.title )/2,
								-tileSize*4.5 )
			if pic.subTitle then

				love.graphics.print( pic.subTitle,
								-fontSmall:getWidth( pic.subTitle )/2,
								-tileSize*3.5 )
			end
		end
	--	love.graphics.print( pic.statType, 0, 0 )
		--pic.map:drawFG()
		love.graphics.pop()
	love.graphics.setColor(255,255,255)
end

return pics
