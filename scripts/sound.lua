local sound = {sounds = {}}

function sound:add(name,filename)
	self.sounds[name] = love.audio.newSource( 'sounds/' .. filename, 'static' )
end

function sound:play(name)
	if self.sounds[name] then
		source = self.sounds[name]
		source:stop()
		source:play()
	end
end

function sound:stopAll()
	for k,v in pairs(self.sounds) do
		v:stop()
	end
end

return sound
