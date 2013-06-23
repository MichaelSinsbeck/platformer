require 'player'
require 'runner'
require 'goalie'
require 'spikey'
require 'bouncer'
require 'shuriken'
require 'cannon'

require 'launcher'
require 'missile'
require 'explosion'
require 'bandana'
require 'poff'


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
