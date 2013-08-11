-- menu for Bandana

local menu = {active = false}
local buttons = {}
local menuLines = {}
local menuImages = {}
local selButton

local logo_IMG = love.graphics.newImage("images/menu/logo.png")

local startOff_IMG = love.graphics.newImage("images/menu/startOff.png")
local startOn_IMG = love.graphics.newImage("images/menu/startOn.png")
local settingsOff_IMG = love.graphics.newImage("images/menu/settingsOff.png")
local settingsOn_IMG = love.graphics.newImage("images/menu/settingsOn.png")
local exitOff_IMG = love.graphics.newImage("images/menu/exitOff.png")
local exitOn_IMG = love.graphics.newImage("images/menu/exitOn.png")

local worldItemOff_IMG = love.graphics.newImage("images/menu/worldItemOff.png")
local worldItemOn_IMG = love.graphics.newImage("images/menu/worldItemOn.png")
local worldItemInactive_IMG = love.graphics.newImage("images/menu/worldItemInactive.png")


function menu.clear()
	buttons = {}	-- clear all buttons from other menus
	menuImages = {}
	menuLines = {}
end

---------------------------------------------------------
-- Initialise the individual screens:
---------------------------------------------------------

-- creates main menu:
function menu:init()

	menu:clear()	-- remove anything that was previously on the menu

	love.graphics.setBackgroundColor(40,40,40)

	local x,y
	x = (love.graphics.getWidth() - startOff_IMG:getWidth())/2
	y = love.graphics.getHeight()/2
	local startButton = menu:addButton( x, y, startOff_IMG, startOn_IMG, "start", menu.initWorldMap )
	y = y + 50
	menu:addButton( x, y, settingsOff_IMG, settingsOn_IMG, "settings" )
	y = y + 50
	menu:addButton( x, y, exitOff_IMG, exitOn_IMG, "exit", love.event.quit)

	
	-- add main logo:
	x = love.graphics.getWidth()/2 - logo_IMG:getWidth()/2	-- center
	y = love.graphics.getHeight()/2 - 50 - logo_IMG:getHeight()
	table.insert(menuImages, {typ="img", img=logo_IMG, x=x, y=y})

	-- start of with the start button selected:
	selectButton(startButton)
end


