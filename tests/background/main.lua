local banner = require("banner")

local bannerList = {}

function love.load()
	love.graphics.setBackgroundColor( 80, 150, 205 )

	bannerList[#bannerList+1] = banner:new( 0, 200 )
end

function love.update( dt )
	for k, b in pairs( bannerList ) do
		b:update( dt )
	end
end

function love.draw()
	for k, b in pairs( bannerList ) do
		b:draw()
	end
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.printf( "'Enter' to create new banner", 10, 10, 120 )
	love.graphics.printf( love.timer.getFPS(), 10, 50, 120 )
end

function love.keypressed( key, unicode )
	if key == "return" then
		bannerList[#bannerList+1] = banner:new( 0, math.random(love.graphics.getHeight()) )
	end
end
