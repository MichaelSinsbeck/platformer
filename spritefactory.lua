require 'player'
require 'runner'
require 'goalie'
require 'spikey'
require 'bouncer'
require 'cannon'
require 'bullet'
require 'launcher'
require 'missile'


function initAll()
  -- Run initializing code on all prototypes
  -- This sets height and width according to the image
  Runner:init()
  Goalie:init()
  Spikey:init()
  Player:init()
  Bouncer:init()
  Cannon:init()
  Bullet:init()
  Launcher:init()
  Missile:init()
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
