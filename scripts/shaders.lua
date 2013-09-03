local shaders = {}

function textFromFile( file )
	local t = love.filesystem.read("scripts/shaders/" .. file)
	--local f = assert(io.open("scripts/shaders/" .. file, "r"))
	--local t = f:read("*all")
	--f:close()
	return t or ""
end

function shaders.load()

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


	shaders.grayScale = love.graphics.newPixelEffect( textFromFile ("grayscale.glsl") )
	shaders.fadeToBlack = love.graphics.newPixelEffect( textFromFile ("fadeToBlack.glsl") )
	print("Shaders loaded.")
end

return shaders
