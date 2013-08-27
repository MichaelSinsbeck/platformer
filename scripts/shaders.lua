local shaders = {}

function textFromFile( file )
	local f = assert(io.open("scripts/shaders/" .. file, "r"))
	local t = f:read("*all")
	f:close()
	return t or ""
end

function shaders.load()
	shaders.grayScale = love.graphics.newPixelEffect( textFromFile ("grayscale.glsl") )
end

return shaders
