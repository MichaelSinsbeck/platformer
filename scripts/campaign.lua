Campaign = {
	'0-01.dat',

	'1-01.dat',	'1-02.dat',	'1-03.dat',	'1-04.dat',	'1-05.dat',
	'1-06.dat',	'1-07.dat',	'1-08.dat',	'1-09.dat',	'1-10.dat',
	'1-11.dat',	'1-12.dat',	'1-13.dat',	'1-14.dat',	'1-15.dat',
	
	'2-01.dat',	'2-02.dat',	'2-03.dat',	'2-04.dat',	'2-05.dat',
	'2-06.dat', '2-07.dat',	'2-08.dat',	'2-09.dat',	'2-10.dat',
	'2-11.dat',	'2-12.dat',	'2-13.dat',	'2-14.dat',	'2-15.dat',
	
	'3-01.dat',	'3-02.dat',	'3-03.dat',	'3-04.dat',	'3-05.dat',
	'3-06.dat', '3-07.dat',	'3-08.dat',	'3-09.dat',	'3-10.dat',
	'3-11.dat',	'3-12.dat',	'3-13.dat',	'3-14.dat',	'3-15.dat',
	
	'4-01.dat',	'4-02.dat',	'4-03.dat',	'4-04.dat',	'4-05.dat',
	'4-06.dat', '4-07.dat',	'4-08.dat',	'4-09.dat',	'4-10.dat',
	'4-11.dat',	'4-12.dat',	'4-13.dat',	'4-14.dat',	'4-15.dat',
	
	'5-01.dat',	'5-02.dat',	'5-03.dat',	'5-04.dat',	'5-05.dat',
	'5-06.dat', '5-07.dat',	'5-08.dat',	'5-09.dat',	'5-10.dat',
	'5-11.dat',	'5-12.dat',	'5-13.dat',	'5-14.dat',	'5-15.dat',

	'6-01.dat', '6-02.dat',
	}

Campaign.current = 0
Campaign.worldNumber = 1
Campaign.last = 0
Campaign.bandana = 'blank'

local num2bandana = {'blank','white','yellow','green','blue','red'}
local bandana2num = {blank=1,white=2,yellow=3,green=4,blue=5,red=6}

function Campaign:showUpgrade( color )
	print("show upgrade", color)
end

function Campaign:upgradeBandana(color)
-- apply new bandana and return the color, if it is new, 'none' otherwise 
	local current = bandana2num[self.bandana]
	local new = bandana2num[color]
	if new > current then
		self.bandana = num2bandana[new]
		p:setBandana(self.bandana)
		self:showUpgrade( color )
		config.setValue('bandana', self.bandana )
		return self.bandana
	end
	return 'none'
end

function Campaign:init()
	print("Initializing Campaign")
	local lastIndex = 1
	local lastLevel = config.getValue( "lastLevel")
	if lastLevel then
		lastIndex = utility.tableFind(self, lastLevel)
	end
	self.last = lastIndex
	local currentLevel = config.getValue( "level")
	local currentIndex = 1
	if currentLevel then
		currentIndex = utility.tableFind(self, currentLevel)
	end
	self:setLevel(currentIndex)
end
function Campaign:reset()
	print("Resetting Campaign")
	self.last = 1
	self:setLevel(1)
	menu:resetWorldButtons()
	menu:createWorldButtons()
	self.bandana = 'blank'
	config.setValue('bandana', self.bandana )
  --myMap = Map:loadFromFile( "levels/" .. self[self.current])  
end

function Campaign:proceed()
	menu:createWorldButtons()
	local worldChange, nextIsNew = self:setLevel(self.current+1)

	if worldChange and nextIsNew then
		-- go to animation for world transition
		--menu:proceedToNextLevel( self.current )	
		
		
		menu:nextWorld( self.worldNumber )	-- (shows new bridge)
		menu:show()
	elseif self[self.current] then
		-- go to next level
		--myMap = Map:loadFromFile( "levels/" .. self[self.current])
		--levelEnd:reset()	
		--myMap:start()
		--mode = 'game'
		
		fader:fadeTo(self.current)
		gui:newLevelName( self.names[ self[self.current] ] )
	else -- if there is no next level
		menu:proceedToNextLevel( self.current )
		self:setLevel(self.current-1)  
		menu:switchToSubmenu( "Worldmap" )
		menu:show()
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
	print("Save: lastlevel: ", lastLevel )
	print("Save: self[self.current]: ", self[self.current] )
	if not lastLevel then
		--print("saving new last level:", self[self.current])
		config.setValue( "lastLevel", self[self.current])
	else
		local curIndex = utility.tableFind(self, self[self.current]) 
		print("Save: curIndex: ", curIndex)
		local lastIndex = utility.tableFind(self, lastLevel)
		print("Save: lastIndex: ", lastIndex)
		-- If the saved lastlevel is higher than my current last level, then we just reset the game.
		-- In this case, overwrite what's written in the file:
		if lastIndex and curIndex then
			lastIndex = math.min( self.last, lastIndex )
			print("Save: lastIndex: ", lastIndex)
		-- If the saved lastlevel is higher than my current last level, then we just reset the game.
			lastIndex = math.max( curIndex, lastIndex )
			print("Save: curIndex: ", curIndex)
		--print("curIndex, lastIndex", curIndex, lastIndex, #lastLevel, #self[self.current])
			config.setValue( "lastLevel", self[lastIndex])
		end
	end--]]
