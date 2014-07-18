-- This script will send a new rating to the server.
-- Intended to be run in a background thread.

local http = require("socket.http")

local mainURL = require("scripts/url")
mainURL = mainURL .. "userlevels/rate.php"

function rate( levelname, author, ratingFun, ratingDifficulty )
	local url = mainURL .. "?author=" .. author
	url = url .. "&level=" .. levelname
	url = url .. "&fun=" .. ratingFun
	url = url .. "&difficulty=" .. ratingDifficulty

	print("loading:", url)
	local response, statusCode, responseHeaders, statusLine = http.request( url )
	print(resonse, statusCode, responseHeaders, statusLine )

	if response then
		return true, response
	else
		return false, "Could not open URL."
	end
end
