local Object = {}

function Object:init()

	local list = {}

	local new

	new = {
		name = "player",
		objType = spriteFactory("player"),
	}
	new.objType:init()
	if new.objType.vis then
		new.width, new.height = new.objType.width, new.objType.height
	else
		new.width, new.height = 10,10
	end

	table.insert( list, new )

	new = {
		name = "exit",
		objType = spriteFactory("exit"),
	}
	new.objType:init()
	if new.objType.vis then
		new.width, new.height = new.objType.width, new.objType.height
	else
		new.width, new.height = 10,10
	end

	table.insert( list, new )
	
	new = {
		name = "spikey",
		objType = spriteFactory("spikey"),
	}
	new.invisible = true
	new.objType:init()
	if new.objType.vis then
		new.width, new.height = new.objType.width, new.objType.height
	else
		new.width, new.height = 10,10
	end

	table.insert( list, new )

	return list
end

return Object
