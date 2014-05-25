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

local levelVerification = {}

function levelVerification.checkFile( filename )
	local f, message = io.open( filename, "r" )
	if not f then
		return false, message
	end

	local content = f:read( "*all" )
	if not content then
		return false, "Empty file."
	end

	local dimX,dimY = content:match("Dimensions: (.-),(.-)\n")
	local maxX, maxY = tonumber(dimX), tonumber(dimY)
	local author = content:match("Author: (.-)\n")
	local description = content:match("Description:\n(.+)\n?endDescription\n")
	local bg = content:match("Background:(.+)endBackground\n")
	local ground = content:match("Ground:(.+)endGround\n")
	local bgObjects = content:match("BgObjects:(.+)endBgObjects\n")
	local objects = content:match("Objects:(.+)endObjects\n")

	-- Check if all required fields have been set:
	if not dimX or not dimY then
		return false, "Dimensions not found in level file."
	end
	if not author then
		return false, "Author not found in level file."
	end
	if not bg then
		return false, "No background found in level file."
	end
	if not ground then
		return false, "No ground/walls found in level file."
	end
	if not bgObjects then
		return false, "No background object list found in level file."
	end
	if not ground then
		return false, "No object list found in level file."
	end

	-- Check if description is too long:
	if description and #description > 200 then
		return false, "Description is too long!"
	end

	-- Check if dimensions of map are correct:
	local x, y = 0, 0
	for line in ground:gmatch("(.-)\n") do
		y = y + 1
		x = math.max( x, #line )
	end
	if x > maxX then
		return false, "Level is wider than the header claims."
	end
	if y > maxY then
		return false, "Level is higher than the header claims."
	end

	x, y = 0, 0
	for line in bg:gmatch("(.-)\n") do
		y = y + 1
		x = math.max( x, #line )
	end
	if x > maxX then
		return false, "Level is wider than the header claims."
	end
	if y > maxY then
		return false, "Level is higher than the header claims."
	end

	local playersFound, flagsFound = 0, 0
	for obj in objects:gmatch( "(Obj:.-endObj)\n" ) do			
		objType = obj:match( "Obj:(.-)\n")
		if objType == "Player" then
			playersFound = playersFound + 1
		elseif objType == "Exit" then
			flagsFound = flagsFound + 1
		end
	end
	if playersFound == 0 then
		return false, "No player found on map."
	elseif playersFound > 1 then
		return false, "Too many players on map."
	end
	if flagsFound == 0 then
		return false, "Need a flag object in level."
	end

	-- TODO: Possibly add other checks here

	-- File is a complete level:
	return true
end

-- If command line arguments are given, then use those:
-- (Otherwise, wait for someone to call the checkFile function.)
if args then
	if args[1] then
		return levelVerification.checkFile( arg[1] )
	end
end

return levelVerification
