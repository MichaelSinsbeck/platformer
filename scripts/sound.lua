local sound = {sources = {},sounds={},playing={}}

-- sources is a table of sources: key = filename, value = source
-- sounds is a table of sounds: key = sound/event, value = filename
-- playing is the table of sounds that are currently playing

function sound:add(name,...)

	if not self.sounds[name] then
			self.sounds[name] = {}
	end
	local arg = {...}
	for k,filename in pairs(arg) do
		-- load the file to the sources, it not done already
		if not self.sources[filename] then
			self.sources[filename] = love.audio.newSource( 'sounds/' .. filename, 'static' )
		end
		-- and insert into the list of sounds
		table.insert(self.sounds[name],filename)
	end
	
end


function sound:play(sound)
	if not self.sounds[sound] then
		return
	end
	local nPossibilities = #self.sounds[sound]
	local randomNumber = love.math.random(nPossibilities)
	local thisFilename = self.sounds[sound][randomNumber]
	local newSource = self.sources[thisFilename]:clone()
	newSource:stop()
	newSource:play()
	table.insert(self.playing,newSource)
end

function sound:clean()
	for i = #self.playing,1,-1 do
		if self.playing[i]:isStopped() then
			table.remove(self.playing,i)
		end
	end
end

function sound:stopAll()
	for k,v in pairs(self.sounds) do
		v:stop()
	end
end

function sound:clear()
	self.sources = {}
	self.sounds = {}
	love.audio.stop()
end

return sound
