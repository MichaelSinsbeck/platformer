-- This shall be the starting point for all background threads.
-- This script is started as a thread. Then arguments are passed to it,
-- the channels it uses to communicate and the name of the script it should execute.
-- For now, all scripts that should be executed in backgroun threads are (blocking) html requests.
-- The printChannel is for printing messages to the standard console, the statusChannel is used for status updates. Once "success" or "failed" is send thorugh the statusChannel, the game considers this thread to be done running.
-- Once the script has finished, this thread sends back info to the main thread and terminates.
require("scripts/threadUtils")

local args = {...}

statusChannel = args[1]
printChannel = args[2] -- should be global!
scriptFile = args[3] -- should be global!
functionName = args[4]

-- Load the given script.
dofile(scriptFile)
--for k, v in pairs(_G) do
--	print("\t",k, v)
--end

-- Execute the function. Since it has been loaded and is global, it should now be in _G:
local result, msg = _G[functionName]( args[5], args[6], args[7], args[8], args[9] )

if result then
	statusChannel:push("success")
else
	statusChannel:push("failed")
	statusChannel:push( msg )		-- supply reason for failing to parent threat.
end

