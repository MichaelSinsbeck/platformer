-- menu for Bandana

local menu = {active = false, text = '',images = {}}
local buttons = {}
local menuLines = {}
local menuImages = {}
local menuBackgrounds = {}
local selButton
local worldNames = {'the village', 'the forest', 'in the wall', 'on paper', 'the junkyard'}

local PADDING = 50		-- distance of buttons from edges

local startOff_IMG, startOn_IMG
local settingsOff_IMG, settingsOn_IMG
local exitOff_IMG, exitOn_IMG
local worldItemOff_IMG, worldItemOn_IMG, worldItemInactive_IMG
local creditsOff_IMG, creditsOn_IMG 
local background1_IMG
local background2_IMG
local background3_IMG
local background4_IMG
local background5_IMG

local menuPlayer = require("scripts/menuPlayer")
local credits = require("scripts/credits")

-- This function loads the images in the right scaling
function menu:init()
	local prefix = Camera.scale * 8
	self.images.logo_IMG = love.graphics.newImage("images/menu/"..prefix.."logo.png")

	self.images.startOff_IMG = love.graphics.newImage("images/menu/"..prefix.."startOff.png")
	self.images.startOn_IMG = love.graphics.newImage("images/menu/"..prefix.."startOn.png")
	self.images.settingsOff_IMG = love.graphics.newImage("images/menu/"..prefix.."settingsOff.png")
	self.images.settingsOn_IMG = love.graphics.newImage("images/menu/"..prefix.."settingsOn.png")
	self.images.exitOff_IMG = love.graphics.newImage("images/menu/"..prefix.."exitOff.png")
	self.images.exitOn_IMG = love.graphics.newImage("images/menu/"..prefix.."exitOn.png")
	self.images.creditsOff_IMG = love.graphics.newImage("images/menu/40creditsOff.png")
	self.images.creditsOn_IMG = love.graphics.newImage("images/menu/40creditsOn.png")

	self.images.worldItemOff_IMG = love.graphics.newImage("images/menu/"..prefix.."worldItemOff.png")
	self.images.worldItemOn_IMG = love.graphics.newImage("images/menu/"..prefix.."worldItemOn.png")
	self.images.worldItemInactive_IMG = love.graphics.newImage("images/menu/"..prefix.."worldItemInactive.png")

	self.images.background1_IMG = love.graphics.newImage("images/world/"..prefix.."world1.png")
	self.images.background2_IMG = love.graphics.newImage("images/world/"..prefix.."world2.png")
	self.images.background3_IMG = love.graphics.newImage("images/world/"..prefix.."world3.png")
	self.images.background4_IMG = love.graphics.newImage("images/world/"..prefix.."world4.png")
	self.images.background5_IMG = love.graphics.newImage("images/world/"..prefix.."world5.png")	
