function Sound:loadAll()
	self:clear()
	print('Loadings sounds')
--[[
	-- menu sounds
	self:add('menuMove','silence.wav','silence.wav')
	self:add('menuEnter','silence.wav')
	self:add('menuBack','silence.wav')
	self:add('menuPause','silence.wav')
	self:add('showStatistics','silence.wav')

	-- in-game short sounds
	-- ninja:
	self:add('jump','silence.wav')
	self:add('wallJump','silence.wav')
	self:add('doubleJump','silence.wav')
	self:add('openParachute','openParachute.wav')
	self:add('jumpOfLine','silence.wav')
	self:add('land','silence.wav')
	self:add('win','silence.wav')
	-- gegner:
	self:add('shurikenShoot','shurikenShoot.wav')
	self:add('shurikenHit','shurikenHit_1.wav','shurikenHit_2.wav','shurikenHit_3.wav')
	self:add('spawnWalker','silence.wav')
	self:add('walkerLand','walkerLand_1.wav','walkerLand_2.wav','walkerLand_3.wav')
	self:add('walkerStep','walkerStep_1.wav','walkerStep_2.wav','walkerStep_3.wav')
	self:add('buttonPress','silence.wav')
	self:add('buttonRelease','silence.wav')
	self:add('buttonUnPress','silence.wav')
	self:add('goalieCollide','silence.wav')
	self:add('runnerCollide','silence.wav')
	self:add('runnerLand','silence.wav')
	
	self:add('launcherShoot','shurikenShoot.wav')
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
	self:add('shurikenDeath','shurikenDeath_1.wav','shurikenDeath_2.wav','shurikenDeath_3.wav')
	self:add('walkerDeath','shurikenDeath_1.wav','shurikenDeath_2.wav','shurikenDeath_3.wav')
	self:add('goalieDeath','shurikenDeath_1.wav','shurikenDeath_2.wav','shurikenDeath_3.wav')
	self:add('spikeDeath','shurikenDeath_1.wav','shurikenDeath_2.wav','shurikenDeath_3.wav')	
	
	-- in-game long sounds
	self:add('shurikenFly','silence.wav')
	self:add('rotatorLong','silence.wav')
	self:add('runnerLong','silence.wav')
	
	self:add('wallSlide','silence.wav')
	self:add('groundSlide','silence.wav')
	self:add('run','silence.wav')
	self:add('walk','silence.wav')
	
	--]]

	
end
