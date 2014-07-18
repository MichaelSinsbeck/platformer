-- This script will return a table with all the user/level pairs.
-- Intended to be run in a background thread.
--
local http = require("socket.http")

local mainURL = require("scripts/url")
mainURL = mainURL .. "userlevels/"

function getLevelNames( authorizationLevel )
	local url = mainURL .. "listAuthorized.php"

	if authorizationLevel == "unauthorized" then
		url = mainURL .. "listUnauthorized.php"
	end

	print("loading:", url)
	local response, statusCode, responseHeaders, statusLine = http.request( url )

	if response then
		return true, response
	else
		return false, "Could not open URL."
	end
end