end

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
function menu:initMain()
	menuPlayer:init()
	self.xCamera = 0
	self.yCamera = 0
	self.xTarget = 0
	self.yTarget = 0

	menu:clear()	-- remove anything that was previously on the menu
	menu.state = "main"

	love.graphics.setBackgroundColor(40,40,40)
	

	local x,y
	x = -5
	y = 0
	
	local actionHover = menuPlayer:setDestination(x - 3, y + 5)
	local startButton = menu:addButton( x, y, 'startOff_IMG', 'startOn_IMG', "start", menu.initWorldMap, actionHover )
	y = y + 10
	
	actionHover = menuPlayer:setDestination(x - 3, y + 5)
	menu:addButton( x, y, 'settingsOff_IMG', 'settingsOn_IMG', "settings", nil, actionHover )
	
	y = y + 10
	actionHover = menuPlayer:setDestination(x - 3, y + 5)

	menu:addButton( x, y, 'creditsOff_IMG', 'creditsOn_IMG', "credits", menu.startCredits, actionHover )

	
	y = y + 10
	actionHover = menuPlayer:setDestination(x - 3, y + 5)
	menu:addButton( x, y, 'exitOff_IMG', 'exitOn_IMG', "exit", love.event.quit, actionHover )

	
	-- add main logo:
	x = - 85
	y = - 78
	table.insert(menuImages, {typ="img", img='logo_IMG', x=x, y=y})

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
	x = -1
	y = -30
	
	table.insert(menuBackgrounds, {typ="img", img='background1_IMG', x=x, y=y})
	
	x = x + 120
	table.insert(menuBackgrounds, {typ="img", img='background2_IMG', x=x, y=y})
	
	x = x + 120
	table.insert(menuBackgrounds, {typ="img", img='background3_IMG', x=x, y=y})
	
	x = x + 120
	table.insert(menuBackgrounds, {typ="img", img='background4_IMG', x=x, y=y})
	
	x = x + 120
	table.insert(menuBackgrounds, {typ="img", img='background5_IMG', x=x, y=y})	

	-- find out the last level that was beaten:
	local currentLevel = config.getValue("level")
	local lastLevel = config.getValue("lastLevel")
	local currentLevelFound = false
	local lastLevelFound = false
	local prevX, prevY
	local firstButton
	local dir = "right"
	local distBetweenButtons = 12

	local size = 5
	
	local actionHover

	if DEBUG then lastLevel = Campaign[#Campaign] end

	x, y = 0, 0
	
	for k, v in ipairs(Campaign) do

		local curButton
		-- add buttons until the current level is found:
		if not lastLevelFound then
			curButton = menu:addButton( x, y,
							'worldItemOff_IMG',
							'worldItemOn_IMG',
							v,
							menu:startGame( v ),
							scrollWorldMap )
		else
			table.insert(menuImages, {typ="img", img='worldItemInactive_IMG', x=x, y=y})
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
	menu.xTarget = math.floor((selButton.x)/120)*120+59
	menu.xCamera = menu.xTarget		
end

function scrollWorldMap()	--called when a button on world map is selected

	-- Create function which will set ninja coordinates. Then call that function:
	local func = menuPlayer:setDestination(selButton.x+5, selButton.y + 2)
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
-- Starts displaying the credits:
---------------------------------------------------------

function menu:startCredits()

	menu:clear()	-- remove anything that was previously on the menu
	menu.state = "credits"
	credits:init()
	
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
	new.ox = self.images[imgOff]:getWidth()*0.5/Camera.scale
	new.oy = self.images[imgOff]:getHeight()*0.5/Camera.scale
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
			local aDist = sDist( a.x, a.y, selButton.x, selButton.y - 10, "y" )
			local bDist = sDist( b.x, b.y, selButton.x, selButton.y - 10, "y" )
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
			local aDist = sDist( a.x, a.y, selButton.x, selButton.y + 10, "y" )
			local bDist = sDist( b.x, b.y, selButton.x, selButton.y + 10, "y" )
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
			local aDist = sDist( a.x, a.y, selButton.x - 10, selButton.y, "x" )
			local bDist = sDist( b.x, b.y, selButton.x - 10, selButton.y, "x" )
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
			local aDist = sDist( a.x, a.y, selButton.x + 10, selButton.y, "x" )
			local bDist = sDist( b.x, b.y, selButton.x + 10, selButton.y, "x" )
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
			if menu.state == "worldMap" then
				config.setValue( "level", selButton.name )
			end
			menu:initMain()
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
	
	if menu.state == "credits" then
		credits:update(dt)
	end

	for k, button in pairs(buttons) do
		if button.selected then
			-- Smooth movement of map - blockwise - 
			if menu.state == "worldMap" then 
				self.xTarget = math.floor((button.x)/120)*120+59
				self.worldNumber = math.floor(button.x/120)+1
			end
			
			if button.name == "settings" then
				button.timer = button.timer + dt
				button.angle = button.timer * 5
			elseif button.name == "start" then
				button.timer = button.timer + dt
				button.xShift = 1-2*math.abs(math.sin(5*button.timer))
				button.yScale = 1-0.1*math.abs(math.cos(5*button.timer))
				button.xScale = 1/button.yScale
			elseif button.name == "credits" then
				button.timer = button.timer + dt
				--button.xScale = 1-0.1*math.abs(math.cos(6*button.timer))
				button.yScale = button.xScale
				button.angle = math.sin(- button.timer * 6)
				button.yShift = 1-2*math.abs(math.sin(6*button.timer))
			elseif button.name == "exit" then
				button.timer = button.timer + dt
				button.yShift = 1-2*math.abs(math.sin(5*button.timer))
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
	love.graphics.translate(
		-math.floor(self.xCamera*Camera.scale)+love.graphics.getWidth()/2,
		-math.floor(self.yCamera*Camera.scale)+love.graphics.getHeight()/2)

  
	-- draw background elements:
	for k, element in pairs(menuBackgrounds) do
		love.graphics.draw( self.images[element.img], element.x*Camera.scale, element.y*Camera.scale )
	end
	love.graphics.setLineWidth(Camera.scale*0.4)
	for k, element in pairs(menuLines) do
		if element.active then
			love.graphics.setColor(0,0,0)
		else
			love.graphics.setColor(64,64,64)
		end
		love.graphics.line( element.x1*Camera.scale, element.y1*Camera.scale, element.x2*Camera.scale, element.y2 *Camera.scale)
	end
	love.graphics.setColor(255,255,255)
	for k, element in pairs(menuImages) do
		love.graphics.draw( self.images[element.img], element.x*Camera.scale, element.y*Camera.scale, alpha )
	end

	for k, button in pairs(buttons) do
		local angle = button.angle or 0
		local xShift = button.xShift or 0
		local yShift = button.yShift or 0
		local xScale = button.xScale or 1
		local yScale = button.yScale or 1
		if button.selected then
			love.graphics.draw( self.images[button.imgOn], 
				(button.x+button.ox+xShift)*Camera.scale, 
				(button.y+button.oy+yShift)*Camera.scale, 
				angle, xScale, yScale, 
				button.ox*Camera.scale, 
				button.oy*Camera.scale)
		else
			love.graphics.draw( self.images[button.imgOff], 
				(button.x+button.ox+xShift)*Camera.scale, 
				(button.y+button.oy+yShift)*Camera.scale, 
				angle, xScale, yScale, 
				button.ox*Camera.scale, 
				button.oy*Camera.scale)
		end
		--love.graphics.print(k, button.x, button.y )
	end
	if menu.state ~= "credits" then
		menuPlayer:draw()
	end
	love.graphics.pop()

	if menu.state == "worldMap" then
		love.graphics.setFont(fontLarge)
		love.graphics.setColor(0,0,0)
		love.graphics.printf(worldNames[menu.worldNumber], 0, love.graphics.getHeight()*0.5-Camera.scale*40, love.graphics.getWidth(), 'center')			
		love.graphics.setColor(255,255,255)
	end
	
	if menu.state == "credits" then
		credits:draw()
	else
		love.graphics.setFont(fontSmall)
		local y = love.graphics.getHeight()-Camera.scale*10
		local displayText = menu.text
		if menu.state == "worldMap" then
			love.graphics.setColor(0,0,0)
			y = love.graphics.getHeight()*0.5+Camera.scale*44
			if menu.text and Campaign.names[menu.text] then
				displayText = Campaign.names[menu.text]
			end
		end
	end
	--love.graphics.printf(displayText, 0, y, love.graphics.getWidth(), 'center')	
	love.graphics.setColor(255,255,255)	
	

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
