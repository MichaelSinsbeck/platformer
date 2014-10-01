function Sound:loadAll()
	self:clear()
	print('Loadings sounds')

	-- menu sounds
	self:add('menuMove','placeholder.wav','placeholder2.wav')
	self:add('menuEnter','silence.wav')
	self:add('menuBack','silence.wav')
	self:add('menuPause','silence.wav')
	self:add('showStatistics','silence.wav')

	-- in-game short sounds
	-- ninja:
	self:add('jump','silence.wav')
	self:add('wallJump','silence.wav')
	self:add('doubleJump','silence.wav')
	self:add('openParachute','silence.wav')
	self:add('jumpOfLine','silence.wav')
	self:add('land','silence.wav')
	self:add('win','silence.wav')
	-- gegner:
	self:add('shurikenShoot','placeholder.wav')
	self:add('shurikenHit','silence.wav')
	self:add('spawnWalker','silence.wav')
	self:add('walkerLand','silence.wav')
	self:add('walkerStep','silence.wav')
	self:add('buttonPress','silence.wav')
	self:add('buttonRelease','silence.wav')
	self:add('buttonUnPress','silence.wav')
	self:add('goalieCollide','silence.wav')
	self:add('runnerCollide','silence.wav')
	self:add('runnerLand','silence.wav')
	
	self:add('launcherShoot','silence.wav')
	self:add('cannonShoot','silence.wav')
	self:add('meatCollide','silence.wav')
	self:add('missileExplode','silence.wav')
	self:add('glassBreak','silence.wav')
	self:add('textAppear','silence.wav')
	self:add('textDisappear','silence.wav')
	self:add('collectBean','silence.wav')
	self:add('bumperBump','silence.wav')
	self:add('weakBouncerBump','silence.wav')
	self:add('mediumBouncerBump','silence.wav')
	self:add('strongBouncerBump','silence.wav')
	self:add('crumbleblockTouch','silence.wav')
	self:add('crumbleblockCrumble','silence.wav')
	self:add('collectKey','silence.wav')
	self:add('doorOpen','silence.wav')

	
	-- ninja stirbt an verschiedenen gegnern:
	self:add('shurikenDeath','silence.wav')
	self:add('walkerDeath','silence.wav')
	self:add('goalieDeath','silence.wav')
	self:add('spikeDeath','silence.wav')	
	
	-- in-game long sounds
	self:add('shurikenFly','silence.wav')
	self:add('rotatorLong','silence.wav')
	self:add('runnerLong','silence.wav')
	
	self:add('wallSlide','silence.wav')
	self:add('groundSlide','silence.wav')
	self:add('run','silence.wav')
	self:add('walk','silence.wav')
	
	

	
end
