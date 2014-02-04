require 'scripts/objects.player'
require 'scripts/objects.imitator'
require 'scripts/objects.runner'
require 'scripts/objects.goalie'
require 'scripts/objects.spikey'
require 'scripts/objects.bouncer'
require 'scripts/objects.shuriken'
require 'scripts/objects.cannon'
require 'scripts/objects.launcher'
require 'scripts/objects.missile'
require 'scripts/objects.explosion'
require 'scripts/objects.bandana'
require 'scripts/objects.poff'
require 'scripts/objects.line'
require 'scripts/objects.particle'
require 'scripts/objects.windmill'
require 'scripts/objects.button'
require 'scripts/objects.appearblock'
require 'scripts/objects.emitter'
require 'scripts/objects.winddot'
require 'scripts/objects.bubble'
require 'scripts/objects.crumbleblock'
require 'scripts/objects.glassblock'
require 'scripts/objects.fixedcannon'
require 'scripts/objects.butterfly'
require 'scripts/objects.meat'
require 'scripts/objects.exit'
require 'scripts/objects.bungee'
require 'scripts/objects.door'
require 'scripts/objects.keyhole'
require 'scripts/objects.key'
require 'scripts/objects.bumper'
require 'scripts/objects.clubber'
require 'scripts/objects.light'
require 'scripts/objects.bonus'
require 'scripts/objects.input'
require 'scripts/objects.walker'
require 'scripts/objects.walkerhorz'
require 'scripts/objects.walkervert'
require 'scripts/objects.spawner'


function initAll()
  -- Run initializing code on all prototypes
  -- This sets height and width according to the image
  Runner:init()
  Goalie:init()
  Spikey:init()
  Player:init()
  BouncerLeft:init()
  Bouncer:init()
  Cannon:init()
  Shuriken:init()
  Launcher:init()
  Missile:init()
  Explosion:init()
  Bandana:init()
  Poff:init()
  Shuriken:init()
  Particle:init()
	Windmill:init()
	Button:init()
	Appearblock:init()
	Imitator:init()
	Winddot:init()
	Emitter:init()
	Crumbleblock:init()
	Bubble:init()
	Glassblock:init()
	FixedCannon:init()
	Butterfly:init()
	Meat:init()
	Exit:init()
	Bungee:init()
	Door:init()
	Keyhole:init()
	Key:init()
	Bumper:init()
	Clubber:init()
	Light:init()
	Bonus:init()
	InputJump:init()	-- keyboard and gamepad keys displayed in level
	InputAction:init()
	InputLeft:init()
	InputRight:init()
	updateInputDisplays()
	Walker:init()
	WalkerRight:init()
	WalkerLeft:init()
	WalkerDown:init()
	WalkerUp:init()
	Spawner:init()
end

function spriteFactory(name,opts)
	local new
	print(name)
	if name == 'runner' then
		new = Runner:New(opts)
	elseif name == 'player' then
		new = Player:New(opts)
	elseif name == 'bouncer' then
		new = Bouncer:New(opts)
	elseif name == 'cannon' then
		new = Cannon:New(opts)   
	elseif name == 'button' then
		new = Button:New(opts)
	elseif name == 'missile' then
		new = Missile:New(opts)    
	elseif name == 'exit' then
		new = Exit:New(opts)    
	elseif name == 'spikey' then
		new = Spikey:New(opts)    
	elseif name == 'bandana' then
		new = Bandana:New(opts)    
	elseif name == 'door' then
		new = Door:New(opts)    
	elseif name == 'emitter' then
		new = Emitter:New(opts)    
	elseif name == 'spawner' then
		new = Spawner:New(opts)    
	elseif name == 'launcher' then
		new = Launcher:New(opts)    
	elseif name == 'crumbleblock' then
		new = Crumbleblock:New(opts)    
	elseif name == 'appearblock' then
		new = Appearblock:New(opts)    
	end
	if new then
		new.name = name
	end
	return new
end
