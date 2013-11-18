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
	local startX = - width/2 + tileSize/Camera.scale/2
	print(rows, startX)
	for k = 1, num do
		slots[k] = { x = startX + slotWidth*(k-1), y = 0, taken = {} }
		if k == 1 then
			print("slots start @", startX)
		end
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
		listY[lNum] = 2*tileSize/Camera.scale -- + math.random(2)
	end
	if rest > 0 then
		local lNum = #list+1
		list[lNum] = Visualizer:New( 'listCount' .. rest )
		list[lNum]:init()
		listX[lNum] = listStartX + tileSize*(lNum-1)/Camera.scale
		listY[lNum] = 2*tileSize/Camera.scale -- + math.random(2)
	end
	print("list starts @", listStartX)
	print("list data", num, full5, rest, images)
	
	return list, listX, listY -- return the images and the x and y positions
end

function pics:new( x, y, statType, num )
	print(x, y, statType, num)
	local newPic = { x=x, y=y,
					vis = {}, posX = {}, posY = {},
					list = {}, listPosX = {}, listPosY = {}}
					
	if statType == "fall" then
		local width = math.min(num*5, 45)
		local randomWidth = 3
		-- generate positions so that they overlap, but each position is unique:
		local freeSlots = generateSlots( num/2, width )
		newPic.slots = freeSlots
		local found = false
		local tries = 0
		
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
	elseif statType == "spikes" then
		local width = math.min(num*3, 45)
		local randomWidth = 3
		-- generate positions so that they overlap, but each position is unique:
		local freeSlots = generateSlots( num/2, width )
		newPic.slots = freeSlots
		local found = false
		local tries = 0
		
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
	end

	picList[#picList+1] = newPic
end

function pics:draw()
	local x,y
	for k,pic in pairs(picList) do
		for k = 1, #pic.vis do
			x = pic.x + pic.posX[k]
			y = pic.y + pic.posY[k]
			pic.vis[k]:draw( x*Camera.scale, y*Camera.scale )
		end
		for k = 1, #pic.list do
			x = pic.x + pic.listPosX[k]
			y = pic.y + pic.listPosY[k]
			pic.list[k]:draw( x*Camera.scale, y*Camera.scale )
		end
	end
	love.graphics.setColor(255,255,255)
end

return pics
