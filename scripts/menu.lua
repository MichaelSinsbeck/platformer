-- menu for Bandana

local menu = {active = false, cameraSpeed = 1000, text = ''}
local buttons = {}
local menuLines = {}
local menuImages = {}
local menuBackgrounds = {}
local selButton
local worldNames = {'the village', 'the forest', 'in the wall', 'on paper', 'the junkyard'}

local PADDING = 50		-- distance of buttons from edges

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

local background1_IMG = love.graphics.newImage("images/world/world1.png")
local background2_IMG = love.graphics.newImage("images/world/world2.png")
local background3_IMG = love.graphics.newImage("images/world/world3.png")
local background4_IMG = love.graphics.newImage("images/world/world4.png")
local background5_IMG = love.graphics.newImage("images/world/world5.png")

local menuPlayer = require("scripts/menuPlayer")

function menu.clear()
	buttons = {}	-- clear all buttons from other menus
	menuImages = {}
	menuBackgrounds = {}
	menuLines = {}
end

---------------------------------------------------------
-- Initialise the individual screens:
---------------------------------------------------------

-- creates main menu:
function menu:init()
	menuPlayer:init()
	self.xCamera = 0
	self.yCamera = 0
	self.xTarget = 0
	self.yTarget = 0

	menu:clear()	-- remove anything that was previously on the menu
	menu.state = "main"

	love.graphics.setBackgroundColor(40,40,40)
	

	local x,y
	x = (love.graphics.getWidth() - startOff_IMG:getWidth())/2
	y = love.graphics.getHeight()/2
	
	local actionHover = menuPlayer:setDestination(x - 15, y + 25)
	local startButton = menu:addButton( x, y, startOff_IMG, startOn_IMG, "start", menu.initWorldMap, actionHover )
	y = y + 50
	
	actionHover = menuPlayer:setDestination(x - 15, y + 25)
	menu:addButton( x, y, settingsOff_IMG, settingsOn_IMG, "settings", nil, actionHover )
	
	y = y + 50
	actionHover = menuPlayer:setDestination(x - 15, y + 25)
	menu:addButton( x, y, exitOff_IMG, exitOn_IMG, "exit", love.event.quit, actionHover )

	
	-- add main logo:
	x = love.graphics.getWidth()/2 - logo_IMG:getWidth()/2	-- center
	y = love.graphics.getHeight()/2 - 50 - logo_IMG:getHeight()
	table.insert(menuImages, {typ="img", img=logo_IMG, x=x, y=y})

	-- start of with the start button selected:
	selectButton(startButton)
	
	menuPlayer:reset()
end


