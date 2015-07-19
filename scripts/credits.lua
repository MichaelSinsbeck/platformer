
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
local active = false

function credits:update( dt )
	if not active then return end
	ct = ct + dt
	if ct > 5 then
		creditsNum = creditsNum + 1		-- go on to displaying the next credit entry
		ct = 0
	end
		
	if creditsNum > #creditEntries then
		menu:switchToSubmenu( "Main" )
		active = false
			--menu.startTransition(menu.initMain)()
	end
end

function credits:draw()
	if not active then return end
	love.graphics.origin()
	local x,y,scale
	
	love.graphics.setColor(44,90,160)
	love.graphics.rectangle("fill", 0, love.graphics.getHeight()/2 - 1.1*AnimationDB.image[creditEntries[1].img]:getHeight()/2 , love.graphics.getWidth(), 1.1*AnimationDB.image[creditEntries[1].img]:getHeight())

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

function credits:start() -- set timer back to zero and stuff
	active = true
	creditsNum = 1
	ct = 0
end

function credits:stop()
	active = false
end

function credits:init()
	local prefix = Camera.scale * 8
	
	creditEntries[1] = {title = "idea & design", person = "Michael Sinsbeck", img = 'creditsDesign'}
	creditEntries[2] = {title = "graphics", person = "Michael Sinsbeck\ngermanunkol", img = 'creditsGraphics'}
	creditEntries[3] = {title = "programming", person = "Michael Sinsbeck\ngermanunkol", img = 'creditsProgramming'}
	creditEntries[4] = {title = "music", person = "Max Ackermann", img = 'creditsMusic'}
	creditEntries[5] = {title = "sound", person = "Thomas Stoetzner\nMichael Sinsbeck\nLukas Nowok", img = 'creditsSound'}
	
	creditsNum = 1
	ct = 0
	
	local imax = math.floor(love.graphics.getWidth()/20)
	local dx = love.graphics.getWidth()/imax
	local top = love.graphics.getHeight()/2 - 1.1*AnimationDB.image[creditEntries[1].img]:getHeight()/2
	local bottom = love.graphics.getHeight()/2 + 1.1*AnimationDB.image[creditEntries[1].img]:getHeight()/2		
	
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
