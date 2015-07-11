function Sound:loadAll()
	self:clear()
	print('Loadings sounds')

	-- menu sounds
	--self:add('menuMove',.1,10,'menuMove.wav')
	self:add('menuMove',.1,10,'max/G6.ogg','max/G7.ogg','max/G8.ogg','max/G9.ogg','max/G10.ogg','max/G11.ogg','max/G12.ogg')
	--self:add('menuMove',.1,10,'max/G6.ogg')	
	self:add('menuEnter',.1,10,'max/G1.ogg')
	--self:add('menuEnter',.5,10,'menuBack.wav')
	self:add('menuBack',.5,10,'menuBackII.wav')

	--self:add('menuPause','silence.wav')
  --self:add('showStatistics','hits/hit12.mp3.ogg')

	-- in-game short sounds

	-- ninja:
	self:add('jump',.1,10,'Jump_1.wav','Jump_2.wav','Jump_3.wav','Jump_4.wav','Jump_5.wav','Jump_6.wav','Jump_7.wav','Jump_9.wav','Jump_10.wav')
	self:add('dash',.1,10,'playerDash1.wav','playerDash2.wav')
	self:add('openParachute',.1,10,'lukas/openParachuteII.wav')
	self:add('land',1,10, 'playerLand1.wav', 'playerLand2.wav', 'playerLand3.wav')
	self:add('run',.2,10,'playerRunII.wav')
	self:add('wallSlide',0.05,10,'slide.wav')
	self:add('groundSlide',1,10,'Rutschen_3.wav')
	self:add('lineSlide',.3,10,'lineSlide.wav')
	self:add('shootBungee',.1,10,'freesound/rope1.wav','freesound/rope2.wav','freesound/rope3.wav')
--	self:add('win',1,10,'hits/hit12.mp3.ogg')

	-- deathes:
	--self:add('shurikenDeath',1,10,'shurikenDeath_1.wav','shurikenDeath_2.wav','shurikenDeath_3.wav')
	--self:add('walkerDeath',1,10,'shurikenDeath_1.wav','shurikenDeath_2.wav','shurikenDeath_3.wav')
	--self:add('goalieDeath',1,10,'shurikenDeath_1.wav','shurikenDeath_2.wav','shurikenDeath_3.wav')
	--self:add('spikeDeath',1,10,'lukas/shurikenDeath_1.wav','lukas/shurikenDeath_2II.wav','lukas/shurikenDeath_3II.wav')
	--self:add('spikeDeath',1,10,'monster_mash_v11.wav','monster_mash_v21.wav')
	self:add('death',1,10,'monster_mash_v11.wav','monster_mash_v21.wav')
	self:add('meatCollide',.1,20,'mash_v1.wav', 'mash_v2.wav', 'mash_v3.wav', 'mash_v4.wav', 'mash_v5.wav', 'mash_v6.wav')
	
	
	self:add('upgrade',.1,10,'opengameart/hit12.wav')

	-- enemies:
	self:add('shurikenShoot',.5,10,'lukas/shurikenShoot.wav')
	self:add('shurikenHit',.3,5, 'lukas/shurikenHit_1II.wav', 'lukas/shurikenHit_2II.wav', 'lukas/shurikenHit_3II.wav')
	self:add('shurikenFly',1,5,'NinjaStern_rauscharm_v1.wav')
	self:add('buttonPress',0.2,30,'opengameart/switch17.ogg')
	self:add('buttonUnPress',0.2,30,'opengameart/switch18.ogg')
	self:add('ticktock',0.2,30,'opengameart/ticking_clock_bearbeitet.wav')
	self:add('launcherShoot',.1,40,'lukas/shurikenShoot.wav')
	self:add('cannonShoot',.3,50,'opengameart/hit02II.wav')
	self:add('missileFly',1,20,'Rakete_v2.wav')
	self:add('missileExplode',.05,30,'freesound/explosion.wav')
	self:add('followerWake',1,10,'monster_v3.wav')
	self:add('wall1',1,10,'Wall_01.wav')
	self:add('wall2',1,10,'Wall_02.wav')
	self:add('wall3',1,10,'Wall_03.wav')
	self:add('wall4',1,10,'Wall_04.wav')
	self:add('wall5',1,10,'Wall_05.wav')
	self:add('wall6',1,10,'Wall_06.wav')	
	self:add('followerDie',1,10,'lukas/shurikenDeath_1.wav','lukas/shurikenDeath_2II.wav','lukas/shurikenDeath_3II.wav')
	self:add('walkerStep',.1,5,'lukas/walkerStep_1.wav','lukas/walkerStep_2.wav','lukas/walkerStep_3.wav')
	self:add('walkerLand',.4,15,'lukas/walkerLand_1.wav','lukas/walkerLand_3.wav')
	self:add('glassBreak',.2,20,'freesound/glass_break1.wav','freesound/glass_break2.wav','freesound/glass_break3.wav','freesound/glass_break4.wav','freesound/glass_break5.wav')
	self:add('bouncerBump',1,10,'freesound/bouncer.wav')
	self:add('rotator',.2,15,'freesound/engine3.wav')
	
	self:add('textAppear',.1,10,'freesound/text-appear.wav')
	self:add('textDisappear',.1,10,'freesound/text-disappear.wav')
	
	--self:add('spawnWalker',1,10,'silence.wav')
	
	
	--self:add('goalieCollide',1,10,'silence.wav')
	--self:add('runnerCollide',1,10,'silence.wav')
	--self:add('runnerLand',1,10,'silence.wav')
	

	
	--self:add('missileExplode',1,10,'opengameart/synthetic_explosion_1II.wav')
	--self:add('glassBreak',1,10,'silence.wav')

	
	--self:add('collectBean',1,10,'silence.wav')
	--self:add('bumperBump',1,10,'silence.wav')
	--self:add('weakBouncerBump',1,10,'silence.wav')
	--self:add('mediumBouncerBump',1,10,'silence.wav')
	--self:add('strongBouncerBump',1,10,'silence.wav')
	--self:add('crumbleblockTouch',1,10,'silence.wav')

	--self:add('collectKey',1,10,'silence.wav')
	--self:add('doorOpen',1,10,'silence.wav')

	
end
