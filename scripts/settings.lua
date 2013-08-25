
local settings = {}

settings.xWin = 0
settings.yWin = 0
settings.scale = 4
settings.fullScreen = false

function settings:checkMode( w, h )
	return true
	--[[if settings.fullScreen then
		for k, v in pairs(love.graphics.getModes()) do
			if v.width >= w and v.height >= h then
				return true
			end
		end
	else
		for k, v in pairs(love.graphics.getModes()) do
			if v.width > w and v.height > h then
				return true
			end
		end
	end
	return false]]--
end

function settings:setWindowSize( scale )
	
	scale = scale or settings.scale
	
	-- size of box size is 0.56
	-- window size should be as close as possible to 32x20
	-- scale*18 gives the resolution, where scale is 4,5,6,7 or 8
	local xWin, yWin = scale*18*0.56*32, scale*18*0.56*20
	print("Attempt to rescale: resolution, winX, winY", scale*18, xWin, yWin)
	if settings:checkMode( xWin, yWin ) then
		print("\t-> Success!")
		Camera:setScale( scale )
		settings.scale = scale
		config.setValue("scale", scale)
		love.graphics.setMode( xWin, yWin, settings.fullScreen )
		settings.xWin, settings.yWin = xWin, yWin
		return true
	else
		print("\t-> Failed!")
		return false
	end
end

function settings:toggleFullScreen()
	settings.fullScreen = (settings.fullScreen == false)
	if settings:setWindowSize() then
		config.setValue("fullscreen", settings.fullScreen)
	end
end


-- reads previous configuration and sets it:
function settings:initWindowSize()

	local prevScale = tonumber(config.getValue("scale"))	-- default scale is 4
	local fullScreen = config.getValue("fullscreen")
	
	-- make sure prevScale has a valid value:
	if not prevScale then prevScale = 4 end
	prevScale = math.floor(prevScale)
	if prevScale < 4 or prevScale > 8 then
		prevScale = 4
	end
	
	-- make sure fullScreen has a boolean value (default: false)
	if fullScreen == "true" then fullScreen = true
	else fullScreen = false
	end
	
	settings.fullScreen = fullScreen
	settings:setWindowSize( prevScale )
end

return settings
