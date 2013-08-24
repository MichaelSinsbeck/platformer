
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

function credits:update( dt )
	ct = ct + dt
	if ct > 5 then
		creditsNum = creditsNum + 1		-- go on to displaying the next credit entry
		ct = 0
	end
end

function credits:draw()
	local x,y
	if creditsNum <= #creditEntries then
		if ct < 1 then
		x = love.graphics.getWidth()/2 - math.max(12*ct*ct - 22*ct + 10, 0)/5*love.graphics.getWidth()
				- creditEntries[creditsNum].img:getWidth()
		else
			x = love.graphics.getWidth()/2 - creditEntries[creditsNum].img:getWidth()
		end
		y = love.graphics.getHeight()/2	- creditEntries[creditsNum].img:getHeight()/2
		love.graphics.draw(creditEntries[creditsNum].img, x, y)
	end
end

function credits:init( prefix )
	local prefix = Camera.scale * 8
	creditsDesign_IMG = love.graphics.newImage("images/credits/"..prefix.."creditsDesign.png")
	creditsGraphics_IMG = love.graphics.newImage("images/credits/"..prefix.."creditsGraphics.png")
	creditsProgramming_IMG = love.graphics.newImage("images/credits/"..prefix.."creditsProgramming.png")
	creditsMusic_IMG = love.graphics.newImage("images/credits/"..prefix.."creditsMusic.png")
	
	creditEntries[1] = {title = "Idea & Design", person = "micha", img = creditsDesign_IMG}
	creditEntries[2] = {title = "Graphics", person = "micha", img = creditsGraphics_IMG}
	creditEntries[3] = {title = "Programming", person = "Micha & Germanunkol", img = creditsProgramming_IMG}
	creditEntries[4] = {title = "Music & Sound", person = "???", img = creditsMusic_IMG}
	
	creditsNum = 1
	ct = 0
end


return credits
