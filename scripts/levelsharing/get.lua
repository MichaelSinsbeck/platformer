-- This script will return the contents of the given file on the server.
-- Intended to be run in a background thread.

local http = require("socket.http")

local mainURL = require("scripts/url")

function get( filename )
	local url = mainURL .. filename

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
