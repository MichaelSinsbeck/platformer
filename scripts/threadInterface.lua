-- The interface to running a function in a new thread.
-- This interface handles creating, destroying and communicating with the thread.
-- threads.update has to be called once every frame (if there are threads active).
--
local threadInterface = {}
local threadList = {}

-- Creates a new thread, starts it and adds it to the 
-- list of threads:
function threadInterface.new( name, script, functionName, eventSuccess, eventFail, ... )
	local t = {}
	t.thread = love.thread.newThread( "scripts/thread.lua" )
	t.statusChannel = love.thread.newChannel()	-- used for sending data out of the thread
	t.printChannel = love.thread.newChannel() -- used for receiving prints from inside the thread
	t.name = name
	t.eventSuccess = eventSuccess
	t.eventFail = eventFail

	table.insert( threadList, t )

	-- start the thread and pass the relevant data to it as you do so:
	t.thread:start( t.statusChannel, t.printChannel, script, functionName, unpack({...}) )
end

-- Check for new messages and errors on all active threads
function threadInterface.update( dt )
	local toRemove = {}
	for i, t in ipairs( threadList ) do
		local err = t.thread:getError()
		if err then
			print( "Error in thread: " .. t.name .. "\n\t" .. err )
			table.insert( toRemove, i )
		end
		while t.printChannel:peek() do
			local msg = t.printChannel:pop()
			print( "Thread " .. t.name .. ": " .. msg )
		end

		-- Check if the script has finished:
		local status = t.statusChannel:pop()
		if status then
			if status == "success" then
				print( "Thread " .. t.name .. " returned successfully!" )
				if t.eventSuccess then
					t.eventSuccess()
				end
				table.insert( toRemove, i )
			end
			if status == "failed" then
				print( "Thread " .. t.name .. " failed!" )
				if t.eventFail then
					t.eventFail()
				end
				table.insert( toRemove, i )
			end
		end
	end

	-- Remove all of the given threads from the list:
	for k, i in pairs(toRemove) do
		threadInterface.removeThreadByIndex( i )
	end
end

function threadInterface.removeThreadByIndex( index )
	table.remove( threadList, index )
end


return threadInterface
