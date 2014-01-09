
local settings = {}

--settings.fullscreen = false

function settings:checkMode( w, h )
	if settings.fullscreen then
		for k, v in pairs(love.graphics.getModes()) do
			if v.width >= w and v.height >= h then
				return true
			end
		end
	else
		for k, v in pairs(love.graphics.getModes()) do
			if v.width >= w and v.height >= h then
				return true
			end
		end
	end
	return false
end

function settings:setWindowSize()
	local success
	local scale
	if self.fullscreen then
		scale = self:fullscreenScale()
		--success = love.graphics.setMode(self.xScreen,self.yScreen, true)
		success = love.window.setMode( 0, 0, {fullscreen = true} )
	else
		scale = self:windowScale()
		success = love.window.setMode(
			math.min(self.xScreen,scale*8*32),
			math.min(self.yScreen,scale*8*20)
			, {fullscreen = false} )
	end
	Camera:setScale(scale)

	local w, h = love.window.getDimensions()
	
	fullscreenCanvas = love.graphics.newCanvas(w, h)
	
	return success
end

function settings:toggleFullScreen(switch)
	if switch == nil then
		self.fullscreen = not self.fullscreen
	else
		self.fullscreen = switch
	end
	self:setWindowSize()
	Camera:applyScale()
	config.setValue("fullscreen",self.fullscreen)
end


-- reads previous configuration and sets it:
function settings:initWindowSize()
	
	-- find screen size
	--[[
	local modes = love.graphics.getModes()
	table.sort(modes, function(a, b) return a.width*a.height > b.width*b.height end)
	self.xScreen = modes[1].width
	self.yScreen = modes[1].height
	]]--
	local w, h = love.window.getDesktopDimensions()
	self.xScreen = w
	self.yScreen = h

	-- only property is "fullscreen"
	self.fullscreen = config.getValue("fullscreen")
	if not self.fullscreen or self.fullscreen == "false" then
		self.fullscreen = false
	end

	settings:setWindowSize()
end

-- find largest scale-factor that still fits into the screen
function settings:windowScale()
	local scale = math.min(math.floor((self.xScreen-1)/(8*32)),	math.floor((self.yScreen-1)/(8*20)),8)
	scale = math.max(scale,4)
	return scale
end

-- find a scale such that the number of tiles in the images is as close
-- as possible to 32*20.
function settings:fullscreenScale()
	local suggestedScale = 4
	local target = 640
	local nTiles = self.xScreen/32 * self.yScreen/32
	for scale = 5,8 do
		local nNewTiles = self.xScreen*self.yScreen/(scale*scale*8*8)
		if math.abs(nNewTiles - target) < math.abs(nTiles - target) then
		-- accept new value
			suggestedScale = scale
			nTiles = nNewTiles
		end
	end
	return suggestedScale
end

function settings.init()
	menu:clear()	-- remove anything that was previously on the menu
	menu.state = "settings"

	menuPlayer.vis:setAni("lookWhite")
	
	local x,y = -22, 0
	
	menu.setPlayerPosition( 0, 15 )()
	menuPlayer.vis.sx = -1
	
	local startButton = menu:addButton( x, y, 'keyboardOff_IMG', 'keyboardOn_IMG', "keyboard", menu.startTransition(keys.initKeyboard), nil)
	
	x = x + 25
	menu:addButton( x, y, 'gamepadOff_IMG', 'gamepadOn_IMG', "gamepad", menu.startTransition(keys.initGamepad), nil )

	menu:addBox(-25,-4,50,30)

	selectButton(startButton)
end

return settings
