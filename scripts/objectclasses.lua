-- make the base class global
object = require 'scripts/objects.object'

-- insert all other object classes into a local table
local objectClasses = {
Player = require 'scripts/objects.player',
Imitator = require 'scripts/objects.imitator',
Runner = require 'scripts/objects.runner',
Goalie = require 'scripts/objects.goalie',
Spikey = require 'scripts/objects.spikey',
Bouncer = require 'scripts/objects.bouncer',
--Medusa = require 'scripts/objects.medusa',
--MedusaSpawner = require 'scripts/objects.medusaSpawner',
Shuriken = require 'scripts/objects.shuriken',
Cannon = require 'scripts/objects.cannon',
Launcher = require 'scripts/objects.launcher',
Missile = require 'scripts/objects.missile',
Explosion = require 'scripts/objects.explosion',
Bandana = require 'scripts/objects.bandana',
Poff = require 'scripts/objects.poff',
Smoke = require 'scripts/objects.smoke',
Woosh = require 'scripts/objects.woosh',
Line = require 'scripts/objects.line',
LineHook = require 'scripts/objects.lineHook',
Particle = require 'scripts/objects.particle',
Windmill = require 'scripts/objects.windmill',
Button = require 'scripts/objects.button',
Appearblock = require 'scripts/objects.appearblock',
Winddot = require 'scripts/objects.winddot',
Bubble = require 'scripts/objects.bubble',
Crumbleblock = require 'scripts/objects.crumbleblock',
Glassblock = require 'scripts/objects.glassblock',
Fixedcannon = require 'scripts/objects.fixedcannon',
-- Butterfly = require 'scripts/objects.butterfly',
Meat = require 'scripts/objects.meat',
Exit = require 'scripts/objects.exit',
Bungee = require 'scripts/objects.bungee',
Door = require 'scripts/objects.door',
Keyhole = require 'scripts/objects.keyhole',
Key = require 'scripts/objects.key',
Bumper = require 'scripts/objects.bumper',
--Clubber = require 'scripts/objects.clubber',
--Light = require 'scripts/objects.light',
Bonus = require 'scripts/objects.bonus',
--Input = require 'scripts/objects.input',
Walker = require 'scripts/objects.walker',
Spawner = require 'scripts/objects.spawner',
Water = require 'scripts/objects.water',
Droplet = require 'scripts/objects.droplet',
Rock = require 'scripts/objects.rock',
Bean = require 'scripts/objects.bean',
Rotator = require 'scripts/objects.rotator',
Npc = require 'scripts/objects.npc',
Text = require 'scripts/objects.text',
TimedText = require 'scripts/objects.timedText',
CameraGuide = require 'scripts/objects.cameraguide',
CameraGuideRect = require 'scripts/objects.cameraguiderectangle',
ParallaxConfig = require 'scripts/objects.parallaxConfig',
Upwind = require 'scripts/objects.upwind',
Anchor = require 'scripts/objects.anchor',
Follower = require 'scripts/objects.follower',
Laser = require 'scripts/objects.laser',
}


function initAll()
  -- Run initializing code on all prototypes
  -- This sets height and width according to the image
	for name, class in pairs(objectClasses) do
		if class.init then
			class:init()
		end
	end
end

function spriteFactory(name,opts)
	if objectClasses[name] then
		local new = objectClasses[name]:New(opts)
		if new.init then
			new:init()
		end
		return new
	end
end
--[[
function spriteFactory(name,opts)
	local new
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
	elseif name == 'door' then
		new = Door:New(opts)    
	elseif name == 'key' then
		new = Key:New(opts)    
	elseif name == 'keyhole' then
		new = Keyhole:New(opts)    
	elseif name == 'fixedcannon' then
		new = FixedCannon:New(opts)    
	end
	if new then
		new.name = name
	end
	return new
end]]


return objectClasses
