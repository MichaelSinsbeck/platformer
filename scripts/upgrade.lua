local upgrade = {color = 'none'}

local width = 100
local height = 100
local minTime = .5 -- minimum time, the player has to wait, before continue is possible
local box = BambooBox:new( "", width, height )
local color
local thisTitle
local thisExplanation
local startTime
local vis, bvis, banner

local title ={
	none   = 'Nothing',
	white  = 'White Bandana',
	yellow = 'Yellow Bandana',
	green = 'Green Bandana',
	blue = 'Blue Bandana',
	red = 'Red Bandana',
}

local explanation = {
	none   = '\n\n\n\n\n\n\n\n\n\nYou already have this bandana.\nEnjoy a bowl of rice instead',
	white  = '\n\n\n\n\n\n\n\n\n\nBe a ninja, jump higher, run faster!',
	yellow = '\n\n\n\n\n\n\n\n\n\nLearn the wall-jump.',
	green = '\n\n\n\n\n\n\n\n\n\nUse it as a parachute.',
	blue = '\n\n\n\n\n\n\n\n\n\nLearn the woosh.',
	red = '\n\n\n\n\n\n\n\n\n\nUse it as grappling hook.',
}

local visNames = {
	none   = 'upgradeRice',
	white  = 'upgradeWhite',
	yellow = 'upgradeYellow',
	green = 'upgradeGreen',
	blue = 'upgradeBlue',
	red = 'upgradeRed',
}

local buttonNames = {
  yellow = 'JUMP',
  green = 'JUMP',
  blue = 'DASH',
  red = 'ACTION', 
}

local function getButtonVis(color)
	local device
	local button = buttonNames[color]
	if not button then return nil end
	
	if love.joystick.getJoystickCount() == 0 then
		--return Visualizer:New( getAnimationForKey( keys[button] ) )
		return Visualizer:New( getAnimationForKey( keys[button] ), nil, nameForKey(keys[button]) )		
	else
		return Visualizer:New(  getAnimationForPad( keys.PAD[button] ) )
	end
end

function upgrade:newBandana(newColor)
	mode = 'upgrade'
	shaders:setDeathEffect( .8 )
	color = Campaign:upgradeBandana(newColor)
	thisTitle = title[color]
	thisExplanation = explanation[color]
	-- Image
	vis = Visualizer:New(visNames[color])
	vis:init()
	
	-- Banner
	banner = Visualizer:New('banner')
	banner:init()
	
	-- Which button to press.
	bvis = getButtonVis(color)
	if bvis then bvis:init() end

	startTime = love.timer.getTime()

	gui.addBandana( color );
end

function upgrade.draw()
	--game:draw()
	
	-- box
	local x = 0.5*love.graphics.getWidth()/Camera.scale - 0.5*box.width
	local y = 0.5*love.graphics.getHeight()/Camera.scale - 0.5*box.height
	box:draw(x,y)

	local boundary = Camera.scale * 10	
	y = math.floor(0.5*love.graphics.getHeight() - 0.5*box.pixelHeight + boundary)
	
	-- banner
	local bannerColor = utility.bandana2color[color]
	if bannerColor then
		x = 0.5*love.graphics.getWidth()	
		love.graphics.setColor(bannerColor)
		banner:draw(x,y+7*Camera.scale,true)
	end

	x = math.floor(0.5*love.graphics.getWidth() - 0.5*box.pixelWidth + boundary)
	-- title
	if color == 'blue' or color == 'green' or color == 'red' then
		love.graphics.setColor(colors.text3)
	else
		love.graphics.setColor(colors.text)
	end
	love.graphics.setFont(fontLarge)
	love.graphics.printf(thisTitle, x, y, box.pixelWidth-2*boundary, 'center' )
	
	 -- explanation
	y = y + fontLarge:getHeight()
	love.graphics.setColor(colors.text)
	love.graphics.setFont(fontSmall)
	love.graphics.printf(thisExplanation, x, y, box.pixelWidth-2*boundary, 'center' )
	
	 -- press key to continue
	if love.timer.getTime() > startTime + minTime then
		love.graphics.setColor(colors.text2)
		y = math.floor(0.5*love.graphics.getHeight() + 0.5*box.pixelHeight - boundary - fontSmall:getHeight())
		love.graphics.printf('Press any key to continue', x, y, box.pixelWidth-2*boundary, 'center' )
	end
	
	-- Draw image
	x = 0.5 * love.graphics.getWidth()
	y = 0.5*love.graphics.getHeight() - 0.15*box.pixelHeight
	vis:draw(x,y)
	
	-- Show new button
	if bvis then
		y = 0.5*love.graphics.getHeight() + 0.5*box.pixelHeight - boundary - 3*fontSmall:getHeight()
		bvis:draw(x,y)
			
		love.graphics.setColor(colors.text)
		x = math.floor(0.5*love.graphics.getWidth() - 0.5*box.pixelWidth + boundary)
		y = math.floor(0.5*love.graphics.getHeight() + 0.5*box.pixelHeight - boundary - 5*fontSmall:getHeight())
		love.graphics.printf('Button:', x, y, box.pixelWidth-2*boundary, 'center' )
	end		
end

function upgrade.keypressed()
	if love.timer.getTime() > startTime + minTime then
		mode = 'game'
		shaders:resetDeathEffect()
	end
end

function upgrade.joystickpressed(joystick, button)
	if love.timer.getTime() > startTime + minTime then
		mode = 'game'
		shaders:resetDeathEffect()
	end
end

return upgrade
