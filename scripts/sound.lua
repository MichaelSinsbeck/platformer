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

function sound:addAll()
	print('Loadings sounds')
	self:add('jump','jump.ogg')
	self:add('blockbreak','blockbreak.ogg')
	self:add('boom','boom.ogg')
	self:add('coin','coin.ogg')
	self:add('fireball','fireball.ogg')
	self:add('oneup','oneup.ogg')
	self:add('shot','shot.ogg')	
end

return sound
