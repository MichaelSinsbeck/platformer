local sound = {sources = {},event2file={},longSounds={},eventVolume = {},eventDistance = {}}

-- sources is a table of sources: key = filename, value = source
-- event2file is a table of sounds: key = sound/event, value = filename
-- longSounds: key:object (from spriteEngine), value: source

local attenuationModel = 'linear clamped'
local dist_ref = 2
--local dist_max = 10
local roll_off = 1
local doppler = 1
love.audio.setDistanceModel(attenuationModel)

-- add a sound to the database, the ... are filenames.
function sound:add(name,volume,maxDistance,...)
	if not self.event2file[name] then
			self.event2file[name] = {}
	end
	self.eventVolume[name] = volume
	self.eventDistance[name] = maxDistance
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

function sound:playLongSound(event,object,volume,pitch)
	-- first check if the object has a sound already and if yes it if is the same
	local thisFilename
	if self.event2file[event] then
		thisFilename = self.event2file[event][1]
	end
	if not thisFilename then
		return
	end
	
	if not self.longSounds[object] then
		self.longSounds[object] = {}
	end
	if self.longSounds[object].filename ~= thisFilename then -- sound changed
		if self.longSounds[object].source then
			self.longSounds[object].source:stop()
		end
		local newSource = getFreeSource(thisFilename)
		newSource:setLooping(true)
		newSource:setAttenuationDistances(dist_ref,self.eventDistance[event])
		
		newSource:play()
		
		self.longSounds[object].source = newSource
		self.longSounds[object].filename = thisFilename
	end
	
	-- apply volume and pitch
	volume = volume or 1
	volume = math.min(volume,1) * self.eventVolume[event]
	pitch = pitch or 1
	self.longSounds[object].source:setVolume(volume)
	self.longSounds[object].source:setPitch(pitch)
	
end

function sound:stopLongSound(object)
	if self.longSounds[object] then
		self.longSounds[object].source:stop()
		self.longSounds[object] = nil
	end
end

function sound:stopAllLongSounds()
	for obj, v in pairs(self.longSounds) do
		v.source:stop()
	end
	self.longSounds = {}
end

function sound:pauseLongSounds()
	for obj, v in pairs(self.longSounds) do
		v.source:pause()
	end
end

function sound:resumeLongSounds()
	love.audio.resume()
end

function sound:setListener(object)
	local x = object.x or 0
	local y = object.y or 0
	local vx = object.vx or 0
	local vy = object.vy or 0
	love.audio.setPosition(x,y,0)
	--love.audio.setVelocity(doppler*vx,doppler*vy,0)
end

function sound:setPositions()
	for object, v in pairs(self.longSounds) do
		local x = object.x or 0
		local y = object.y or 0
		local vx = object.vx or 0
		local vy = object.vy or 0
		
		v.source:setPosition(x,y,0)
		v.source:setVelocity(doppler*vx,doppler*vy,0)
	end
end

function sound:play(event,volume,pitch,variance)
	local thisFilename = getRandomFilename(event)
	volume = volume or 1
	pitch = pitch or 1
	if variance then
		pitch = pitch * math.exp(variance * love.math.randomNormal())
	end
	if thisFilename then
		local newSource = getFreeSource(thisFilename)	
		newSource:stop()
		newSource:setLooping(false)
		newSource:setAttenuationDistances(dist_ref,self.eventDistance[event])
		newSource:setPosition(0,0,0)
		newSource:setVelocity(0,0,0)
		newSource:setRelative(true)
		newSource:setVolume(self.eventVolume[event]*volume)
		newSource:setPitch(pitch)
		newSource:play()
		return newSource
	else
		print('Sound file missing for event: ' .. event)
	end
end

function sound:playSpatial(sound,x,y,volume,pitch,variance)
	local newSource = self:play(sound,volume,pitch,variance)
	if newSource then
		local lx,ly,lz = love.audio.getPosition()
		-- doing the relative calculations by hand turns of doppler effect for short sounds
		newSource:setPosition(x-lx,y-ly,0)
		newSource:setRelative(true)
	end
end

function sound:stopAll()
	love.audio.stop()
	self.clean()
end

function sound:clear()
	self.sources = {}
	self.event2file = {}
	self.longSounds = {}
	love.audio.stop()
end


-- volume goes from 0 to 1
function sound:setMusicVolume(volume)
	print( "Music volume set to " .. volume )
end
function sound:setSoundVolume(volume)
	print( "Effect volume set to " .. volume )
end

return sound
