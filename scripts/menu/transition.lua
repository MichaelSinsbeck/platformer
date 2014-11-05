
local transition = {}

local transitionImages = {}

function transition:loadImages()
	local img = love.graphics.newImage("images/transition/silhouette.png")
	local newImage = {
		img = img,
		startX = 0, startY = love.graphics.getHeight(),
	endX = love.graphics.getWidth()/2, endY = love.graphics.getHeight()/2, -- position
	startSX = 3, startSY = 3, endSX = 5, endSY = 5, -- scale
	startR = 0, endR = .1, -- rotation
	oX = img:getWidth()/2, oY = img:getHeight()/2, -- offset
	}
	table.insert( transitionImages, newImage )
	newImage = {
	img = img,
	startX = love.graphics.getWidth()/2, startY = love.graphics.getHeight()/2,
endX = love.graphics.getWidth()/2, endY = love.graphics.getHeight()/2, -- position
startSX = 0.2, startSY = 0.2, endSX = 5, endSY = 5, -- scale
startR = 0, endR = 0, -- rotation
oX = img:getWidth()/2, oY = img:getHeight()/2, -- offset
}
table.insert( transitionImages, newImage )
newImage = {
	img = img,
	startX = 0, startY = love.graphics.getHeight(),
endX = love.graphics.getWidth()/2, endY = love.graphics.getHeight()/2, -- position
startSX = 3, startSY = 3, endSX = 5, endSY = 5, -- scale
startR = -1, endR = -.1, -- rotation
oX = img:getWidth()/2, oY = img:getHeight()/2, -- offset
}
table.insert( transitionImages, newImage )
newImage = {
	img = img,
	startX = love.graphics.getWidth(), startY = love.graphics.getHeight(),
endX = love.graphics.getWidth()/2, endY = love.graphics.getHeight()/2, -- position
startSX = 3, startSY = 3, endSX = 8, endSY = 8, -- scale
startR = 0, endR = .1, -- rotation
oX = img:getWidth()/2, oY = img:getHeight()/2, -- offset
	}
	table.insert( transitionImages, newImage )
	newImage = {
		img = img,
		startX = love.graphics.getWidth()/2, startY = love.graphics.getHeight(),
	endX = love.graphics.getWidth()/2, endY = love.graphics.getHeight()/2, -- position
	startSX = 3, startSY = 3, endSX = 7, endSY = 7, -- scale
	startR = 0, endR = .1, -- rotation
	oX = img:getWidth()/2, oY = img:getHeight()/2, -- offset
}
table.insert( transitionImages, newImage )

img = love.graphics.newImage("images/transition/silhouetteBlue.png")
newImage = {
	img = img,
	startX = 0, startY = 0,
endX = love.graphics.getWidth() + img:getWidth(), endY = love.graphics.getHeight() + img:getWidth(), -- position
startSX = 3, startSY = 3, endSX = 5, endSY = 5, -- scale
startR = 0, endR = 0, -- rotation
oX = img:getWidth(), oY = img:getHeight(), -- offset
	}
	table.insert( transitionImages, newImage )

	img = love.graphics.newImage("images/transition/silhouetteBlue.png")
	newImage = {
		img = img,
		startX = love.graphics.getWidth(), startY = 0,
	endX = 0, endY = love.graphics.getHeight() + img:getWidth(), -- position
	startSX = -3, startSY = 3, endSX = -5, endSY = 5, -- scale
	startR = 0, endR = 0, -- rotation
	oX = img:getWidth(), oY = img:getHeight(), -- offset
}
	table.insert( transitionImages, newImage )
end

function transition:new( event, showImage )
	return function()
		if not self.transitionActive then
			self.transitionActive = true
			self.transitionPercentage = 0
			love.mouse.setVisible(false)
			self.transitionEvent = event	-- will be called when transitionPercentage is 50%
			if showImage then
				self.transImg = transitionImages[ math.random( #transitionImages ) ]
				self.transitionSpeed = TRANSITION_SPEED
			else
				self.transImg = nil
				self.transitionSpeed = TRANSITION_SPEED*2
			end
		end
	end
end

function transition:active()
	return (self.transitionActive == true)
end

function transition:update()
	self.transitionPercentage = self.transitionPercentage + dt*self.transitionSpeed
	if self.transitionPercentage >= 50 and self.transitionEvent then
		self.transitionEvent()
		self.transitionEvent = nil
		shaders:resetDeathEffect()
	end
	if self.transitionPercentage >= 100 then
		self.transitionActive = false
		self.transitionPercentage = 0
	end
end

function transition:draw()
	if self.transitionPercentage <= 50 and self.transImg then
		local amount = 1 - math.pow((self.transitionPercentage - 50)/50, 2)

		local x = amount*(self.transImg.endX -  self.transImg.startX)
					 + self.transImg.startX
		local y = amount*(self.transImg.endY -  self.transImg.startY)
					 + self.transImg.startY
		local r = amount*(self.transImg.endR -  self.transImg.startR)
					 + self.transImg.startR
		local sx = amount*(self.transImg.endSX -  self.transImg.startSX)
					 + self.transImg.startSX
		local sy = amount*(self.transImg.endSY -  self.transImg.startSY)
					 + self.transImg.startSY
		love.graphics.draw( self.transImg.img, x, y, r, sx, sy, self.transImg.oX, self.transImg.oY ) 
	end

end

return transition
