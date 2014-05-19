-- menu for Bandana

local menu = {active = false, text = '',images = {}, bandanas = {}}

local TRANSITION_SPEED = 50
local LEVEL_NAME_DISPL_TIME = 4

local buttons = {}
local menuLines = {}
local menuImages = {}
local menuBackgrounds = {}
local menuTexts = {}
local menuBoxes = {}
local menuLogs = {}
local selButton
local worldNames = {'the village', 'the forest', 'in the wall', 'on paper', 'the junkyard'}

--local PADDING = 50		-- distance of buttons from edges

local dWorld = 170
local nLogs = 8
local distBetweenButtons = 10
local levelsPerWorld = 15
local distBetweenWorlds = dWorld-levelsPerWorld*distBetweenButtons

menuPlayer = {}
local credits = require("scripts/credits")

-- This function loads the images in the right scaling
function menu:init()
	menu:loadTransitionImages()
	menu.curLevelName = nil

	menuPlayer.vis = Visualizer:New("whiteWalk")	--require("scripts/menuPlayer")
	--menuPlayer.x = 0
	--menuPlayer.y = 0
	menuPlayer.vis:init()
	
	controlKeys:setup() -- make sure to display the correct keys!
	
	menu.bandanas = {}
	for i = 0,4 do
		local newLine = {}
	  for x = 0,1280,10 do
	    local y = math.sin(math.pi*x/150)
	    newLine[#newLine+1] = x+math.random()-math.random()
			newLine[#newLine+1] = -2*Camera.scale*y+(i+.5)*Camera.scale*40+math.random()-math.random()
	  end
	  menu.bandanas[#menu.bandanas+1] = newLine
	end

	-- resize any bamboo Boxes if necessary:
	for k, element in pairs(menuBoxes) do
		element.box = BambooBox:new( "", element.box.width, element.box.height )
	end
end

function menu:getImage( imgName )
	return AnimationDB.image[imgName]
end

function menu.clear()
	mode = 'menu'
	buttons = {}	-- clear all buttons from other menus
	menuImages = {}
	menuBackgrounds = {}
	menuLines = {}
	menuTexts = {}
	menuBoxes = {}
	menuLogs = {}	
end

---------------------------------------------------------
-- Initialise the individual screens:
---------------------------------------------------------

-- creates main menu:
function menu.initMain()
	menu.xCamera = 0
	menu.yCamera = 0
	menu.xTarget = 0
	menu.yTarget = 0

	menu:clear()	-- remove anything that was previously on the menu
	menu.state = "main"

	editor.active = false

	--love.graphics.setBackgroundColor(40,40,40)
	love.graphics.setBackgroundColor(22,45,80)

	local x,y
	x = -3
	--x = -52
	y = -10
	
	menu:addBox(x-21,y-7,48,64)
	
	local actionHover = menu.setPlayerPosition( x - 4, y + 5 )
	local startButton = menu:addButton( x, y, 'startOff', 'startOn', "start", menu.startTransition(menu.initWorldMap, true), actionHover )
	--local startButton = menu:addButtonAnimated( x, y, 'startOff', 'startOn', "start", menu.startTransition(menu.initWorldMap), actionHover )
	y = y + 10
	
	actionHover = menu.setPlayerPosition( x - 4, y + 5 )
	menu:addButton( x, y, 'settingsOff', 'settingsOn', "settings", menu.startTransition(settings.init, false), actionHover )
	y = y + 10
	
	actionHover = menu.setPlayerPosition( x - 4, y + 5 )
	menu:addButton( x, y, 'editorOff', 'editorOn', "level editor", menu.startTransition( editor.start, true), actionHover )
	y = y + 10

	actionHover = menu.setPlayerPosition( x - 4, y + 5 )
	menu:addButton( x, y, 'creditsOff', 'creditsOn', "credits", menu.startTransition(menu.startCredits, false), actionHover )
	y = y + 10
	
	actionHover = menu.setPlayerPosition( x - 4, y + 5 )
	menu:addButton( x, y, 'exitOff', 'exitOn', "exit", menu.startTransition(love.event.quit), actionHover )

	
	-- add main logo:
	x = - 85
	y = - 78
	table.insert(menuImages, {typ="img", img='logo', x=x, y=y})
	

	-- start of with the start button selected:
	selectButton(startButton)
	
	menuPlayer.vis:setAni("whiteWalk")
	menuPlayer.vis.sx = 1

	menu.curLevelName = nil	-- don't display level name when entering menu
end

function menu.setPlayerPosition( x, y )
	return function()
		menuPlayer.x = x
		menuPlayer.y = y
	end
end

local function scrollWorldMap()	--called when a button on world map is selected
	menu.xTarget = math.floor((selButton.x)/dWorld)*dWorld+75 -- set Camera position
	Campaign.worldNumber = math.floor(selButton.x/dWorld)+1 -- calculate worldNumber
	
	-- Create function which will set ninja coordinates. Then call that function:
	local func = menu.setPlayerPosition( selButton.x+5, selButton.y+2 )
	--menuPlayer.vis:setAni("whiteWalk")
	func()
end
-- creates world map menu:
function menu.initWorldMap()
	
	menu:clear()	-- remove anything that was previously on the menu
	menu.state = "worldMap"
	
	--love.graphics.setBackgroundColor(40,40,40)	
	love.graphics.setBackgroundColor(80,150,205)
	
	-- add world background images:
	local x,y
	x = -5
	y = -30
	
	table.insert(menuBackgrounds, {typ="img", img='world1', x=x, y=y})
	
	x = x + dWorld
	table.insert(menuBackgrounds, {typ="img", img='world2', x=x, y=y})
	
	x = x + dWorld
	table.insert(menuBackgrounds, {typ="img", img='world3', x=x, y=y})
	
	x = x + dWorld
	table.insert(menuBackgrounds, {typ="img", img='world4', x=x, y=y})
	
	x = x + dWorld
	table.insert(menuBackgrounds, {typ="img", img='world5', x=x, y=y})	

	-- find out the last level that was beaten:
	local currentLevel = config.getValue("level")
	local lastLevel = config.getValue("lastLevel") or Campaign[1]
	local currentLevelFound = false
	local lastLevelFound = false
	local prevX, prevY
	local firstButton
	--local dir = "right"
	
	local size = 5
	
	local actionHover

	if DEBUG then lastLevel = Campaign[#Campaign] end

	local x, y = 0, 0
	
	menu.furthestX = 0		-- will save x value of farthest button
	
	for k, v in ipairs(Campaign) do

		local curButton
		-- add buttons until the current level is found:
		if not lastLevelFound then
			curButton = menu:addButton( x, y,
							'worldItemOff',
							'worldItemOn',
							v,
							menu.startTransition(menu.startCampaignLevel( k ), true),
							scrollWorldMap )
			if x > menu.furthestX then
				menu.furthestX = x
			end
		else
			table.insert(menuImages, {typ="img", img='worldItemInactive', x=x, y=y})
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
			Campaign.last = math.max(Campaign.last,k)
		end

		if not firstButton then
			firstButton = curButton
		end
		
		x = x + distBetweenButtons
		
		-- after last level of each world
		if k/levelsPerWorld == math.floor(k/levelsPerWorld) then
			wx = x + 3
			for i = 1,nLogs do
				local thisVis = Visualizer:New('log')
				thisVis:init()
				if lastLevelFound then
					thisVis.sx = 0
					thisVis.sy = 0
				end
				local wy = y + 5 - math.sin(math.pi * (i-1)/(nLogs-1))				
				table.insert(menuLogs, {vis = thisVis, x = wx, y = wy})
				wx = wx + 2.1
			end
			
			x = x + distBetweenWorlds
		end

	end

	-- fallback:
	if not currentLevelFound and firstButton then
		-- start off with the first level selected:
		selectButton(firstButton)
	end
	
	-- set camera position
	menu.xTarget = math.floor((selButton.x)/dWorld)*dWorld+75
	menu.xCamera = menu.xTarget
end

-- remove one menu-image and add one button, called when new world is reached
function menu.AddOneWorldMap()
	table.remove(menuImages, 1)
	
	local v = Campaign[Campaign.current]
	local x = (Campaign.current-1) * distBetweenButtons + Campaign.worldNumber * distBetweenWorlds
	local y = 0
	
	menu:addButton( x, y,
		'worldItemOff',
		'worldItemOn',
		v,
		menu.startTransition(menu.startGame( "levels/" .. v ), true),
		scrollWorldMap )
	if x > menu.furthestX then
		menu.furthestX = x
	end

	menuLines[Campaign.current-1].active = true
end


---------------------------------------------------------
-- Creates and returns an annonymous function
-- which will start the given level:
---------------------------------------------------------

function menu.startCampaignLevel( lvlNum )
	local lvl = "levels/" .. Campaign[lvlNum]
	return function()
		initAll()
		Campaign.current = lvlNum		
		p = spriteFactory('Player')
		mode = 'game'
		gravity = 22
		--Campaign.current = lvlNum
		myMap = Map:loadFromFile( lvl )
		levelEnd:reset()		-- resets the counters of all deaths etc
		myMap:start(p)
		config.setValue( "level", lvl )
	end
end

function menu.startGame( lvl )
	return function ()
		initAll()
		p = spriteFactory('Player')
		mode = 'game'
		gravity = 22
		--Campaign.current = lvlNum
		myMap = Map:loadFromFile( lvl )
		levelEnd:reset()		-- resets the counters of all deaths etc
		myMap:start(p)		
		config.setValue( "level", lvl )
	end
end

function menu:newLevelName( txt, noCampaignName )
	local level = Campaign.current
	local world = math.ceil(level/15)
	local innerlvl = (level-1) % 15 + 1
	if noCampaignName then
		menu.curLevelName = txt
	else
		menu.curLevelName = world .. ' - ' .. innerlvl .. ' : ' .. txt
	end
	menu.levelNameTime = 0
	menu.levelNameWidth = fontLarge:getWidth(menu.curLevelName)
	menu.levelNameBox = menu:generateBox(0.5*(Camera.width-menu.levelNameWidth)-2*Camera.scale,0,menu.levelNameWidth+4*Camera.scale,fontLarge:getHeight()*1.1,1/Camera.scale)
end

function menu:updateLevelName( dt )
	menu.levelNameTime = menu.levelNameTime + dt
	if menu.levelNameTime >= LEVEL_NAME_DISPL_TIME then
		menu.curLevelName = nil
	end
end

function menu:drawLevelName()
	love.graphics.setFont( fontLarge )
	local y = 50
	local time = (menu.levelNameTime - 0.8*LEVEL_NAME_DISPL_TIME)/0.8
	if time > 0 then
		y = 50 - math.pow( time, 4)*(fontLarge:getHeight()+100)
	end
	love.graphics.push()
	love.graphics.translate(0,y)

	love.graphics.setColor(44,90,160)
	love.graphics.rectangle('fill',0.5*(Camera.width-menu.levelNameWidth)-2*Camera.scale,0,menu.levelNameWidth+4*Camera.scale,fontLarge:getHeight()*1.1)
	
	love.graphics.setColor(0,0,0)
	love.graphics.setLineWidth(Camera.scale * 0.5)
	love.graphics.line(menu.levelNameBox.points)
	
	love.graphics.setColor(255,255,255)
	love.graphics.printf( menu.curLevelName, 0, fontLarge:getHeight()*0.05 , love.graphics.getWidth(), 'center')
	
	
	love.graphics.pop()
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
				timer = 0,
				angle = 0,
			}
	new.ox = AnimationDB.image[imgOff]:getWidth()*0.5/Camera.scale
	new.oy = AnimationDB.image[imgOff]:getHeight()*0.5/Camera.scale
	table.insert(buttons, new)

	return new
end
function menu:addButtonAnimated( x,y,imgOff,imgOn,name,action,actionHover, scaleX, scaleY )
	
	local new = {x=x,
				y=y,
				selected=selected,
				vis=Visualizer:New(imgOff),
				animationOff = imgOff,
				animationOn = imgOn,
				name=name,
				action=action,
				actionHover=actionHover,
				animated = true
			}
	new.ox = Camera.scale*8*0.5
	new.oy = Camera.scale*8*0.5
	new.vis:init()
	new.vis:update(0)
	
	if scaleX then
		new.vis.sx = scaleX
	end
	if scaleY then
		new.vis.sy = scaleY
	end
	
	table.insert(buttons, new)

	return new
end
-- add a button that displays a label (for key assignment)
function menu:addButtonLabeled( x,y,imgOff,imgOn,name,action,actionHover,label,font )
	
	if label == " " then
		label = "space"
	end
	
	local new = {x=x,
				y=y,
				selected=selected,
				imgOff=imgOff,
				imgOn=imgOn,
				name=name,
				action=action,
				actionHover=actionHover,
				timer = 0,
				font=font,
				label=label
			}
	--new.ox = AnimationDB.image[imgOff]:getWidth()*0.5/Camera.scale
	--new.oy = AnimationDB.image[imgOff]:getHeight()*0.5/Camera.scale
	new.ox = 0
	new.oy = 0
	
	new.labelX = (AnimationDB.image[imgOff]:getWidth() - _G[font]:getWidth(label))*0.5/Camera.scale
	table.insert(buttons, new)

	return new
end

function menu:addText( x, y, index, str )
	menuTexts[index] = {txt = str, x=x, y=y}
end

function menu:changeText( index, str )
	menuTexts[index].txt = str
end

function menu:changeButtonImage( name, imageOff, imageOn )
	for k, b in pairs(buttons) do
		if b.name == name then
			b.imgOff = imageOff or b.imgOff
			b.imgOn = imageOn or b.imgOn
			if b.label then
				b.labelX = (AnimationDB.image[b.imgOff]:getWidth()
						- _G[b.font]:getWidth(b.label))*0.5/Camera.scale
			end
			break
		end
	end
end

function menu:changeButtonLabel( name, label )
	for k, b in pairs(buttons) do
		if b.name == name then
			b.label = label
			b.labelX = (AnimationDB.image[b.imgOff]:getWidth()
						- _G[b.font]:getWidth(b.label))*0.5/Camera.scale
			break
		end
	end
end

function menu:generateBox(left,top,width,height,boxFactor)
	local boxFactor = boxFactor or 1
	local new = {}
	new.points = {}
	new.left = left
	new.top = top
	new.width = width
	new.height = height
	local index = 1
	local stepsize = 0
	table.insert(new.points, left)
	table.insert(new.points, top)
	for i = 1,math.floor(boxFactor*.2*width) do
		stepsize = width/math.floor(boxFactor*.2*width)
		table.insert(new.points, left + i*stepsize)
		table.insert(new.points, top)
	end
	
	for i = 1,math.floor(boxFactor*.2*height) do
		stepsize = height/math.floor(boxFactor*.2*height)
		table.insert(new.points, left+width)
		table.insert(new.points, top + i*stepsize)
	end
	
	for i = 1,math.floor(boxFactor*.2*width) do
		stepsize = width/math.floor(boxFactor*.2*width)
		table.insert(new.points, left + width - i*stepsize)
		table.insert(new.points, top + height)
	end
		
	for i = 1,math.floor(boxFactor*.2*height) do
		stepsize = height/math.floor(boxFactor*.2*height)
		table.insert(new.points, left)
		table.insert(new.points, top + height - i*stepsize)
	end
	
	for i = 1,#new.points-2 do
		new.points[i] = new.points[i] + 0.4/boxFactor*math.random() - 0.4/boxFactor*math.random()
	end
	new.points[#new.points-1] = new.points[1]
	new.points[#new.points] = new.points[2]

	return new
end

function menu:addBox(left,top,width,height)
	--table.insert(menuBoxes, menu:generateBox(left,top,width,height))
	table.insert( menuBoxes, { x = left, y = top, box = BambooBox:new( "", width, height ) } )
end

-- changes scales of Logs, if existant
function menu:easeLogs(t)
	for k,log in ipairs(menuLogs) do
		if k > (Campaign.worldNumber-1) * nLogs and k <= Campaign.worldNumber * nLogs then
			local i = k - Campaign.worldNumber * nLogs -1
			local tEase = t-(i-1)/(nLogs-1)-1
			log.vis.sx = self.easing(tEase)
			log.vis.sy = log.vis.sx
		end
	end
end

-- simple easing function with "overshoot"
function menu.easing(t)
	if t <= 0 then
		return 0
	elseif t >= 1 then
		return 1
	else
		return 1-(1-3*t)*((1-t)^2)
	end
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

	-- make sure the button is indeed in the right direction, then select it:
	for k = 1, #buttons do
		if buttons[k].y < selButton.y then
			selButton.selected = false
			selectButton(buttons[k])
			return
		end
	end
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

	-- make sure the button is indeed in the right direction, then select it:
	for k = 1, #buttons do
		if buttons[k].y > selButton.y then
			selButton.selected = false
			selectButton(buttons[k])
			return
		end
	end
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

	-- make sure the button is indeed in the right direction, then select it:
	for k = 1, #buttons do
		if buttons[k].x < selButton.x then
			-- turn around player if moving to the left
			if selButton.x > buttons[k].x then
				menuPlayer.vis.sx = -1
			end
			selButton.selected = false
			selectButton(buttons[k])
			return
		end
	end
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

	-- make sure the button is indeed in the right direction, then select it:
	for k = 1, #buttons do
		if buttons[k].x > selButton.x then
			-- turn around player if moving to the right
			if selButton.x < buttons[k].x then
				menuPlayer.vis.sx = 1
			end
			selButton.selected = false
			selectButton(buttons[k])
			return
		end
	end
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
	if menu.state == "credits" then	--any key in credits screen returns to main screen.
		menu.startTransition(menu.initMain, false)()
	else
		if key == keys.UP or key == "w" or key == keys.PAD.UP then
			menu:selectAbove()
		elseif key == keys.DOWN or key == "s" or key == keys.PAD.DOWN then
			menu:selectBelow()
		elseif key == keys.LEFT or key == "a" or key == keys.PAD.LEFT then
			menu:selectLeft()
		elseif key == keys.RIGHT or key == "d" or key == keys.PAD.RIGHT then
			menu:selectRight()
		elseif key == keys.CHOOSE or key == " " or key == keys.PAD.CHOOSE then
			menu:execute()
		elseif key == keys.BACK or key == keys.PAD.BACK then
			if menu.state == "main" then
				menu.startTransition(love.event.quit, false)()
			else
				if menu.state == "worldMap" then
					config.setValue( "level", selButton.name )
					menu.startTransition(menu.initMain, true)()
				elseif menu.state == "settings" then
					menu.startTransition(menu.initMain, false)()
				elseif menu.state == "keyboard" or menu.state == "gamepad" then
					keys:exitSubMenu()
				elseif menu.state == "pause" then
					menu:endPauseMenu()
				end
			end
		end
	end
end


---------------------------------------------------------
-- Animate ninja and buttons:
---------------------------------------------------------

function menu:update(dt)
	menuPlayer.vis:update(dt/2)

	local factor = math.min(1, 3*dt)
	self.xCamera = self.xCamera + factor * (self.xTarget- self.xCamera)
	
	if menu.state == "credits" then
		credits:update(dt)
	end

	for k, button in pairs(buttons) do
		if button.selected then
			-- Smooth movement of map - blockwise - 
			if menu.state == "worldMap" then 
--				self.xTarget = math.floor((button.x)/120)*120+59
--				Campaign.worldNumber = math.floor(button.x/120)+1
			end
			
			if button.animated then
				button.vis:update(dt)
			else
				if button.name == "settings" then
					button.timer = button.timer + dt
					button.angle = button.timer * 5
				elseif button.name == "start" or button.name == "continue" then
					button.timer = button.timer + dt
					button.xShift = 1-2*math.abs(math.sin(5*button.timer))
					button.yScale = 1-0.1*math.abs(math.cos(5*button.timer))
					button.xScale = 1/button.yScale
				elseif button.name == "credits" then
					button.timer = button.timer + dt
					--button.xScale = 1-0.1*math.abs(math.cos(6*button.timer))
					--button.xScale = 1-2*math.abs(math.sin(6*button.timer))
					button.xScale = 1+0.15*math.abs(math.sin(6*button.timer))
					button.yScale = button.xScale
					button.angle = 0.2*math.sin(- button.timer * 6)
					button.yShift = 1-2*math.abs(math.sin(6*button.timer))
				elseif button.name == "exit" or button.name == "leave" then
					button.timer = button.timer + dt
					button.yShift = 1-2*math.abs(math.sin(5*button.timer))
					button.xScale = 1-0.05*math.abs(math.cos(5*button.timer))
					button.yScale = 1/button.xScale
				elseif button.name == "level editor" then
					button.timer = button.timer + dt
					button.yShift = -1*math.abs(math.sin(5*button.timer))
					button.xScale = 1-0.05*math.abs(math.cos(5*button.timer))
					button.yScale = 1/button.xScale
					button.yScale = 1/button.xScale
				elseif button.name == "keyboard" then
					button.timer = button.timer + dt
					button.xScale = 1-0.1*math.abs(math.cos(5*button.timer))
					button.yScale = 1-0.05*math.abs(math.cos(5*button.timer))
				elseif button.name == "gamepad" then
					button.timer = button.timer + dt
					button.xScale = 1-0.1*math.abs(math.cos(5*button.timer))
					button.yScale = 1-0.05*math.abs(math.cos(5*button.timer))
				elseif button.name == "restart level" then
					button.timer = button.timer + dt
					button.angle = button.angle - math.pow(math.sin(button.timer), 2)/5
				end
			end
		end
	end

	for k, element in pairs(menuBoxes) do
		element.box:update(dt)
	end
end

---------------------------------------------------------
-- Display menu on screen:
---------------------------------------------------------

function menu:draw()
	--[[if menu.state ~= "worldMap" and menu.state ~= "pause" then
		--myMap:drawParallax(1)
		for k,v in pairs(self.bandanas) do
		  love.graphics.setColor(0,0,30)
		  love.graphics.setLineWidth(Camera.scale*0.5)
		  love.graphics.line(v)
		end
	love.graphics.setColor(255,255,255,100)
	love.graphics.drawq(menu.images.shadow,menu.images.shadowQuad,0,0)
	end]]


	love.graphics.push()
	love.graphics.translate(
		-math.floor(self.xCamera*Camera.scale)+love.graphics.getWidth()/2,
		-math.floor(self.yCamera*Camera.scale)+love.graphics.getHeight()/2)

	-- draw background elements:
	for k, element in pairs(menuBackgrounds) do
		--[[if menu.state == "worldMap" then
			if element.x > menu.furthestX then
				love.graphics.setPixelEffect( shaders.grayScale )
			end
		end]]--
		love.graphics.draw( AnimationDB.image[element.img], element.x*Camera.scale, element.y*Camera.scale )
		--love.graphics.setPixelEffect( )
	end
	
	-- draw logs (bridges)
	for k,log in ipairs(menuLogs) do
		log.vis:draw(log.x*Camera.scale,log.y*Camera.scale)
	end

	local color = {44,90,160,150} -- color of box content
	if menu.state == "pause" then
		color = {44,90,160,255}
	end
	
	-- draw boxes:
	for k,element in pairs(menuBoxes) do
		element.box:draw( element.x, element.y )
	end
	--[[
	for k,element in pairs(menuBoxes) do
		-- scale box coordinates according to scale
		local scaled = {}
		for i = 1,#element.points do
			scaled[i] = element.points[i] * Camera.scale
		end
		-- draw
		--love.graphics.setColor(44,90,160)
		love.graphics.setColor( color )
		love.graphics.setLineWidth(Camera.scale*0.5)
		love.graphics.rectangle('fill',
			element.left*Camera.scale,
			element.top*Camera.scale,
			element.width*Camera.scale,
			element.height*Camera.scale)
		love.graphics.setColor(0,0,0)
		love.graphics.line(scaled)
	end ]]--
	
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
		love.graphics.draw( AnimationDB.image[element.img], element.x*Camera.scale, element.y*Camera.scale, alpha )
	end
	
	for k, button in pairs(buttons) do
		local angle = button.angle or 0
		local xShift = button.xShift or 0
		local yShift = button.yShift or 0
		local xScale = button.xScale or 1
		local yScale = button.yScale or 1
		if button.selected then
			if button.animated then
				button.vis:draw((button.x+button.ox+xShift)*Camera.scale,
								(button.y+button.oy+yShift)*Camera.scale)
			else
				love.graphics.draw( AnimationDB.image[button.imgOn], 
					(button.x+button.ox+xShift)*Camera.scale, 
					(button.y+button.oy+yShift)*Camera.scale, 
					angle, xScale, yScale, 
					button.ox*Camera.scale, 
					button.oy*Camera.scale)
			end
		else
			if button.animated then
				button.vis:draw((button.x+button.ox+xShift)*Camera.scale,
								(button.y+button.oy+yShift)*Camera.scale)
			else
				love.graphics.draw( AnimationDB.image[button.imgOff], 
					(button.x+button.ox+xShift)*Camera.scale, 
					(button.y+button.oy+yShift)*Camera.scale, 
					angle, xScale, yScale, 
					button.ox*Camera.scale, 
					button.oy*Camera.scale)
			end
		end
		love.graphics.setColor(0,0,0,255)
		if button.label then
			love.graphics.setFont( _G[button.font] )
			love.graphics.print( button.label,
						(button.x+button.ox+xShift + button.labelX)*Camera.scale ,
						(button.y+button.oy+yShift + 3)*Camera.scale )
						
		end
		love.graphics.setColor(255,255,255,255)
		--love.graphics.print(k, button.x, button.y )
	end
	
	if menu.state == "main" or menu.state == "worldMap" or
		menu.state == "settings" or menu.state == "keyboard" 
		or menu.state == "gamepad" or menu.state == "pause" then
		--menuPlayer:draw()
		menuPlayer.vis:draw(menuPlayer.x*Camera.scale, menuPlayer.y*Camera.scale)
	end
	
	love.graphics.setFont(fontSmall)
	for k, text in pairs(menuTexts) do
		love.graphics.print( text.txt, 
			(text.x)*Camera.scale, 
			(text.y)*Camera.scale)
	end
	
	love.graphics.pop()

	if menu.state == "worldMap" then
	
		love.graphics.setFont(fontLarge)
		love.graphics.setColor(0,0,0)
		love.graphics.printf(worldNames[Campaign.worldNumber], 0, love.graphics.getHeight()*0.5-Camera.scale*40, love.graphics.getWidth(), 'center')			
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
		love.graphics.printf(displayText, 0, y, love.graphics.getWidth(), 'center')	
		love.graphics.setColor(255,255,255)	
	end

	controlKeys:draw("menu")

end



-----------------------------------------------------------
-- Pause Menu:
-----------------------------------------------------------

function menu.initPauseMenu()
	menu.xCamera = 0
	menu.yCamera = 0
	menu.xTarget = 0
	menu.yTarget = 0

	menu:clear()	-- remove anything that was previously on the menu
	menu.state = "pause"

	love.graphics.setBackgroundColor(40,40,40)
	if not shaders:getDeathEffect() then
		shaders:setDeathEffect( .8 )
	end

	local x,y
	x = -2
	y = 0
	
	local actionHover = menu.setPlayerPosition( x - 4, y + 5 )
	local startButton = menu:addButton( x, y, 'startOff', 'startOn', "continue",menu.endPauseMenu, actionHover )
	--local startButton = menu:addButtonAnimated( x, y, 'startOff', 'startOn', "start", menu.startTransition(menu.initWorldMap), actionHover )
	y = y + 10
	
	actionHover = menu.setPlayerPosition( x - 4, y + 5 )
	local restartEvent = function()
		levelEnd:reset()
		myMap:start(p)
		mode = "game" 
	end
	menu:addButton( x, y, 'restartOff', 'restartOn', "restart level", menu.startTransition(restartEvent, false), actionHover )
	y = y + 10
	
	actionHover = menu.setPlayerPosition( x - 4, y + 5 )
	menu:addButton( x, y, 'exitOff', 'exitOn', "leave", menu.startTransition(menu.initWorldMap, true), actionHover )

	
	-- add main logo:
	x = - 35
	y = - 78
	table.insert(menuImages, {typ="img", img='paused', x=x, y=y})
	
	menu:addBox(-20,-4,40,40)

	-- start of with the start button selected:
	selectButton(startButton)
	
	menuPlayer.vis:setAni("whiteWalk")
	menuPlayer.vis.sx = 1

	menu.curLevelName = nil	-- don't display level name when entering menu
end

function menu.endPauseMenu()
	shaders:resetDeathEffect()
	mode = 'game'
end
---------------------------------------------------------
-- Starts full screen menu transition:
---------------------------------------------------------

local transitionImages = {}

function menu.loadTransitionImages()

	transitionImages = {}

	local img = love.graphics.newImage("images/transition/silhouette.png")
	local newImage = {
		img = img,
		startX = 0, startY = love.graphics.getHeight(),
		endX = love.graphics.getWidth()/2, endY = love.graphics.getHeight()/2, -- position
		startSX = 3, startSY = 3, endSX = 5, endSY = 5, -- scale
		startR = 0, endR = .1, -- rotation
		oX = img:getWidth()/2, oY = img:getHeight()/2, -- offset
	}
	table.insert( transitionImages, newImage )
	newImage = {
		img = img,
		startX = love.graphics.getWidth()/2, startY = love.graphics.getHeight()/2,
		endX = love.graphics.getWidth()/2, endY = love.graphics.getHeight()/2, -- position
		startSX = 0.2, startSY = 0.2, endSX = 5, endSY = 5, -- scale
		startR = 0, endR = 0, -- rotation
		oX = img:getWidth()/2, oY = img:getHeight()/2, -- offset
	}
	table.insert( transitionImages, newImage )
	newImage = {
		img = img,
		startX = 0, startY = love.graphics.getHeight(),
		endX = love.graphics.getWidth()/2, endY = love.graphics.getHeight()/2, -- position
		startSX = 3, startSY = 3, endSX = 5, endSY = 5, -- scale
		startR = -1, endR = -.1, -- rotation
		oX = img:getWidth()/2, oY = img:getHeight()/2, -- offset
	}
	table.insert( transitionImages, newImage )
	newImage = {
		img = img,
		startX = love.graphics.getWidth(), startY = love.graphics.getHeight(),
		endX = love.graphics.getWidth()/2, endY = love.graphics.getHeight()/2, -- position
		startSX = 3, startSY = 3, endSX = 8, endSY = 8, -- scale
		startR = 0, endR = .1, -- rotation
		oX = img:getWidth()/2, oY = img:getHeight()/2, -- offset
	}
	table.insert( transitionImages, newImage )
	newImage = {
		img = img,
		startX = love.graphics.getWidth()/2, startY = love.graphics.getHeight(),
		endX = love.graphics.getWidth()/2, endY = love.graphics.getHeight()/2, -- position
		startSX = 3, startSY = 3, endSX = 7, endSY = 7, -- scale
		startR = 0, endR = .1, -- rotation
		oX = img:getWidth()/2, oY = img:getHeight()/2, -- offset
	}
	table.insert( transitionImages, newImage )

	img = love.graphics.newImage("images/transition/silhouetteBlue.png")
	newImage = {
		img = img,
		startX = 0, startY = 0,
		endX = love.graphics.getWidth() + img:getWidth(), endY = love.graphics.getHeight() + img:getWidth(), -- position
		startSX = 3, startSY = 3, endSX = 5, endSY = 5, -- scale
		startR = 0, endR = 0, -- rotation
		oX = img:getWidth(), oY = img:getHeight(), -- offset
	}
	table.insert( transitionImages, newImage )
	
	img = love.graphics.newImage("images/transition/silhouetteBlue.png")
	newImage = {
		img = img,
		startX = love.graphics.getWidth(), startY = 0,
		endX = 0, endY = love.graphics.getHeight() + img:getWidth(), -- position
		startSX = -3, startSY = 3, endSX = -5, endSY = 5, -- scale
		startR = 0, endR = 0, -- rotation
		oX = img:getWidth(), oY = img:getHeight(), -- offset
	}
	table.insert( transitionImages, newImage )


end

function menu.startTransition( event, showImage )
	return function()
		if not menu.transitionActive then
			menu.curLevelName = nil
			menu.transitionActive = true
			menu.transitionPercentage = 0
			love.mouse.setVisible(false)
			menu.transitionEvent = event	-- will be called when transitionPercentage is 50%
			if showImage then
				menu.transImg = transitionImages[ math.random( #transitionImages ) ]
				menu.transitionSpeed = TRANSITION_SPEED
			else
				menu.transImg = nil
				menu.transitionSpeed = TRANSITION_SPEED*2
			end
		end
	end
end

-- Handle transition every frame until done:
function menu:transition( dt )
	menu.transitionPercentage = menu.transitionPercentage + dt*menu.transitionSpeed
	if menu.transitionPercentage >= 50 and menu.transitionEvent then
		menu.transitionEvent()
		menu.transitionEvent = nil
		shaders:resetDeathEffect()
	end
	if menu.transitionPercentage >= 100 then
		menu.transitionActive = false
		menu.transitionPercentage = 0
	end
end

function menu:drawTransition()
	if menu.transitionPercentage <= 50 and menu.transImg then
		local amount = 1 - math.pow((menu.transitionPercentage - 50)/50, 2)

		local x = amount*(menu.transImg.endX -  menu.transImg.startX)
					 + menu.transImg.startX
		local y = amount*(menu.transImg.endY -  menu.transImg.startY)
					 + menu.transImg.startY
		local r = amount*(menu.transImg.endR -  menu.transImg.startR)
					 + menu.transImg.startR
		local sx = amount*(menu.transImg.endSX -  menu.transImg.startSX)
					 + menu.transImg.startSX
		local sy = amount*(menu.transImg.endSY -  menu.transImg.startSY)
					 + menu.transImg.startSY
		love.graphics.draw( menu.transImg.img, x, y, r, sx, sy, menu.transImg.oX, menu.transImg.oY ) 
	end
end

---------------------------------------------------------
-- Misc functions:
---------------------------------------------------------

-- computes square of the distance between two points (for speed)
-- weighs one direction (x or y) more than the other
function sDist(x1, y1, x2, y2, preferred)
	if preferred == "x" then
		return (x1-x2)^2 + ((y1-y2)^2)*2
	else
		return ((x1-x2)^2)*2 + (y1-y2)^2
	end
end

function selectButton(button)
	if selButton then
		-- switch to the "off" animation of the button:
		if selButton.animated then
			selButton.vis:setAni( selButton.animationOff )
		end
	end

	selButton = button
	button.selected = true

	-- display names of selected buttons, but not in key selection menu:
	if menu.state ~= "keyboard" and menu.state ~= "gamepad" then
		menu.text = button.name
	else menu.text = ""
	end
	if selButton.actionHover then
		selButton.actionHover( selButton )
	end
	if selButton.animated then
		selButton.vis:setAni( selButton.animationOn )
	end
end

function menu:getSelected()
	return selButton
end

return menu