-- creates world map menu:
function menu:initWorldMap()
	
	menu:clear()	-- remove anything that was previously on the menu
	

	-- find out the last level that was beaten:
	local currentLevel = config.getValue("level")
	local lastLevel = config.getValue("lastLevel")
	local currentLevelFound = false
	local lastLevelFound = false
	local prevX, prevY
	local firstButton
	local dir = "right"
	local distBetweenButtons = 50
	local padding = 50
	local x, y = padding, 70

	local size = worldItemOn_IMG:getWidth()/2

	if DEBUG then lastLevel = Campaign[#Campaign] end

	for k, v in ipairs(Campaign) do

		local curButton
		-- add buttons until the current level is found:
		if not lastLevelFound then
			curButton = menu:addButton( x, y, worldItemOff_IMG, worldItemOn_IMG, v, menu:startGame( v ))
		else
			table.insert(menuImages, {typ="img", img=worldItemInactive_IMG, x=x, y=y})
		end

		if prevX and prevY then
			table.insert(menuLines, {typ="line", x1=prevX+size, y1=prevY+size, x2=x+size, y2=y+size})
		end
		prevX, prevY = x,y

		if not currentLevel or v == currentLevel then
			if curButton then
				currentLevelFound = true
				selectButton( curButton )
			end
		end

		if not lastLevel or v == lastLevel then
			lastLevelFound = true
		end

		if not firstButton then
			firstButton = curButton
		end
		
		if dir == "right" then
			if x + distBetweenButtons < love.graphics.getWidth() - padding then
				x = x + distBetweenButtons
			else
				y = y + distBetweenButtons
				dir = "left"
			end
		elseif dir == "left" then
			if x - distBetweenButtons > padding then
				x = x - distBetweenButtons
			else
				y = y + distBetweenButtons
				dir = "right"
			end
		end

	end

	-- fallback:
	if not currentLevelFound and firstButton then
		-- start off with the first level selected:
		selectButton(firstButton)
	end

end


---------------------------------------------------------
-- Creates and returns an annonymous function
-- which will start the given level:
---------------------------------------------------------

function menu:startGame( lvl )

	local lvlNum = 1

	-- lvl is the filename, so find the corresponding index
	for k, v in ipairs(Campaign) do
		if v == lvl then
			lvlNum = k
			break
		end
	end

	return function ()
		initAll()
		-- Creating Player
		p = spriteFactory('player')
		--p = Player:New()
		--spriteEngine:insert(p)

		mode = 'game'
		gravity = 22

		Campaign.current = lvlNum

		myMap = Map:LoadFromFile( Campaign[Campaign.current] )
		myMap:start(p)
		
		config.setValue( "level", lvl )
	end
end


-- adds a new button to the list of buttons and then returns the new button
function menu:addButton( x,y,imgOff,imgOn,name,action )
	
	local new = {x=x, y=y, selected=selected, imgOff=imgOff, imgOn=imgOn, name=name}
	new.action = action
	table.insert(buttons, new)

	return new
end


---------------------------------------------------------
-- Selects next button towards the right, left, above and below
-- from the currently selected button, depending on distance:
---------------------------------------------------------

function menu:selectAbove()

	-- a button needs to be selected for the algorithm to work.
	if not selButton then
		selectButton(buttons[#buttons])
		return
	end


	-- sort list. Check which button is closest to the
	-- position 10 pixel to the top of the current button
	table.sort(buttons, function (a, b)
		if a.y < selButton.y and b.y < selButton.y then
			local aDist = sDist( a.x, a.y, selButton.x, selButton.y - 50, "y" )
			local bDist = sDist( b.x, b.y, selButton.x, selButton.y - 50, "y" )
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


function menu:selectBelow()
	-- a button needs to be selected for the algorithm to work.
	if not selButton then
		selectButton(buttons[#buttons])
		return
	end

	-- sort list. Check which button is closest to the
	-- position 10 pixel below of the current button
	table.sort(buttons, function (a, b)
		if a.y > selButton.y and b.y > selButton.y then
			local aDist = sDist( a.x, a.y, selButton.x, selButton.y + 50, "y" )
			local bDist = sDist( b.x, b.y, selButton.x, selButton.y + 50, "y" )
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


function menu:selectLeft()
	-- a button needs to be selected for the algorithm to work.
	if not selButton then
		selectButton(buttons[#buttons])
		return
	end

	-- sort list. Check which button is closest to the
	-- position 10 pixel below of the current button
	table.sort(buttons, function (a, b)
		if a.x < selButton.x and b.x < selButton.x then
			local aDist = sDist( a.x, a.y, selButton.x - 50, selButton.y, "x" )
			local bDist = sDist( b.x, b.y, selButton.x - 50, selButton.y, "x" )
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


function menu:selectRight()
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
			local aDist = sDist( a.x, a.y, selButton.x + 50, selButton.y, "x" )
			local bDist = sDist( b.x, b.y, selButton.x + 50, selButton.y, "x" )
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


---------------------------------------------------------
-- Runs function of current button when enter is pressed:
---------------------------------------------------------

function menu:execute()
	for k, button in pairs(buttons) do
		if button.selected then
			if button.action then
				button.action()
			end
			break
		end
	end
end

function menu:keypressed( key, unicode )
	if key == "up" or key == "w" then
		menu:selectAbove()
	elseif key == "down" or key == "s" then
		menu:selectBelow()
	elseif key == "left" or key == "a" then
		menu:selectLeft()
	elseif key == "right" or key == "d" then
		menu:selectRight()
	elseif key == "return" or key == " " then
		menu:execute()
	end
end


---------------------------------------------------------
-- Display menu on screen:
---------------------------------------------------------

function menu:draw()

	-- draw background elements:
	for k, element in pairs(menuImages) do
		love.graphics.draw( element.img, element.x, element.y )
	end
	for k, element in pairs(menuLines) do
		love.graphics.line( element.x1, element.y1, element.x2, element.y2 )
	end

	for k, button in pairs(buttons) do
		if button.selected then
			love.graphics.draw( button.imgOn, button.x, button.y )
		else
			love.graphics.draw( button.imgOff, button.x, button.y )
		end
		--love.graphics.print(k, button.x, button.y )
	end
end


---------------------------------------------------------
-- Misc functions:
---------------------------------------------------------

-- computes square of the distance between two points (for speed)
function sDist(x1, y1, x2, y2, preferred)
	if preferred == "x" then
		return (x1-x2)^2 + ((y1-y2)^2)*2
	else
		return ((x1-x2)^2)*2 + (y1-y2)^2
	end
end

function selectButton(button)
	selButton = button
	button.selected = true
	print ("Selected button: '" .. button.name .. "'")
end


return menu
