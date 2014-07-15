-- This shall be the starting point for all background threads.
-- This script is started as a thread. Then arguments are passed to it,
-- the channels it uses to communicate and the name of the script it should execute.
-- For now, all scripts that should be executed in backgroun threads are (blocking) html requests.
-- The printChannel is for printing messages to the standard console, the statusChannel is used for status updates. Once "success" or "failed" is send thorugh the statusChannel, the game considers this thread to be done running.
-- Once the script has finished, this thread sends back info to the main thread and terminates.
--
-- IMPORTANT! Any scripts called by this should return 'false' and an error message upon failure, which will then be passed back to the main thread. The main thread expects such a failure message, if it's not supplied, it will wait forever.
require("scripts/threadUtils")

local args = {...}

statusChannel = args[1]
printChannel = args[2] -- should be global!
resultsChannel = args[3] -- should be global!
scriptFile = args[4] -- should be global!
functionName = args[5]

-- Load the given script.
dofile(scriptFile)

-- Execute the function. Since it has been loaded and is global, it should now be in _G:
local result, msg = _G[functionName]( args[6], args[7], args[8], args[9], args[10] )

if result then
	if msg then
		resultsChannel:push( msg )
	end
	statusChannel:push("success")
else
	statusChannel:push("failed")
	if not msg then
		msg = "Unknown error"	-- msg is needed, so in case there is none, use this default error.
	end
	statusChannel:push( msg )	-- supply reason for failing to parent threat.
end

