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


function initAll()
  -- Run initializing code on all prototypes
  -- This sets height and width according to the image
  Runner:init()
  Goalie:init()
  Spikey:init()
  Player:init()
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