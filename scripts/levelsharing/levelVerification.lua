-- Script used to verify a level file. This script should be run on the client before sending a file
-- and on the server after receiving a file.
-- Script takes in the filename and returns either true or false and the error message.
--
-- Note:
--	- Path given should be absolute path!
--	- Script uses io instead of love.filesystem so that it does not require love to run on server
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

return levelVerification
