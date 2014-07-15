-- This script will return a table with all the user/level pairs.
-- Intended to be run in a background thread.
--
local http = require("socket.http")

local mainURL = "http://www.germanunkol.de/bandana/userlevels/"

function getLevel( levelname, author, authorized )
	local url = mainURL .. "authorized/"

	if authorized ~= true then
		url = mainURL .. "unauthorized/"
	end

	url = url .. author .. "/" .. levelname .. ".dat"

	print("loading:", url)
	local response, statusCode, responseHeaders, statusLine = http.request( url )
	print(resonse, statusCode, responseHeaders, statusLine )

	if response and tonumber(statusCode) >= 400 then	-- errors like 403, 404, 504 etc:
		print("error...")
		return false, response
	end

	if response then
		return true, response
	else
		return false, "Could not open URL."
	end
end
