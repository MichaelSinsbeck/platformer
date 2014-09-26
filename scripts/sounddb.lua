function Sound:loadAll()
	self:clear()
	print('Loadings sounds')

	self:add('menuMove','placeholder2.wav')
	self:add('menuEnter','placeholder.wav')
	self:add('menuBack','placeholder.wav')
	self:add('menuPause','placeholder.wav')

	self:add('jump','placeholder.wav','placeholder2.wav')
	self:add('wallJump','placeholder.wav')
	self:add('doubleJump','placeholder.wav')
	self:add('openParachute','placeholder.wav')
	self:add('win','placeholder.wav')
	self:add('land','placeholder.wav')
	self:add('spikeDeath','placeholder.wav')
	self:add('shurikenShoot','placeholder2.wav')
	self:add('shurikenHit','placeholder.wav')
	self:add('shurikenDeath','placeholder.wav')
	
	self:add('spawn','placeholder.wav')
	self:add('buttonPress','placeholder.wav')
	self:add('buttonRelease','placeholder.wav')
	self:add('buttonUnPress','placeholder.wav')
	
	self:add('showStatistics','placeholder.wav')
	
end
