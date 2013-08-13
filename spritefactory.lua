require 'objects.player'
require 'objects.imitator'
require 'objects.runner'
require 'objects.goalie'
require 'objects.spikey'
require 'objects.bouncer'
require 'objects.shuriken'
require 'objects.cannon'
require 'objects.launcher'
require 'objects.missile'
require 'objects.explosion'
require 'objects.bandana'
require 'objects.poff'
require 'objects.line'
require 'objects.particle'
require 'objects.windmill'
require 'objects.button'
require 'objects.appearblock'
require 'objects.emitter'
require 'objects.winddot'
require 'objects.bubble'
require 'objects.crumbleblock'
require 'objects.glassblock'
require 'objects.fixedcannon'
require 'objects.butterfly'
require 'objects.meat'


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
