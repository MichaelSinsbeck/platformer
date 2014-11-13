local UserlevelSubmenu = {}

local userlevelFilters
local sortingSchemes = {
	"Levelname ascending",
	"Levelname descending",
	"Author ascending",
	"Author descending",
	"Fun rating ascending",
	"Fun rating descending",
	"Difficulty rating ascending",
	"Difficulty rating descending",
}

local Submenu = require( "scripts/menu/submenu" )

function UserlevelSubmenu:new()
	local width = love.graphics.getWidth()/Camera.scale - 16
	local height = love.graphics.getHeight()/Camera.scale - 32

	local submenu = Submenu:new()
	submenu:addPanel( -width/2, -height/2 - 8, width, height )
	submenu:addLayer( "Filters" )
	submenu:addPanel( -width/2 + 8, 0, width - 16, height/2 - 8, "Filters" )

	submenu.selectedUserlevel = 1
	submenu.firstDisplayedUserlevel = 1

	submenu.userlevels = {}
	submenu.userlevelsByAuthor = {}
	submenu.userlevelsFiltered = {}

	-- Only load settings when starting the userlevel list for the first time:
	if not self.userlevelFilters then
		userlevelFilters = {
			sorting = 1,
			authorizedOnly = true,
			downloadedOnly = false,
		}
		submenu.loadedUserlevelFilters = true
		local val
		val = config.getValue( "LevelsFilterAuthorized" )
		if val ~= nil then userlevelFilters.authorizedOnly = val end
		--val = config.getValue( "LevelsFilterDownloaded" )
		--if val ~= nil then userlevelFilters.downloadedOnly = val end
		val = config.getValue( "LevelsSorting" )
		if val ~= nil then
			userlevelFilters.sorting =
				math.min(math.max(math.floor(tonumber(val)), 1), #sortingSchemes )
		end
	end

	return menu
end


-- Load a list of all levels which have already been downloaded previously and are available
-- locally
--[[function UserlevelSubmenu:loadDownloadedUserlevels()
	local list = love.filesystem.getDirectoryItems( "userlevels/authorized/" )
	for i, author in pairs(list) do
		local levels = love.filesystem.getDirectoryItems( "userlevels/authorized/" .. author )
		for j, levelname in pairs(levels) do
			local newLevel = Userlevel:new( levelname:sub(1,#levelname-4), author, 0, 0, true )
			UserlevelSubmenu:insertUserlevelIntoList( newLevel )
		end
	end

	list = love.filesystem.getDirectoryItems( "userlevels/unauthorized/" )
	for i, author in pairs(list) do
		local levels = love.filesystem.getDirectoryItems( "userlevels/unauthorized/" .. author )
		for j, levelname in pairs(levels) do
			local newLevel = Userlevel:new( levelname:sub(1,#levelname-4), author, 0, 0, false )
			UserlevelSubmenu:insertUserlevelIntoList( newLevel )
		end
	end
	UserlevelSubmenu:applyUserlevelFilters()
end]]

function UserlevelSubmenu:applyUserlevelFilters()
	--[[
	if userlevelFilterBox and userlevelFilterBox.visible then
		menu:hideUserlevelFilters()
	end

	userlevelsFiltered = {}

	-- Go through all levels and see if they fullfill the filter requirements:
	for k,level in pairs(userlevels) do
		local skip = false
		if userlevelFilters.authorizedOnly == true then
			if level.authorized ~= true then
				skip = true
			end
		end
		if userlevelFilters.downloadedOnly == true then
			if level:getIsDownloaded() ~= true then
				skip = true
			end
		end
		if userlevelFilters.searchText then
			local containsStr = string.lower( level.levelname ):find( userlevelFilters.searchText ) or 
								string.lower( level.author ):find( userlevelFilters.searchText )
			print(level.levelname, level.author, userlevelFilters.searchText, containsStr)
			if not containsStr then
				skip = true
				print("\tskipping")
			end
		end

		if not skip then
			table.insert( userlevelsFiltered, level )
		end
	end

	local sorting = sortingSchemes[userlevelFilters.sorting]
	if sorting == "Levelname ascending" then
		table.sort( userlevelsFiltered, Userlevel.sortByNameAscending )
	elseif sorting == "Levelname descending" then
		table.sort( userlevelsFiltered, Userlevel.sortByNameDescending )
	elseif sorting == "Author ascending" then
		table.sort( userlevelsFiltered, Userlevel.sortByAuthorAscending )
	elseif sorting == "Author descending" then
		table.sort( userlevelsFiltered, Userlevel.sortByAuthorDescending )
	elseif sorting == "Fun rating ascending" then
		table.sort( userlevelsFiltered, Userlevel.sortByFunAscending )
	elseif sorting == "Fun rating descending" then
		table.sort( userlevelsFiltered, Userlevel.sortByFunDescending )
	elseif sorting == "Difficulty rating ascending" then
		table.sort( userlevelsFiltered, Userlevel.sortByDifficultyAscending )
	elseif sorting == "Difficulty rating descending" then
		table.sort( userlevelsFiltered, Userlevel.sortByDifficultyDescending )
	end

	-- Adjust list view in case less levels are shown than before:
	menu.firstDisplayedUserlevel = 1
	menu.selectedUserlevel = 1
	userlevelFilters.searchText = nil	-- reset previous
	if buttonCenter then selectButton( buttonCenter ) end

	config.setValue( "LevelsFilterAuthorized", userlevelFilters.authorizedOnly )
	--config.setValue( "LevelsFilterDownloaded", userlevelFilters.downloadedOnly )
	config.setValue( "LevelsSorting", userlevelFilters.sorting )]]
end


return UserlevelSubmenu
