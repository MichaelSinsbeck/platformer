local shaders = {}
local deathEffect = {
	fullTime = 2,
	percentage = 0,
}

--local backgroundBaseColor = {0.21, 0.34, 0.435, 1.0}
local backgroundBaseColor = {0.31, 0.44, 0.535, 1.0}

local renderedToCanvas = false

local function textFromFile( file )
	local t = love.filesystem.read("scripts/shaders/" .. file)
	--local f = assert(io.open("scripts/shaders/" .. file, "r"))
	--local t = f:read("*all")
	--f:close()
	return t or ""
end

function shaders:load()

	print("Loading Shaders...")
	--[[print("\tLooking for canvas support...")
	if love.graphics.isSupported("canvas") then
		print("\t\t...supported!")
	else
		print("\t\t...not supported!")
		print("Disabling shaders")
		settings:setShadersEnabled( false )
		return
	end
	
	print("\tLooking for shader support...")
	if love.graphics.isSupported("shader") then
		print("\t\t...supported!")
	else
		print("\t\t...not supported!")
		print("Disabling shaders")
		settings:setShadersEnabled( false )
		return
	end
	
	print("\tLooking for non-power-of-two texture support...")
	if love.graphics.isSupported("npot") then
		print("\t\t...supported!")
	else
		print("\t\t...not supported!")
		print("Disabling shaders")
		settings:setShadersEnabled( false )
		return
	end]]

	--shaders.grayScale = love.graphics.newPixelEffect( textFromFile ("grayscale.glsl") )
	--shaders.fadeToBlack = love.graphics.newPixelEffect( textFromFile ("fadeToBlack.glsl") )
	shaders.fullscreen = love.graphics.newShader( "scripts/shaders/fullscreen.glsl" )
	shaders.background = love.graphics.newShader( "scripts/shaders/background.glsl" )
	shaders.background:send( "baseCol", backgroundBaseColor )
	shaders.backgroundCanvas = love.graphics.newCanvas(
								love.graphics.getWidth(),
								love.graphics.getHeight() )
	shaders.resetDeathEffect()
	print("Shaders loaded.")
end

function shaders:setDeathEffect( percentage )
	deathEffect.percentage = math.max( 0, math.min(1, percentage) )
	deathEffect.active = true
end

function shaders:resetDeathEffect()
	deathEffect.active = false
	deathEffect.percentage = 0
end

function shaders:getDeathEffect()
	return deathEffect.active, deathEffect.percentage
end

function shaders:update( dt )
	if settings:getShadowsEnabled() and shadows.needsShadowUpdate then
		if myMap then
			myMap:updateShadows()
		end
	end
end

function shaders:draw()
	if settings:getShadersEnabled() then
		renderedToCanvas = false
		if menu.transitionActive or deathEffect.active then
			renderedToCanvas = true
			--fullscreenCanvas:clear(love.graphics.getBackgroundColor())
			love.graphics.setCanvas(fullscreenCanvas)
			love.graphics.clear(love.graphics.getBackgroundColor())
			--love.graphics.setColor(l)
			--love.graphics.rectangle('fill', 0, 0,
			--		fullscreenCanvas:getWidth(), fullscreenCanvas:getHeight())
			--love.graphics.setColor(255,255,255,255)
		end
	end
end

function shaders:stop()
	if settings:getShadersEnabled() then
		if renderedToCanvas then
			love.graphics.setCanvas()
			shaders.fullscreen:send( "percentage", menu.transitionPercentage )
			shaders.fullscreen:send( "grayAmount", deathEffect.percentage )
			love.graphics.setShader( shaders.fullscreen )
			love.graphics.draw(fullscreenCanvas, 0, 0)
			love.graphics.setShader()
		end
	else
		if menu.transitionActive then
			-- draw black rectangle over everything:
			love.graphics.setColor( 0, 0, 0, 255*math.sin(math.pi*menu.transitionPercentage/100))
			love.graphics.rectangle('fill', 0, 0,
					fullscreenCanvas:getWidth(), fullscreenCanvas:getHeight())
			love.graphics.setColor( 255, 255, 255, 255 )
		end
	end
end

local rememberShader, rememberCanvas
function shaders:startBackground()
	rememberShader = love.graphics.getShader()
	rememberCanvas = love.graphics.getCanvas()
	shaders.backgroundCanvas:clear()
	love.graphics.setShader( shaders.background )
	love.graphics.setCanvas( shaders.backgroundCanvas )
end
function shaders:endBackground( posX, posY )
	love.graphics.setShader( rememberShader )
	love.graphics.setCanvas( rememberCanvas )
	love.graphics.push()
	love.graphics.origin()
	love.graphics.draw( shaders.backgroundCanvas )
	love.graphics.pop()
end


return shaders
