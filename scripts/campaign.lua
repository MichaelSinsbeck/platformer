Campaign = {
	'l01.dat', -- world 1
	'l02.dat',
	'l03.dat',
	'l04.dat',	
	'l05.dat',
	'l06.dat', 
	'l09.dat', -- blue bandana
	'l16.dat',
	'l17.dat', -- cave
	'l18.dat',
	'l19.dat',
	'l20.dat',
	'l13.dat',
	'l21.dat',
	'l12.dat',	
	'l22.dat',
	}

Campaign.current = 0
Campaign.worldNumber = 1
Campaign.last = 0

function Campaign:reset()
  Campaign:setLevel(1)
  myMap = Map:LoadFromFile(self[self.current])  
end

function Campaign:proceed()
	local nextIsNew = (self.current+1 > self.last)
	local worldChange = self:setLevel(self.current+1)
	
	if worldChange and nextIsNew then
		-- go to animation for world transition
		bridge:start()
	elseif self[self.current] then
		-- go to next level
		myMap = Map:LoadFromFile(self[self.current] , 1 ) -- *only for demo*
		levelEnd:reset()	
		myMap:start(p) 
		mode = 'game'
		menu:newLevelName( self.names[ self[self.current] ] )
  else
		self:setLevel(self.current-1)  
		menu.initWorldMap()      
  end
	self:saveState()
end

function Campaign:saveState()
	-- remember the level which was last played
	config.setValue( "level", self[self.current] )
	--config.setValue( "lastLevel", self[self.last] )
	
	-- if this level is further down the list than the
	-- saved "last level", then save the current level
	-- as the "last level":
	local lastLevel = config.getValue( "lastLevel")
	if not lastLevel then
		--print("saving new last level:", self[self.current])
		config.setValue( "lastLevel", self[self.current])
	else
		local curIndex = tableFind(self, self[self.current]) 
		local lastIndex = tableFind(self, lastLevel)
		--print("curIndex, lastIndex", curIndex, lastIndex, #lastLevel, #self[self.current])
		if curIndex and lastIndex and curIndex > lastIndex then
			config.setValue( "lastLevel", self[self.current])
		end
	end--]]

end

function Campaign:setLevel(lvlnum)
	self.current = lvlnum
	self.last = math.max(self.last, self.current)
	local newWorld =  math.floor((self.current-1)/15)+1
	if newWorld == self.worldNumber then
		return false
	else
		self.worldNumber = newWorld
		return true
	end
end

Campaign.names = {}
Campaign.names['l01.dat'] = 'welcome'
Campaign.names['l02.dat'] = 'windmill'
Campaign.names['l03.dat'] = 'the tower'
Campaign.names['l04.dat'] = 'the cellar'
Campaign.names['l05.dat'] = 'deadly'
Campaign.names['l06.dat'] = 'advanced jumping'
Campaign.names['l09.dat'] = 'leap of faith'
Campaign.names['l12.dat'] = 'house of the many spikes'
Campaign.names['l13.dat'] = 'back and forth'
Campaign.names['l16.dat'] = 'broken bridge'
Campaign.names['l17.dat'] = 'they see me walkin'
Campaign.names['l18.dat'] = 'too little space'
Campaign.names['l19.dat'] = 'one drop'
Campaign.names['l20.dat'] = 'push the button'
Campaign.names['l21.dat'] = 'companion'
Campaign.names['l22.dat'] = 'the end'
