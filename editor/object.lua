local Object = {}

function Object:init()

	local list = {}
	local properties = {}

	local new

	new = spriteFactory("player")
	new:init()
	table.insert( list, new )

	new = spriteFactory("exit")
	new:init()
	table.insert( list, new )
	
	new = spriteFactory("spikey")
	new:init()
	table.insert( list, new )

	new = spriteFactory("bouncer")
	new:init()
	table.insert( list, new )

	new = spriteFactory("cannon")
	new:init()
	table.insert( list, new )

	new = spriteFactory("button")
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

	return list, properties
end

return Object
