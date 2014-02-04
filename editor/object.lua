local Object = {}

function Object:init()

	local list = {}

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

	return list
end

return Object
