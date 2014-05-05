
---------------------------------------------------------
-- Display credits when it is selected from the menu.
---------------------------------------------------------

local credits = {}
local creditEntries = {}
local creditsDesign_IMG 
local creditsGraphics_IMG
local creditsProgramming_IMG 
local creditsMusic_IMG
local creditsNum = 1
local ct = 0
local coordinatesTop
local coordinatesBottom

function credits:update( dt )
	ct = ct + dt
	if creditsNum > #creditEntries then
		if ct > 1 then
			menu.startTransition(menu.initMain)()
		end
	else
		if ct > 5 then
			creditsNum = creditsNum + 1		-- go on to displaying the next credit entry
			ct = 0
		end
	end
end

function credits:draw()
	local x,y,scale
	
	love.graphics.setColor(44,90,160)
	love.graphics.rectangle("fill", 0, love.graphics.getHeight()/2 - AnimationDB.image[creditEntries[1].img]:getHeight()/2 , love.graphics.getWidth(), AnimationDB.image[creditEntries[1].img]:getHeight())

	-- Draw two lines
	love.graphics.setColor(0,0,0)
	love.graphics.line(coordinatesTop)
	love.graphics.line(coordinatesBottom)

	love.graphics.setColor(255,255,255)	
	y = love.graphics.getHeight()/2	- 11*Camera.scale
	if creditsNum <= #creditEntries then
		local img = AnimationDB.image[creditEntries[creditsNum].img]
		if ct < 1 then
			x = love.graphics.getWidth()/2 - math.max(12*ct*ct - 22*ct + 10, 0)/5*love.graphics.getWidth()
				- img:getWidth()
		else
			x = love.graphics.getWidth()/2 - img:getWidth()
		end
		love.graphics.draw(img, x, y)
		
		ct2 = ct - .1
		love.graphics.setFont(fontLarge)
		if ct2 < 1 then
			x = love.graphics.getWidth()/2 + math.max(12*ct2*ct2 - 22*ct2 + 10, 0)/5*love.graphics.getWidth()
		else
			x = love.graphics.getWidth()/2
		end
		love.graphics.print(creditEntries[creditsNum].title, x, y)
		
		
		ct3 = ct - 1
		love.graphics.setFont(fontSmall)
		if ct3 < 1 then
		x = love.graphics.getWidth()/2 + math.max(12*ct3*ct3 - 22*ct3 + 10, 0)/5*love.graphics.getWidth()
		else
			x = love.graphics.getWidth()/2
		end
		love.graphics.print(creditEntries[creditsNum].person, x + 30, y + 45)
	end
	
end

function credits:init( prefix )
	local prefix = Camera.scale * 8
		
	creditEntries[1] = {title = "idea & design", person = "micha", img = 'creditsDesign'}
	creditEntries[2] = {title = "graphics", person = "micha", img = 'creditsGraphics'}
	creditEntries[3] = {title = "programming", person = "micha\ngermanunkol", img = 'creditsProgramming'}
	
	creditEntries[4] = {title = "music & sound", person = "none", img = 'creditsMusic'}
	
	creditsNum = 1
	ct = 0
	
	local imax = math.floor(love.graphics.getWidth()/20)
	local dx = love.graphics.getWidth()/imax
	local top = love.graphics.getHeight()/2 - AnimationDB.image[creditEntries[1].img]:getHeight()/2
	local bottom = love.graphics.getHeight()/2 + AnimationDB.image[creditEntries[1].img]:getHeight()/2		
	
	coordinatesTop = {}
	coordinatesBottom = {}
	for i = 0,imax do
		table.insert(coordinatesTop, i*dx)
		table.insert(coordinatesTop, top + math.random()-math.random())
		table.insert(coordinatesBottom, i*dx)
		table.insert(coordinatesBottom, bottom + math.random()-math.random())
	end
	
	
end


return credits
