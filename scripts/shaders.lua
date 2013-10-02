local shaders = {}
local deathEffect = {
	fullTime = 2,
	percentage = 0,
	renderedToCanvas = false,
}

function textFromFile( file )
	local t = love.filesystem.read("scripts/shaders/" .. file)
	--local f = assert(io.open("scripts/shaders/" .. file, "r"))
	--local t = f:read("*all")
	--f:close()
	return t or ""
end

function shaders:load()

	print("Loading Shaders...")
	print("\tLooking for canvas support...")
	if love.graphics.isSupported("canvas") then
		print("\t\t...supported!")
	else
		print("\t\t...not supported!")
		print("Disabling shaders")
		USE_SHADERS = false
		return
	end
	
	print("\tLooking for shader support...")
	if love.graphics.isSupported("pixeleffect") then
		print("\t\t...supported!")
	else
		print("\t\t...not supported!")
		print("Disabling shaders")
		USE_SHADERS = false
		return
	end
	
	print("\tLooking for non-power-of-two texture support...")
	if love.graphics.isSupported("npot") then
		print("\t\t...supported!")
	else
		print("\t\t...not supported!")
		print("Disabling shaders")
		USE_SHADERS = false
		return
	end

	--shaders.grayScale = love.graphics.newPixelEffect( textFromFile ("grayscale.glsl") )
	--shaders.fadeToBlack = love.graphics.newPixelEffect( textFromFile ("fadeToBlack.glsl") )
	shaders.fullscreen = love.graphics.newPixelEffect( textFromFile("fullscreen.glsl") )
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

function shaders:update( dt )
	if USE_SHADOWS and shadows.needsShadowUpdate then
		if myMap then
			myMap:updateShadows()
		end
	end
end

function shaders:draw()
	if USE_SHADERS then
		renderedToCanvas = false
		if menu.transitionActive or deathEffect.active then
			renderedToCanvas = true
			fullscreenCanvas:clear(love.graphics.getBackgroundColor())
			love.graphics.setCanvas(fullscreenCanvas)
			--love.graphics.setColor(l)
			--love.graphics.rectangle('fill', 0, 0,
			--		fullscreenCanvas:getWidth(), fullscreenCanvas:getHeight())
			--love.graphics.setColor(255,255,255,255)
		end
	end
end

function shaders:stop()
	if USE_SHADERS then
		if renderedToCanvas then
			love.graphics.setCanvas()
			shaders.fullscreen:send( "percentage", menu.transitionPercentage )
			shaders.fullscreen:send( "grayAmount", deathEffect.percentage )
			love.graphics.setPixelEffect( shaders.fullscreen )
			love.graphics.draw(fullscreenCanvas, 0, 0)
			love.graphics.setPixelEffect()
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

return shaders
