Campaign = {
	'l01.dat', -- world 1
	'l02.dat',
	'l03.dat',
	'l04.dat',	
	'l05.dat',
	'l06.dat', 
	'l09.dat', -- blue bandana
	'l07.dat', -- walker
	'l08.dat', -- walker
	'l10.dat',
	'l11.dat',	
	'l12.dat',	
	'l13.dat',
	'l14.dat',
	'l15.dat',

	-- world 2
	'n11.dat',
	'n12.dat',
	'n5.dat',
	'n24.dat',	
	'n6.dat',
	'n7.dat',
	'n8.dat',
	'n9.dat',
	'n14.dat',
	'n17.dat',	
	'n18.dat',
	'n16.dat',
	'n20.dat',
	'n19.dat',
	'n21.dat',
	'n23.dat',
	'n27.dat',
	'n26.dat',
	'n28.dat',
	'n25.dat',
	'n22.dat',
	'n29.dat',
	'n31.dat',
	'n30.dat',
	'n32.dat',
	'n33.dat',
	'n34.dat', -- button
	'n35.dat',
	'n36.dat',
	'n37.dat', -- imitator
	'n39.dat',
	'n40.dat',	
	'n41.dat', -- wind
	'n42.dat', -- breaking block
	'n44.dat', -- glass tutorial
	'n43.dat', -- glass long level			
	'n45.dat', -- fixed cannon	
	'n50.dat', -- welcome castle
	'n49.dat', -- hook intro
	'n47.dat', -- leap of faith, hook
	'n48.dat', -- more hook
	'n46.dat',	
	}

Campaign.current = 0
Campaign.worldNumber = 0
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
		myMap = Map:LoadFromFile(self[self.current])
		levelEnd:reset()	
		myMap:start(p) 
		mode = 'game' 
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
Campaign.names['n13.dat'] = 'learn to walk'
Campaign.names['n1.dat'] = 'jump'
Campaign.names['n10.dat'] = 'the chimney'
Campaign.names['n2.dat'] = 'le parcours'
Campaign.names['n3.dat'] = 'by the way, you can die'
Campaign.names['n15.dat'] = 'leap of faith i'
Campaign.names['n38.dat'] = 'jumping advanced'
Campaign.names['n11.dat'] = 'all you can eat'
Campaign.names['n12.dat'] = 'tight'
Campaign.names['n5.dat'] = 'where is the ground?'
Campaign.names['n24.dat']	 = 'free climbing'
Campaign.names['n6.dat'] = 'the launcher'
Campaign.names['n7.dat'] = 'zig zag'
Campaign.names['n8.dat'] = 'vertical'
Campaign.names['n9.dat'] = 'ascension'
Campaign.names['n14.dat'] = 'up, up, around'
Campaign.names['n17.dat'] = 'get over it'
Campaign.names['n18.dat'] = 'no pain, no gain'
Campaign.names['n16.dat'] = 'leap of faith ii'
Campaign.names['n20.dat'] = 'its a trap'
Campaign.names['n19.dat'] = 'bowel'
Campaign.names['n21.dat'] = 'uprising'
Campaign.names['n23.dat'] = 'vertical ii'
Campaign.names['n27.dat'] = 'following'
Campaign.names['n26.dat'] = 'the one'
Campaign.names['n28.dat'] = 'stairway'
Campaign.names['n25.dat'] = 'calm'
Campaign.names['n22.dat'] = 'weeeee'
Campaign.names['n29.dat'] = 'the crown'
Campaign.names['n31.dat'] = 'leap of faith iii'
Campaign.names['n30.dat'] = 'half pipe'
Campaign.names['n32.dat'] = 'dont hesitate'
Campaign.names['n33.dat'] = 'where am i?'
Campaign.names['n34.dat'] = 'push the button'-- button
Campaign.names['n35.dat'] = 'timed'
Campaign.names['n36.dat'] = 'back and forth'
Campaign.names['n37.dat'] = 'i wanna be like you' -- imitator
Campaign.names['n39.dat'] = 'who is faster?'
Campaign.names['n40.dat']	 = 'meditation'
Campaign.names['n41.dat'] = 'upwind' -- wind
Campaign.names['n42.dat']  = 'only once'-- breaking block
Campaign.names['n44.dat'] = 'the elephant' -- glass tutorial
Campaign.names['n43.dat'] = 'dig' -- glass long level			
Campaign.names['n45.dat'] = 'station' -- fixed cannon	
Campaign.names['n46.dat'] = 'testlevel' -- small level
Campaign.names['n47.dat'] = 'leap of faith iv' -- hook intro
Campaign.names['n48.dat'] = 'floorless' -- more hook
Campaign.names['n49.dat'] = 'hooks law' -- hook intro
Campaign.names['n50.dat'] = 'welcome castle' -- hook intro

Campaign.names['l01.dat'] = 'welcome'
Campaign.names['l02.dat'] = 'windmill'
Campaign.names['l03.dat'] = 'the chimney'
Campaign.names['l04.dat'] = 'le parcours'
Campaign.names['l05.dat'] = 'deadly'
Campaign.names['l06.dat'] = 'advanced jumping'
Campaign.names['l07.dat'] = 'it moves'
Campaign.names['l08.dat'] = 'crunch'
Campaign.names['l09.dat'] = 'leap of faith'
Campaign.names['l10.dat'] = 'bowel'
Campaign.names['l11.dat'] = 'push the button'
Campaign.names['l12.dat'] = 'house of the many spikes'
Campaign.names['l13.dat'] = 'back and forth'
Campaign.names['l14.dat'] = 'where is the ground'
Campaign.names['l15.dat'] = 'bullet hell'