-- creates world map menu:
function menu.initWorldMap()
	menuPlayer:init()
	
	menu:clear()	-- remove anything that was previously on the menu
	menu.state = "worldMap"
	
	--love.graphics.setBackgroundColor(40,40,40)	
	love.graphics.setBackgroundColor(80,150,205)
	
	-- add world background images:
	local x,y
	--x = (love.graphics.getWidth() - background1_IMG:getWidth())/2
	x = -5
	y = (love.graphics.getHeight() - background1_IMG:getHeight())/2
	
	table.insert(menuBackgrounds, {typ="img", img=background1_IMG, x=x, y=y})
	
	x = x + (background1_IMG:getWidth() + background2_IMG:getWidth())/2
	table.insert(menuBackgrounds, {typ="img", img=background2_IMG, x=x, y=y})
	
	x = x + (background2_IMG:getWidth() + background3_IMG:getWidth())/2
	table.insert(menuBackgrounds, {typ="img", img=background3_IMG, x=x, y=y})
	
	x = x + (background3_IMG:getWidth() + background4_IMG:getWidth())/2
	table.insert(menuBackgrounds, {typ="img", img=background4_IMG, x=x, y=y})
	
	x = x + (background4_IMG:getWidth() + background5_IMG:getWidth())/2
	table.insert(menuBackgrounds, {typ="img", img=background5_IMG, x=x, y=y})	

	-- find out the last level that was beaten:
	local currentLevel = config.getValue("level")
	local lastLevel = config.getValue("lastLevel")
	local currentLevelFound = false
	local lastLevelFound = false
	local prevX, prevY
	local firstButton
	local dir = "right"
	local distBetweenButtons = 60

	local size = worldItemOn_IMG:getWidth()/2
	
	local actionHover

	if DEBUG then lastLevel = Campaign[#Campaign] end

	x, y = 0, love.graphics.getHeight()/2
	
	for k, v in ipairs(Campaign) do

		local curButton
		-- add buttons until the current level is found:
		if not lastLevelFound then
			curButton = menu:addButton( x, y,
							worldItemOff_IMG,
							worldItemOn_IMG,
							v,
							menu:startGame( v ),
							scrollWorldMap )
		else
			table.insert(menuImages, {typ="img", img=worldItemInactive_IMG, x=x, y=y})
		end

		if prevX and prevY then
			if lastLevelFound then
				table.insert(menuLines, {typ="line", x1=prevX+size, y1=prevY+size, x2=x+size, y2=y+size})
			else
				table.insert(menuLines, {typ="line", x1=prevX+size, y1=prevY+size, x2=x+size, y2=y+size, active = true})
			end
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
			--if x + distBetweenButtons < love.graphics.getWidth() - PADDING then
				x = x + distBetweenButtons
			--else
			--	y = y + distBetweenButtons
			--	dir = "left"
			--end
		elseif dir == "left" then
			if x - distBetweenButtons > PADDING then
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
	
	-- set camera position
	menu.xTarget = math.floor((selButton.x)/600)*600+300-love.graphics.getWidth()/2
	menu.xCamera = menu.xTarget		
end

function scrollWorldMap()	--called when a button on world map is selected
	
	
	--[[if selButton.x > love.graphics.getWidth() - PADDING then
		for k, v in pairs(buttons) do
			if v.imgOff == worldItemOff_IMG then		--find all world button images
				v.x = v.x - love.graphics.getWidth()	-- move all level buttons to the right
			end
		end
		for k, v in pairs(menuBackgrounds) do	-- move all background images
			v.x = v.x - love.graphics.getWidth()
		end
		for k, v in pairs(menuImages) do	-- move all background images
			v.x = v.x - love.graphics.getWidth()
		end
		for k, v in pairs(menuLines) do		-- move all background lines
			v.x1 = v.x1 - love.graphics.getWidth()
			v.x2 = v.x2 - love.graphics.getWidth()
		end
	end
	
	while selButton.x < 0 do
		for k, v in pairs(buttons) do
			if v.imgOff == worldItemOff_IMG then		--find all world button images
				v.x = v.x + love.graphics.getWidth()	-- move all level buttons to the left
			end
		end
		for k, v in pairs(menuImages) do	-- move all background images
			v.x = v.x + love.graphics.getWidth()
		end
		for k, v in pairs(menuLines) do		-- move all background lines
			v.x1 = v.x1 + love.graphics.getWidth()
			v.x2 = v.x2 + love.graphics.getWidth()
		end
	end
	--]]
	-- Create function which will set ninja coordinates. Then call that function:
	local func = menuPlayer:setDestination(selButton.x+25, selButton.y + 10)
	func()
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

---------------------------------------------------------
-- adds a new button to the list of buttons and then returns the new button
---------------------------------------------------------

function menu:addButton( x,y,imgOff,imgOn,name,action,actionHover )
	
	local new = {x=x,
				y=y,
				selected=selected,
				imgOff=imgOff,
				imgOn=imgOn,
				name=name,
				action=action,
				actionHover=actionHover,
				timer = 0
			}
	new.ox = imgOff:getWidth()*0.5
	new.oy = imgOff:getHeight()*0.5
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

	-- turn around player if moving to the left
	if selButton.x > buttons[1].x then
		menuPlayer.scaleX = -1
	end
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

	-- turn around player if moving to the right
	if selButton.x < buttons[1].x then
		menuPlayer.scaleX = 1
	end
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
	elseif key == "escape" then
		if menu.state == "main" then
			love.event.quit()
		else
			config.setValue( "level", selButton.name )			
			menu:init()
		end
	end
end


---------------------------------------------------------
-- Animate ninja and buttons:
---------------------------------------------------------

function menu:update(dt)
	menuPlayer:update(dt/2)
	
	-- smooth movement, always on player
	--[[if menuPlayer.x - self.xTarget > love.graphics.getWidth() - PADDING then
		self.xTarget = menuPlayer.x + PADDING - love.graphics.getWidth()
	end
	if menuPlayer.x - self.xTarget < PADDING then
		self.xTarget = menuPlayer.x - PADDING
	end--]] 
	
	self.xCamera = self.xCamera + 0.05 * (self.xTarget- self.xCamera)
	

	for k, button in pairs(buttons) do
		if button.selected then
			-- Smooth movement of map - blockwise - 
			if menu.state == "worldMap" then 
				self.xTarget = math.floor((button.x)/600)*600+300-love.graphics.getWidth()/2
				self.worldNumber = math.floor(button.x/600)+1
			end
			
			if button.name == "settings" then
				button.timer = button.timer + dt
				button.angle = button.timer * 5
			elseif button.name == "start" then
				button.timer = button.timer + dt
				button.xShift = 5-10*math.abs(math.sin(5*button.timer))
				button.yScale = 1-0.1*math.abs(math.cos(5*button.timer))
				button.xScale = 1/button.yScale
			elseif button.name == "exit" then
				button.timer = button.timer + dt
				button.yShift = 5-10*math.abs(math.sin(5*button.timer))
				button.xScale = 1-0.05*math.abs(math.cos(5*button.timer))
				button.yScale = 1/button.xScale			
			end
		end
	end
end

---------------------------------------------------------
-- Display menu on screen:
---------------------------------------------------------

function menu:draw()

	love.graphics.push()
  love.graphics.translate(-math.floor(self.xCamera),-math.floor(self.yCamera))
  
	-- draw background elements:
	for k, element in pairs(menuBackgrounds) do
		love.graphics.draw( element.img, element.x, element.y )
	end
	love.graphics.setLineWidth(2)
	for k, element in pairs(menuLines) do
		if element.active then
			love.graphics.setColor(0,0,0)
		else
			love.graphics.setColor(64,64,64)
		end
		love.graphics.line( element.x1, element.y1, element.x2, element.y2 )
	end
	love.graphics.setColor(255,255,255)
	for k, element in pairs(menuImages) do
		love.graphics.draw( element.img, element.x, element.y, alpha )
	end

	for k, button in pairs(buttons) do
		local angle = button.angle or 0
		local xShift = button.xShift or 0
		local yShift = button.yShift or 0
		local xScale = button.xScale or 1
		local yScale = button.yScale or 1
		if button.selected then
			love.graphics.draw( button.imgOn, button.x+button.ox+xShift, button.y+button.oy+yShift, angle, xScale, yScale, button.ox, button.oy)
		else
			love.graphics.draw( button.imgOff, button.x+button.ox+xShift, button.y+button.oy+yShift, angle, xScale, yScale, button.ox, button.oy )
		end
		--love.graphics.print(k, button.x, button.y )
	end
	
	menuPlayer:draw()
	
	love.graphics.pop()
--	love.graphics.print(menu.text,400,100)
	love.graphics.setFont(fontSmall)
	local y = love.graphics.getHeight()-50
	if menu.state == "worldMap" then
		love.graphics.setColor(0,0,0)
		y = love.graphics.getHeight()*0.5+170
	end
	love.graphics.printf(menu.text, 0, y, love.graphics.getWidth(), 'center')	
	love.graphics.setColor(255,255,255)
	
	if menu.state == "worldMap" then
		love.graphics.setFont(fontLarge)
		love.graphics.setColor(0,0,0)
		love.graphics.printf(worldNames[menu.worldNumber], 0, love.graphics.getHeight()*0.5-200, love.graphics.getWidth(), 'center')			
		love.graphics.setColor(255,255,255)
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
	--print ("Selected button: '" .. button.name .. "'")
	menu.text = button.name
	if selButton.actionHover then
		selButton.actionHover()
	end
end


return menu
