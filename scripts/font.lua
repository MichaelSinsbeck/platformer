	function loadFont()
	
		local prefix = Camera.scale * 8
		-- load and set font
		fontSmall = love.graphics.newImageFont('images/font/'.. prefix ..'fontSmall.png',
			' abcdefghijklmnopqrstuvwxyz0123456789.,?+&ABCD')
		fontLarge = love.graphics.newImageFont('images/font/'.. prefix ..'fontLarge.png',
			' abcdefghijklmnopqrstuvwxyz0123456789.,?+&ABCD')    
		love.graphics.setFont(fontSmall)
	end
