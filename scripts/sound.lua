local sound = {sounds = {}}

-- sounds is a table of sources. the keys are strings

function sound:add(name,filename)
	self.sounds[name] = love.audio.newSource( 'sounds/' .. filename, 'static' )
end

--function sound:connect(event,sound)
--	self.events[event] = sound
--end

function sound:play(sound)
	--if self.events[event] and self.sounds[self.events[event]] then
	if self.sounds[sound] then
		source = self.sounds[sound]
		source:stop()
		source:play()
	end
end

function sound:stopAll()
	for k,v in pairs(self.sounds) do
		v:stop()
	end
end


function sound:loadAll()
	print('Loadings sounds')

	self:add('menuMove','placeholder.wav')
	self:add('menuEnter','placeholder.wav')
	self:add('menuBack','placeholder.wav')
	self:add('menuPause','placeholder.wav')

	self:add('jump','placeholder.wav')	
	self:add('wallJump','placeholder.wav')
	self:add('doubleJump','placeholder.wav')
	self:add('openParachute','placeholder.wav')
	self:add('win','placeholder.wav')
	self:add('land','placeholder.wav')
	self:add('spikeDeath','placeholder.wav')
	self:add('shurikenShoot','placeholder.wav')
	self:add('shurikenHit','placeholder.wav')
	self:add('shurikenDeath','placeholder.wav')
	
	self:add('spawn','placeholder.wav')
	self:add('buttonPress','placeholder.wav')
	self:add('buttonRelease','placeholder.wav')
	self:add('buttonUnPress','placeholder.wav')
	
	self:add('showStatistics','placeholder.wav')
	
	
	-- hier bitte weitere sounds zufügen in diesem Format:
	-- self:add(soundname,dateiname)
end



return sound
