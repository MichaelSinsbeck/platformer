local Object = {}

function Object:init()

	local list = {}
	local properties = {}


	for name, class in pairs(objectClasses) do
		local new = class:New()
		if new.isInEditor then
			new:init()
			table.insert( list, new)
		end
	end
	
--[[
	new = spriteFactory("Player")
	new:init()
	table.insert( list, new )

	new = spriteFactory("Exit")
	new:init()
	table.insert( list, new )
	
	new = spriteFactory("Spikey")
	new:init()
	table.insert( list, new )

	new = spriteFactory("Bouncer")
	new:init()
	table.insert( list, new )

	new = spriteFactory("Cannon")
	new:init()
	table.insert( list, new )

	new = spriteFactory("Button")
	new:init()
	table.insert( list, new )

	new = spriteFactory("bandana")
	new:init()
	table.insert( list, new )

	new = spriteFactory("emitter")
	new:init()
	table.insert( list, new )

	new = spriteFactory("spawner")
	new:init()
	table.insert( list, new )

	new = spriteFactory("launcher")
	new:init()
	table.insert( list, new )

	new = spriteFactory("crumbleblock")
	new:init()
	table.insert( list, new )

	new = spriteFactory("appearblock")
	new:init()
	table.insert( list, new )

	new = spriteFactory("key")
	new:init()
	table.insert( list, new )

	new = spriteFactory("keyhole")
	new:init()
	table.insert( list, new )

	new = spriteFactory("door")
	new:init()
	table.insert( list, new )

	new = spriteFactory("fixedcannon")
	new:init()
	table.insert( list, new )
	
	new = spriteFactory("light")
	new:init()
	table.insert( list, new )

	new = spriteFactory("lamp")
	new:init()
	table.insert( list, new )

	new = spriteFactory("lineHook")
	new:init()
	table.insert( list, new )]]

	return list, properties
end

return Object
