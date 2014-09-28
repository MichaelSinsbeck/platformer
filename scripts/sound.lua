local sound = {sources = {},event2file={},longSounds={}}

-- sources is a table of sources: key = filename, value = source
-- event2file is a table of sounds: key = sound/event, value = filename
-- longSounds: key:object (from spriteEngine), value: source

-- add a sound to the database, the ... are filenames.
function sound:add(name,...)
	if not self.event2file[name] then
			self.event2file[name] = {}
	end
	local arg = {...}
	for k,filename in pairs(arg) do
		-- load the file to the sources, it not done already
		if not self.sources[filename] then
			self.sources[filename] = {love.audio.newSource( 'sounds/' .. filename, 'static' )}
		end
		-- and insert into the list of sounds
		table.insert(self.event2file[name],filename)
	end
	
end

-- check in the source-pool for a free source and return it
-- if no free source is available, then clone one
local function getFreeSource(filename)
	if sound.sources[filename] and #sound.sources[filename] > 0 then
		for i,theSource in ipairs(sound.sources[filename]) do
			if theSource:isStopped() then
				return theSource
			end
		end
		-- no stopped source exists: create one
		local newSource = sound.sources[filename][1]:clone()
		return newSource
	end
end

local function getRandomFilename(event)
	if not sound.event2file[event] then
		return
	end
	local nPossibilities = #sound.event2file[event]
	local randomNumber = love.math.random(nPossibilities)
	return sound.event2file[event][randomNumber]
end

function sound:playSpatial(sound,x,y)
	local newSource = self.play(sound)
	newSource:setPosition(x,y,0)
	newSource:setVelocity(0,0,0)
end

function sound:playLongSound(sound,object)
	-- first check if the object has a sound already and if yes it if is the same
	local thisFilename = self.event2file[sound][1]
	
	if not self.longSounds[object] then
		self.longSounds[object] = {}
	end
	if self.longSounds[object].filename ~= thisFilename then
		if self.longSounds[object].source then
			self.longSounds[object].source:stop()
		end
		local newSource = getFreeSource(thisFilename)
		newSource:setLooping(true)
		newSource:play()
		
		self.longSounds[object].source = newSource
		self.longSounds[object].filename = thisFilename
	end
end

function sound:stopLongSound(object)
	if self.longSounds[object] then
		self.longSounds[object].source:stop()
		self.longSounds[object] = nil
	end
end

function sound:play(sound)
	local thisFilename = getRandomFilename(sound)

	local newSource = getFreeSource(thisFilename)	
	newSource:stop()
	newSource:play()
	return newSource
end

function sound:stopAll()
	love.audiot.stop()
	self.clean()
	--for k,v in pairs(self.event2file) do
	--	v:stop()
	--end
end

function sound:clear()
	self.sources = {}
	self.event2file = {}
	love.audio.stop()
end

return sound
