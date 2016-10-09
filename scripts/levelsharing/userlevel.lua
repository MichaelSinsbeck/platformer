-- Used to represent and manage user levels which are being downloaded.

local Userlevel = {}
Userlevel.__index = Userlevel

function Userlevel:new( levelname, author, ratingFun, ratingDifficulty, authorized )
	local o = {}
	setmetatable( o, Userlevel )
	o.authorized = authorized or false
	o.levelname = levelname
	o.author = author

	o.downloaded = false

	o.ratingFun = math.floor(ratingFun + 0.5)
	o.ratingDifficulty = math.floor(ratingDifficulty + 0.5)

	-- construct the file name as it must be on the server:
	if o.authorized then
		o.filename = "userlevels/authorized/" .. author .. "/" .. levelname .. ".dat"
	else
		o.filename = "userlevels/unauthorized/" .. author .. "/" .. levelname .. ".dat"
	end

	if love.filesystem.exists( o.filename ) then
		o.downloaded = true
	end

	local visName = 'stars' .. o.ratingFun
	o.ratingFunVis = Visualizer:New( visName )
	o.ratingFunVis:init()
	visName = 'skulls' .. o.ratingDifficulty
	o.ratingDifficultyVis = Visualizer:New( visName )
	o.ratingDifficultyVis:init()

	o.statusVis = Visualizer:New( "userlevelDownload" )
	o.statusVis:init()
	if o.downloaded then
		o.statusVis:setAni( "userlevelPlay" )
		o.statusVis:update(0)
	end

	o.authorizationVis = Visualizer:New( "authorizationFalse" )
	o.authorizationVis:init()
	if o.authorized then
		o.authorizationVis:setAni( "authorizationTrue" )
		o.authorizationVis:update(0)
	end

	return o
end

function Userlevel:download()

	if self.currentlyDownloading then return end

	local returnEvent = function( data )
		self:finishedDownloading( data )
	end
	local failedEvent = function( msg )
		self:failedDownloading( msg )
	end
	--menu:setStatusMsg( "Downloading level " .. self.levelname, -1)
	threadInterface.new( self.levelname, "scripts/levelsharing/download.lua", "getLevel",
			returnEvent, failedEvent, self.levelname, self.author, self.authorized )

	self.statusVis:setAni( "userlevelBusy" )
	self.statusVis:update(0)

	self.currentlyDownloading = true
end

function Userlevel:getIsDownloaded()
	return self.downloaded
end

function Userlevel:finishedDownloading( data )
	if self.authorized then
		love.filesystem.createDirectory("userlevels/authorized/" .. self.author )
	else
		love.filesystem.createDirectory("userlevels/unauthorized/" .. self.author )
	end
	love.filesystem.write( self.filename, data )
	--menu:setStatusMsg( self.levelname .. " can now be played.", 5)
	self.downloaded = true
	self.currentlyDownloading = false

	self.statusVis:setAni( "userlevelPlay" )
	self.statusVis:update(0)

	--menu:updateTextForCurrentUserlevel()	--display name of currently selected level
end
function Userlevel:failedDownloading( msg )
	print("Couldn't download " .. self.filename .. ". Reason: " .. msg )

	self.downloaded = false
	self.currentlyDownloading = false

	self.statusVis:setAni( "userlevelError" )
	self.statusVis:update(0)

	--menu:updateTextForCurrentUserlevel()	--display name of currently selected level
end

function Userlevel:deleteLocalContent()
	love.filesystem.remove( self.filename )
	self.downloaded = false

	--menu:updateTextForCurrentUserlevel()	--display name of currently selected level

	self.statusVis:setAni( "userlevelDownload" )
	self.statusVis:update(0)
end

function Userlevel:loadDescription()
end

function Userlevel:authorize()

	local visName = 'stars' .. o.ratingFun
	o.ratingFunVis = Visualizer:New( visName )
	o.ratingFunVis:init()
	visName = 'skulls' .. o.ratingDifficulty
	o.ratingDifficultyVis = Visualizer:New( visName )
	o.ratingDifficultyVis:init()

	o.statusVis = Visualizer:New( "userlevelDownload" )
	o.statusVis:init()
	if o.downloaded then
		o.statusVis:setAni( "userlevelPlay" )
		o.statusVis:update(0)
	end

	o.authorizationVis = Visualizer:New( "authorizationFalse" )
	o.authorizationVis:init()
	if o.authorized then
		o.authorizationVis:setAni( "authorizationTrue" )
		o.authorizationVis:update(0)
	end
end

function Userlevel:play()
	if not self.downloaded then return end

	--menu.startTransition( menu.startGame( self.filename ), false )()
	menu:startGame( self.filename )()
end

function Userlevel.sortByAuthorAscending( a, b )
	if a and b then
		local author_a, author_b = string.lower(a.author), string.lower(b.author)
		if author_a > author_b then
			return true
		else
			if author_a == author_b then
				if string.lower(a.levelname) < string.lower(b.levelname) then
					return true
				end
			end
		end
	end
	return false
end
function Userlevel.sortByAuthorDescending( a, b )
	if a and b then
		local author_a, author_b = string.lower(a.author), string.lower(b.author)
		if author_a > author_b then
			return true
		else
			if author_a == author_b then
				if string.lower(a.levelname) < string.lower(b.levelname) then
					return true
				end
			end
		end
	end
	return false
end
function Userlevel.sortByNameAscending( a, b )
	if a and b then
		local name_a, name_b = string.lower(a.levelname), string.lower(b.levelname)
		if name_a < name_b then
			return true
		else
			if name_a == name_b then
				if string.lower(a.author) < string.lower(b.author) then
					return true
				end
			end
		end
	end
	return false
end
function Userlevel.sortByNameDescending( a, b )
	if a and b then
		local name_a, name_b = string.lower(a.levelname), string.lower(b.levelname)
		if name_a > name_b then
			return true
		else
			if name_a == name_b then
				if string.lower(a.author) < string.lower(b.author) then
					return true
				end
			end
		end
	end
	return false
end
function Userlevel.sortByFunAscending( a, b )
	if a and b then
		if a.ratingFun < b.ratingFun then
			return true
		else
			if a.ratingFun == b.ratingFun then
				if a.levelname < b.levelname then
					return true
				end
			end
		end
	end
	return false
end
function Userlevel.sortByFunDescending( a, b )
	if a and b then
		if a.ratingFun > b.ratingFun then
			return true
		else
			if a.ratingFun == b.ratingFun then
				if a.levelname < b.levelname then
					return true
				end
			end
		end
	end
	return false
end
function Userlevel.sortByDifficultyAscending( a, b )
	if a and b then
		if a.ratingDifficulty < b.ratingDifficulty then
			return true
		else
			if a.ratingDifficulty == b.ratingDifficulty then
				if a.levelname < b.levelname then
					return true
				end
			end
		end
	end
	return false
end
function Userlevel.sortByDifficultyDescending( a, b )
	if a and b then
		if a.ratingDifficulty > b.ratingDifficulty then
			return true
		else
			if a.ratingDifficulty == b.ratingDifficulty then
				if a.levelname < b.levelname then
					return true
				end
			end
		end
	end
	return false
end
return Userlevel
