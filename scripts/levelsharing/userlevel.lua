-- Used to represent and manage user levels which are being downloaded.

local Userlevel = {}
Userlevel.__index = Userlevel

function Userlevel:new( levelname, author, authorized )
	local o = {}
	setmetatable( o, Userlevel )
	o.authorized = authorized or false
	o.levelname = levelname
	o.author = author

	o.downloaded = false

	o.ratingDifficulty = love.math.random( 5 )
	o.ratingFun = love.math.random( 5 )


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
	visName = 'stars' .. o.ratingDifficulty
	o.ratingDifficultyVis = Visualizer:New( visName )
	o.ratingDifficultyVis:init()

	o.statusVis = Visualizer:New( "userlevelDownload" )
	o.statusVis:init()
	if o.downloaded then
		o.statusVis:setAni( "userlevelPlay" )
		o.statusVis:update(0)
	end

	return o
end

function Userlevel:download()
	local returnEvent = function( data )
		self:finishedDownloading( data )
	end
	local failedEvent = function( msg )
		print("Couldn't download " .. self.filename .. ". Reason: " .. msg )
		menu:setStatusMsg( "Failed to download: " .. self.levelname )
	end
	menu:setStatusMsg( "Downloading level " .. self.levelname, -1)
	threadInterface.new( self.levelname, "scripts/levelsharing/download.lua", "getLevel",
			returnEvent, failedEvent, self.levelname, self.author, self.authorized )

	self.statusVis:setAni( "userlevelBusy" )
	self.statusVis:update(0)
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
	menu:setStatusMsg( self.levelname .. " can now be played.", 5)
	self.downloaded = true

		self.statusVis:setAni( "userlevelPlay" )
		self.statusVis:update(0)
end

function Userlevel:loadDescription()

end

function Userlevel:play()
	if not self.downloaded then return end

	menu.startTransition( menu.startGame( self.filename ), false )()
end

return Userlevel
