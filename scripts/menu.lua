-- menu for Bandana

local menu = {active = false}
local buttons = {}
local selButton

local startOff_IMG = love.graphics.newImage("images/menu/startOff.png")
local startOn_IMG = love.graphics.newImage("images/menu/startOn.png")
local settingsOff_IMG = love.graphics.newImage("images/menu/settingsOff.png")
local settingsOn_IMG = love.graphics.newImage("images/menu/settingsOn.png")
local exitOff_IMG = love.graphics.newImage("images/menu/exitOff.png")
local exitOn_IMG = love.graphics.newImage("images/menu/exitOn.png")

function menu.init()
	local x,y
	x = (love.graphics.getWidth() - startOff_IMG:getWidth())/2
	y = love.graphics.getHeight()/2
	local startButton = menu.addButton( x, y, startOff_IMG, startOn_IMG, "start" )
	y = y + 50
	menu.addButton( x, y, settingsOff_IMG, settingsOn_IMG, "settings" )
	y = y + 50
	menu.addButton( x, y, exitOff_IMG, exitOn_IMG, "exit", love.event.quit)

	for i = 1, 20 do
		x = math.random(love.graphics.getWidth()/2) + love.graphics.getWidth()/4
		y = math.random(love.graphics.getHeight()/2)+ love.graphics.getHeight()/4
		menu.addButton( x, y, exitOff_IMG, exitOn_IMG, "exit", love.event.quit)
	end

	-- start of with the start button selected:
	selectButton(startButton)

	menu.active = true
end


-- adds a new button to the list of buttons and then returns the new button
function menu.addButton( x,y,imgOff,imgOn,name,action )
	
	local new = {x=x, y=y, selected=selected, imgOff=imgOff, imgOn=imgOn, name=name}
	new.action = action
	for k, v in pairs(new) do
		print(k, v)
	end
	table.insert(buttons, new)

	return new
end


-- computes square of the distance between two points (for speed)
function sDist(x1, y1, x2, y2)
	return (x1-x2)^2 + (y1-y2)^2
end

function selectButton(button)
	selButton = button
	button.selected = true
end

function menu.selectAbove()

	-- a button needs to be selected for the algorithm to work.
	if not selButton then
		selectButton(buttons[#buttons])
		return
	end


	-- sort list. Check which button is closest to the
	-- position 10 pixel to the top of the current button
	table.sort(buttons, function (a, b)
		if a.y < selButton.y and b.y < selButton.y then
			local aDist = sDist( a.x, a.y, selButton.x, selButton.y - 50 )
			local bDist = sDist( b.x, b.y, selButton.x, selButton.y - 50 )
			return aDist < bDist
		end
		if a.y < b.y then
			return true
		else
			return false
		end
	end)

	selButton.selected = false
	selectButton(buttons[1])
end


function menu.selectBelow()
	-- a button needs to be selected for the algorithm to work.
	if not selButton then
		selectButton(buttons[#buttons])
		return
	end

	-- sort list. Check which button is closest to the
	-- position 10 pixel below of the current button
	table.sort(buttons, function (a, b)
		if a.y > selButton.y and b.y > selButton.y then
			local aDist = sDist( a.x, a.y, selButton.x, selButton.y + 50 )
			local bDist = sDist( b.x, b.y, selButton.x, selButton.y + 50 )
			return aDist < bDist
		end
		if a.y > b.y then
			return true
		else
			return false
		end
	end)

	selButton.selected = false
	selectButton(buttons[1])
end


function menu.selectLeft()
	-- a button needs to be selected for the algorithm to work.
	if not selButton then
		selectButton(buttons[#buttons])
		return
	end

	-- sort list. Check which button is closest to the
	-- position 10 pixel below of the current button
	table.sort(buttons, function (a, b)
		if a.x < selButton.x and b.x < selButton.x then
			local aDist = sDist( a.x, a.y, selButton.x - 50, selButton.y )
			local bDist = sDist( b.x, b.y, selButton.x - 50, selButton.y )
			return aDist < bDist
		end
		if a.x < b.x then
			return true
		else
			return false
		end
	end)

	selButton.selected = false
	selectButton(buttons[1])
end


function menu.selectRight()
	-- a button needs to be selected for the algorithm to work.
	if not selButton then
		selectButton(buttons[#buttons])
		return
	end

nextX, nextY = selButton.x+10, selButton.y
	-- sort list. Check which button is closest to the
	-- position 10 pixel right of the current button
	table.sort(buttons, function (a, b)
		if a.x > selButton.x and b.x > selButton.x then
			local aDist = sDist( a.x, a.y, selButton.x + 50, selButton.y )
			local bDist = sDist( b.x, b.y, selButton.x + 50, selButton.y )
			return aDist < bDist
		end
		if a.x > b.x then
			return true
		else
			return false
		end
	end)

	selButton.selected = false
	selectButton(buttons[1])
end

function menu.execute()
	for k, button in pairs(buttons) do
		if button.selected then
			if button.action then
				button.action()
			end
			break
		end
	end
end

function menu.keypressed( key, unicode )
	if key == "up" or key == "w" then
		menu.selectAbove()
	elseif key == "down" or key == "s" then
		menu.selectBelow()
	elseif key == "left" or key == "a" then
		menu.selectLeft()
	elseif key == "right" or key == "d" then
		menu.selectRight()
	elseif key == "return" or key == " " then
		menu.execute()
	end
end

function menu.draw()
	for k, button in pairs(buttons) do
		print(k, button)
		if button.selected then
			love.graphics.draw( button.imgOn, button.x, button.y )
		else
			love.graphics.draw( button.imgOff, button.x, button.y )
		end
		love.graphics.print(k, button.x, button.y )
	end
end

return menu
