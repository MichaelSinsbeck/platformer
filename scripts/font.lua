function loadFont()

	--local prefix = Camera.scale * 8
	-- load and set font
	--fontSmall = love.graphics.newImageFont('images/font/'.. prefix ..'fontSmall.png',
		--' abcdefghijklmnopqrstuvwxyz0123456789.,?+&ABCD-:!/')
	--fontLarge = love.graphics.newImageFont('images/font/'.. prefix ..'fontLarge.png',
		--' abcdefghijklmnopqrstuvwxyz0123456789.,?+&ABCD-:!/')
	local size = Camera.scale*6
	fontSmall = love.graphics.newFont('font/bandana.ttf',size)
	fontLarge = love.graphics.newFont('font/bandana.ttf',2*size)	
	love.graphics.setFont(fontSmall)
end
