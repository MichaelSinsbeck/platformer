Campaign = {
	'1-00c.dat',	'1-02.dat',	'1-03.dat',	'1-04.dat',	'1-05.dat',
	'1-06.dat',	'1-07.dat',	'1-08.dat',	'1-09.dat',	'1-10.dat',
	'1-11.dat',	'1-12.dat',	'1-13.dat',	'1-14.dat',	'1-15.dat',
	
	'2-01b.dat',	'2-02.dat',	'2-03.dat',	'2-04.dat',	'2-05.dat',
	'2-06.dat', '2-07.dat',	'2-08.dat',	'2-09.dat',	'2-10.dat',
	'2-11.dat',	'2-12.dat',	'2-13.dat',	'2-14.dat',	'2-15.dat',
	
	--'endofdemo.dat',
	
	'3-01.dat',	'3-02.dat',	'3-03.dat',	'3-04.dat',	'3-05.dat',
	'3-06.dat', '3-07.dat',	'3-08.dat',	'3-09.dat',	'3-10.dat',
	'3-11.dat',	'3-12.dat',	'3-13.dat',	'3-14.dat',	'3-15.dat',
	
	'4-01.dat',	'4-02.dat',	'4-03.dat',	'4-04.dat',	'4-05.dat',
	'4-06.dat', '4-07.dat',	'4-08.dat',	'4-09.dat',	'4-10.dat',
	'4-11.dat',	'4-12.dat',	'4-13.dat',	'4-14.dat',	'4-15.dat',
	
	'5-01.dat',	'5-02.dat',	'5-03.dat',	'5-04.dat',	'5-05.dat',
	'5-06.dat', '5-07.dat',	'5-08.dat',	'5-09.dat',	'5-10.dat',
	'5-11.dat',	'5-12.dat',	'5-13.dat',	'5-14.dat',	'5-15.dat',
	}

Campaign.current = 0
Campaign.worldNumber = 1
Campaign.last = 0
Campaign.bandana = 'blank'

local num2bandana = {'blank','white','yellow','green','blue','red'}
local bandana2num = {blank=1,white=2,yellow=3,green=4,blue=5,red=6}

function Campaign:showUpgrade()
end

function Campaign:upgradeBandana(color)
-- apply new bandana and return the color, if it is new, 'none' otherwise 
	local current = bandana2num[self.bandana]
	local new = bandana2num[color]
	if new > current then
		self.bandana = num2bandana[new]
		p:setBandana(self.bandana)
		self:showUpgrade()
		config.setValue('bandana', self.bandana )
		return self.bandana
	end
	return 'none'
end

function Campaign:reset()
  self:setLevel(1)
  --myMap = Map:loadFromFile( "levels/" .. self[self.current])  
end

function Campaign:proceed()
	local nextIsNew = (self.current+1 > self.last)
	local worldChange = self:setLevel(self.current+1)
	
	if worldChange and nextIsNew then
		-- go to animation for world transition
		bridge:start()
	elseif self[self.current] then
		-- go to next level
		myMap = Map:loadFromFile( "levels/" .. self[self.current])
		levelEnd:reset()	
		myMap:start()
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
		local curIndex = utility.tableFind(self, self[self.current]) 
		local lastIndex = utility.tableFind(self, lastLevel)
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

Campaign.names['l07.dat'] = 'It Moves'
Campaign.names['l08.dat'] = 'Crunch'
Campaign.names['l10.dat'] = 'Bowel'
Campaign.names['l11.dat'] = 'Push the Button'
Campaign.names['l14.dat'] = 'Where is the Ground'
Campaign.names['l15.dat'] = 'Bullet Hell'
Campaign.names['l22.dat'] = 'The End'

Campaign.names['1-00b.dat'] = 'Welcome'
Campaign.names['1-01.dat'] = 'Welcome'
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

Campaign.names['2-01b.dat'] = 'The Tower'
Campaign.names['2-01.dat'] = 'The Tower'
Campaign.names['2-02.dat'] = 'Cellar'
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

Campaign.names['3-01.dat'] = 'Clouds!'
Campaign.names['3-02.dat'] = 'Land'
Campaign.names['3-03.dat'] = 'Bowel'
Campaign.names['3-04.dat'] = 'Up'
Campaign.names['3-05.dat'] = 'Bounce'
Campaign.names['3-06.dat'] = 'Tunnel of Thorns'
Campaign.names['3-07.dat'] = 'Companion'
Campaign.names['3-08.dat'] = 'Vertical'
Campaign.names['3-09.dat'] = 'Horizontal'
Campaign.names['3-10.dat'] = 'Crab'
Campaign.names['3-11.dat'] = 'SMB'
Campaign.names['3-12.dat'] = 'Blender'
Campaign.names['3-13.dat'] = 'Touch sensitive'
Campaign.names['3-14.dat'] = 'Curtain'
Campaign.names['3-15.dat'] = 'Access granted'

Campaign.names['endofdemo.dat'] = 'End of Demo'
