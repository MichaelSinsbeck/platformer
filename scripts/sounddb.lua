function Sound:loadAll()
	self:clear()
	print('Loadings sounds')

	-- menu sounds
	
	self:add('menuMove','silence.ogg','silence.ogg')
	self:add('menuEnter','silence.ogg')
	self:add('menuBack','silence.ogg')
	self:add('menuPause','silence.ogg')
	self:add('showStatistics','silence.ogg')



	-- in-game short sounds
	self:add('jump','silence.ogg','silence.ogg')
	self:add('wallJump','silence.ogg')
	self:add('doubleJump','silence.ogg')
	self:add('openParachute','silence.ogg')
	self:add('win','silence.ogg')
	self:add('land','silence.ogg')
	self:add('spikeDeath','silence.ogg')
	self:add('shurikenShoot','silence.ogg')
	self:add('shurikenHit','silence.ogg')
	self:add('shurikenDeath','silence.ogg')
	self:add('spawnWalker','silence.ogg')
	self:add('buttonPress','silence.ogg')
	self:add('buttonRelease','silence.ogg')
	self:add('buttonUnPress','silence.ogg')
	
	-- in-game long sounds
	self:add('shurikenFly','silence.ogg')
	
	self:add('wallSlide','silence.ogg')
	self:add('groundSlide','silence.ogg')
	self:add('run','silence.ogg')
	self:add('walk','silence.ogg')
	
	

	
end
