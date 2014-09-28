function Sound:loadAll()
	self:clear()
	print('Loadings sounds')

	self:add('menuMove','placeholder2.ogg','placeholder.ogg')
	self:add('menuEnter','placeholder.ogg')
	self:add('menuBack','placeholder.ogg')
	self:add('menuPause','placeholder.ogg')

	self:add('jump','placeholder.ogg','placeholder2.ogg')
	self:add('wallJump','placeholder.ogg')
	self:add('doubleJump','placeholder.ogg')
	self:add('openParachute','placeholder.ogg')
	self:add('win','placeholder.ogg')
	self:add('land','placeholder.ogg')
	self:add('spikeDeath','placeholder.ogg')
	self:add('shurikenShoot','placeholder2.ogg')
	self:add('shurikenHit','placeholder.ogg')
	self:add('shurikenDeath','placeholder.ogg')
	
	self:add('spawn','placeholder.ogg')
	self:add('buttonPress','placeholder.ogg')
	self:add('buttonRelease','placeholder.ogg')
	self:add('buttonUnPress','placeholder.ogg')
	
	self:add('showStatistics','placeholder.ogg')
	
end
