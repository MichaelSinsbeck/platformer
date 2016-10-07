function loadFont()

	--local prefix = Camera.scale * 8
	-- load and set font
	--fontSmall = love.graphics.newImageFont('images/font/'.. prefix ..'fontSmall.png',
		--' abcdefghijklmnopqrstuvwxyz0123456789.,?+&ABCD-:!/')
	--fontLarge = love.graphics.newImageFont('images/font/'.. prefix ..'fontLarge.png',
		--' abcdefghijklmnopqrstuvwxyz0123456789.,?+&ABCD-:!/')
--	local size = Camera.scale*6
	--local filename = 'font/bandana.ttf'
	local size = Camera.scale*6*0.8	
	local filename = 'font/bandana.ttf'
	fontSmall = love.graphics.newFont(filename,size)
	fontLarge = love.graphics.newFont(filename,2*size)	
	love.graphics.setFont(fontSmall)
end
