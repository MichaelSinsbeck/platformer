-- Script used to verify a level file.
-- This script should be run on the client before sending a file
-- and on the server after receiving a file.
-- Script takes in the filename and returns either true or false and the error message.
-- On the server, the filename can be passed as a command line argument. On the client,
-- the function checkFile should be called.
--
-- Note:
--	- Path given should be absolute path!
--	- Script uses io instead of love.filesystem (to avoid depending on Löve on server )
--
-- Checks performed by this file:
-- - level can be loaded
--

local levelVerification = {}

function levelVerification.checkFile( filename )
	local f, message = io.open( filename, "r" )
	if not f then
		return false, message
	end

	-- TODO: Other checks here

	-- File is a complete level:
	return true
end

-- If command line arguments are given, then use those:
-- (Otherwise, wait for someone to call the checkFile function.
if arg[1] then
	return levelVerification.checkFile( arg[1] )
end

return levelVerification
