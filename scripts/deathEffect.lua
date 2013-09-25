local deathEffect = {
		fullTime = 2
	}

function deathEffect:update( time )
	deathEffect.active = true
	deathEffect.time = time
end

function deathEffect:reset()
	deathEffect.active = false
end

function deathEffect:draw()
	if deathEffect.active then
		shaders.grayScale:send( "amount", math.max(math.min(1, deathEffect.time-0.5), 0) )
		love.graphics.setPixelEffect( shaders.grayScale )
	end
end

function deathEffect:stop()
	if deathEffect.active then
		love.graphics.setPixelEffect( )
		love.graphics.setColor(0,0,0,  255*math.max(math.min(1, deathEffect.time*2-1.5), 0))
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	end
end

return deathEffect
