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
	self:add('spikeDeath','silence.wav')
	self:add('shurikenShoot','placeholder.wav')
	self:add('shurikenHit','silence.wav')
	self:add('spawnWalker','silence.wav')
	self:add('walkerLand','silence.wav')
	self:add('buttonPress','silence.wav')
	self:add('buttonRelease','silence.wav')
	self:add('buttonUnPress','silence.wav')
	self:add('GoalieCollide','silence.wav')
	self:add('RunnerCollide','silence.wav')
	self:add('RunnerLand','silence.wav')
	
	-- ninja stirbt an verschiedenen gegnern:
	self:add('shurikenDeath','silence.wav')
	self:add('walkerDeath','silence.wav')
	self:add('GoalieDeath','silence.wav')
	
	-- in-game long sounds
	self:add('shurikenFly','silence.wav')
	
	self:add('wallSlide','silence.wav')
	self:add('groundSlide','silence.wav')
	self:add('run','silence.wav')
	self:add('walk','silence.wav')
	
	

	
end
