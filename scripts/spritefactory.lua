require 'scripts/objects.player'
require 'scripts/objects.spikey'
require 'scripts/objects.shuriken'
require 'scripts/objects.cannon'
require 'scripts/objects.bouncer'
require 'scripts/objects.launcher'
require 'scripts/objects.missile'
require 'scripts/objects.explosion'
require 'scripts/objects.bandana'
require 'scripts/objects.particle'
require 'scripts/objects.windmill'
require 'scripts/objects.button'
require 'scripts/objects.appearblock'
require 'scripts/objects.meat'
require 'scripts/objects.exit'
require 'scripts/objects.input'
require 'scripts/objects.walker'
require 'scripts/objects.spawner'
require 'scripts/objects.poff'


function initAll()
  -- Run initializing code on all prototypes
  -- This sets height and width according to the image

  Spikey:init()
  Player:init()

  Bouncer:init()
  Cannon:init()
  Shuriken:init()
  Launcher:init()
  Missile:init()
  Explosion:init()
  Bandana:init()
  Shuriken:init()
  Particle:init()
	Windmill:init()
	Button:init()
	Poff:init()
	Appearblock:init()
	Meat:init()
	Exit:init()
	InputJump:init()	-- keyboard and gamepad keys displayed in level
	InputAction:init()
	InputLeft:init()
	InputRight:init()
	updateInputDisplays()
	Walker:init()
	Spawner:init()
end

function spriteFactory(name,opts)
  if name == 'runner' then
    return Runner:New(opts)
  elseif name == 'player' then
    return Player:New(opts)
  elseif name == 'bouncer' then
    return Bouncer:New(opts)
  elseif name == 'cannon' then
    return Cannon:New(opts)   
	elseif name == 'bullet' then
    return Bullet:New(opts)
	elseif name == 'missle' then
    return Missle:New(opts)    
  end
end
