
local settings = {
	useShadows = true,
	useShaders = true,
	backgroundDetail = 3,
	fullscreen = false,
}

--settings.fullscreen = false

function settings:checkMode( w, h )
	if self.fullscreen then
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
	print("FULLSCREEN:", self.fullscreen)
	if self.fullscreen then
		print("1")
		scale = self:fullscreenScale()
		print("1.1")
		success = love.window.setMode( 0, 0, {fullscreen = true} )
	else
		print("2")
		scale = self:windowScale()
		print("2.1")
		success = love.window.setMode(
			math.min(self.xScreen,scale*8*32),
			math.min(self.yScreen,scale*8*20), {fullscreen = false} )
	end
		print("3")
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

	--collectgarbage()
end


-- reads previous configuration and sets it:
function settings:initWindowSize()
	
	local w, h = love.window.getDesktopDimensions()
	self.xScreen = w
	self.yScreen = h

	-- only property is "fullscreen"
	--self.fullscreen = config.getValue("fullscreen")
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
	
	local startButton = menu:addButton( x, y, 'keyboardOff', 'keyboardOn', "keyboard", menu.startTransition(keys.initKeyboard), nil)
	
	x = x + 25
	menu:addButton( x, y, 'gamepadOff', 'gamepadOn', "gamepad", menu.startTransition(keys.initGamepad), nil )

	menu:addBox(-33,-7,64,32)

	selectButton(startButton)
end

function settings:getShadowsEnabled()
	return self.useShadows
end

function settings:setShadowsEnabled( bool )
	self.useShadows = bool
end

function settings:getShadersEnabled()
	return self.useShaders
end

function settings:setShadersEnabled( bool )
	self.useShaders = bool
end

function settings:getFullscreen()
	return self.fullscreen
end

function settings:loadAll()
	local bg = config.getValue("backgroundDetail")
	if tonumber( bg ) then
		self.backgroundDetail = tonumber( bg )
	end
	print( "bg", bg, tonumber(bg), self.backgroundDetail )
	local fs = config.getValue("fullscreen")
	if fs == nil or fs == false then
		self.fullscreen = false
	else
		self.fullscreen = true
	end
	local shaders = config.getValue("useShaders")
	if shaders == nil or shaders == false then
		self.useShaders = false
	else
		self.useShaders = true
	end
end

function settings:saveAll()
	config.setValue("fullscreen",self.fullscreen)
	config.setValue("useShaders",self.useShaders)
	config.setValue("backgroundDetail",self.backgroundDetail)
	print("Saved settings:")
	print("\tfullscreen:", self.fullscreen)
	print("\tuseShaders:", self.useShaders)
	print("\tbackgroundDetail:", self.backgroundDetail)
end

function settings:setBackgroundDetail( val )
	print("detail:", val)
	self.backgroundDetail = val
end

function settings:getBackgroundDetail()
	return self.backgroundDetail
end

return settings
