-- Used to represent and manage user levels which are being downloaded.

local Userlevel = {}
Userlevel.__index = Userlevel

function Userlevel:new( levelname, author, authorized )
	local o = {}
	setmetatable( o, Userlevel )
	o.authorized = authorized or false
	o.levelname = levelname
	o.author = author

	-- construct the file name as it must be on the server:
	if o.authorized then
		o.filename = "userlevels/authorized/" .. author .. "/" .. levelname .. ".dat"
	else
		o.filename = "userlevels/unauthorized/" .. author .. "/" .. levelname .. ".dat"
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
end

function Userlevel:getIsDownloaded()
	return love.filesystem.exists( self.filename )
end

function Userlevel:finishedDownloading( data )
	love.filesystem.write( self.filename, data )
end

function Userlevel:loadDescription()

end

return Userlevel
