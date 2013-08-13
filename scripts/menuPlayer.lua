
local menuPlayer = {
	timer = 0,
	animation = "whiteWalk",
	frame = 1,
	x = 0,
	y = 0,
	scale = 1
}
	
function menuPlayer:draw()
	if menuPlayer.currentQuad and menuPlayer.img then
		love.graphics.drawq(menuPlayer.img, menuPlayer.currentQuad,menuPlayer.x,menuPlayer.y, 0, menuPlayer.scale, menuPlayer.scale)
	end
end

function menuPlayer:update(dt)
	menuPlayer.timer = menuPlayer.timer + dt
	-- switch to next frame
	local animationData = AnimationDB.animation[menuPlayer.animation]
	local source = AnimationDB.source[animationData.source]
	while menuPlayer.timer > animationData.duration[menuPlayer.frame] do
		menuPlayer.timer = menuPlayer.timer - animationData.duration[menuPlayer.frame]
		menuPlayer.frame = menuPlayer.frame + 1
		if menuPlayer.frame > #animationData.frames then
			menuPlayer.frame = 1
		end
	end
	menuPlayer.currentQuad = source.quads[animationData.frames[self.frame]]
	menuPlayer.img = source.image
end

function menuPlayer:reset()
	menuPlayer.frame = 1
	menuPlayer.timer = 0
	menuPlayer.scale = 1
end

function menuPlayer:setDestination(x,y)
	return function()
		menuPlayer.x = x
		menuPlayer.y = y
	end
end

return menuPlayer