end

function Campaign:setLevel(lvlnum)
	local nextIsNew = (lvlnum > self.last)
	self.current = lvlnum
	self.last = math.max(self.last, self.current)
	local newWorld = math.floor((self.current-2)/15)+1
	if newWorld == self.worldNumber then
		return false, nextIsNew
	else
		self.worldNumber = newWorld
		return true, nextIsNew
	end
end

Campaign.names = {}

Campaign.names['0-01.dat'] = "Master Kenji's House"

Campaign.names['1-01.dat'] = 'White'
Campaign.names['1-02.dat'] = 'Windmill'
Campaign.names['1-03.dat'] = 'You can die'
Campaign.names['1-04.dat'] = 'Leap of faith'
Campaign.names['1-05.dat'] = 'They see me walking'
Campaign.names['1-06.dat'] = 'Nailproof'
Campaign.names['1-07.dat'] = 'Slide'
Campaign.names['1-08.dat'] = 'Far too far'
Campaign.names['1-09.dat'] = 'The hut'
Campaign.names['1-10.dat'] = 'Shuriking'
Campaign.names['1-11.dat'] = 'Upstream'
Campaign.names['1-12.dat'] = 'Floorless'
Campaign.names['1-13.dat'] = 'Hungry'
Campaign.names['1-14.dat'] = 'Its a trap'
Campaign.names['1-15.dat'] = 'Finale'

Campaign.names['2-01.dat'] = 'Yellow'
Campaign.names['2-02.dat'] = 'Le Parcours'
Campaign.names['2-03.dat'] = 'Advanced Jumping'
Campaign.names['2-04.dat'] = 'Low rider'
Campaign.names['2-05.dat'] = 'Push the button'
Campaign.names['2-06.dat'] = 'House of many spikes'
Campaign.names['2-07.dat'] = 'Companion'
Campaign.names['2-08.dat'] = 'Vertical'
Campaign.names['2-09.dat'] = 'Horizontal'
Campaign.names['2-10.dat'] = 'Crab'
Campaign.names['2-11.dat'] = 'SMB'
Campaign.names['2-12.dat'] = 'Blender'
Campaign.names['2-13.dat'] = 'Touch sensitive'
Campaign.names['2-14.dat'] = 'Curtain'
Campaign.names['2-15.dat'] = 'Access granted'

Campaign.names['3-01.dat'] = 'Green'
Campaign.names['3-02.dat'] = 'Land'
Campaign.names['3-03.dat'] = 'Bowel'
Campaign.names['3-04.dat'] = 'Up'
Campaign.names['3-05.dat'] = 'Bounce'
Campaign.names['3-06.dat'] = 'Tunnel of Thorns'
Campaign.names['3-07.dat'] = 'Someone like you'
Campaign.names['3-08.dat'] = 'Chase'
Campaign.names['3-09.dat'] = 'Meditation'
Campaign.names['3-10.dat'] = 'Teamwork'
Campaign.names['3-11.dat'] = 'Evolution'
Campaign.names['3-12.dat'] = 'Escort agency'
Campaign.names['3-13.dat'] = 'Upwind'
Campaign.names['3-14.dat'] = 'Reverse Bowel'
Campaign.names['3-15.dat'] = 'Heavy Rain'

Campaign.names['4-01.dat'] = 'Blue'
Campaign.names['4-02.dat'] = 'Blocked'
Campaign.names['4-03.dat'] = 'Ascension'
Campaign.names['4-04.dat'] = 'Hall of Tight'
Campaign.names['4-05.dat'] = 'Barrel'
Campaign.names['4-06.dat'] = 'Pew pew'
Campaign.names['4-07.dat'] = 'Bandanadnab'
Campaign.names['4-08.dat'] = 'Hanging garden'
Campaign.names['4-09.dat'] = 'Horizontal'
Campaign.names['4-10.dat'] = 'Unleashed'
Campaign.names['4-11.dat'] = 'Lookin at you'
Campaign.names['4-12.dat'] = 'Stairway to flag'
Campaign.names['4-13.dat'] = 'Nowhere to hide'
Campaign.names['4-14.dat'] = 'Elefant'
Campaign.names['4-15.dat'] = 'Recap'

Campaign.names['5-01.dat'] = 'Red'
Campaign.names['5-02.dat'] = 'Ballistic'
Campaign.names['5-03.dat'] = 'Infiltration'
Campaign.names['5-04.dat'] = 'Floorless'
Campaign.names['5-05.dat'] = 'Quick ride'
Campaign.names['5-06.dat'] = 'Slow ride'
Campaign.names['5-07.dat'] = 'Balance'
Campaign.names['5-08.dat'] = 'Fly freely'
Campaign.names['5-09.dat'] = 'Eyeopener'
Campaign.names['5-10.dat'] = 'Secret Agent'
Campaign.names['5-11.dat'] = 'Air conditioner'
Campaign.names['5-12.dat'] = 'Get up'
Campaign.names['5-13.dat'] = 'Elevator ride'
Campaign.names['5-14.dat'] = 'Double You'
Campaign.names['5-15.dat'] = 'Wee'

Campaign.names['6-01.dat'] = 'Cutscene (boooring!)'
Campaign.names['6-02.dat'] = 'The End'
