require 'player'
require 'runner'
require 'goalie'
require 'spikey'


function initAll()
  -- Run initializing code on all prototypes
  -- This sets height and width according to the image
  Runner:init()
  Goalie:init()
  Spikey:init()
  Player:init()
end

function spriteFactory(name,opts)
  if name == 'runner' then
    return Runner:New(opts);
  elseif name == 'player' then
    return Player:New(opts);
  end
end
