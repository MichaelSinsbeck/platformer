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
	properties[new.name] = {
		colour = {
			current = 1,
			values = {"red", "green", "blue", "white"},
			names = {"red", "green", "blue", "white"},
			changeEvent = function( object, newValue ) print("colour changed:", newValue, object ) end,
		},
	}

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
	properties[new.name] = {
		angle = {
			current = 1,
			values = {0, 0.5*math.pi, math.pi, -0.5*math.pi},
			names = {"0", "90", "180", "270" },
			changeEvent = function( object, newValue ) print("angle changed:", newValue, object ) end,
		},
	}

	return list, properties
end

return Object
