-- Animation Database

AnimationDB = {
source = {},
animation = {}
}

function AnimationDB:loadImage(imagefilename,name,height,width, subfolder)
	-- Load image and prepare quads (height and width are optional)
	if subfolder then
		imagefilename = 'images/'.. subfolder .. "/" .. Camera.scale*8 .. imagefilename
	else
		imagefilename = 'images/'.. Camera.scale*8 .. imagefilename
	end
	local image = love.graphics.newImage(imagefilename)
	local height = height or image:getHeight()
	local width = width or image:getWidth()
	self.source[name] = {}
	self.source[name].image = image
	self.source[name].image:setFilter('linear','linear')
	self.source[name].height = height
	self.source[name].width = width
	self.source[name].quads = {}
  
  local imageWidth = self.source[name].image:getWidth()
  local imageHeight = self.source[name].image:getHeight()
  for j = 1,math.floor(imageHeight/height) do
    for i = 1,math.floor(imageWidth/width) do
      self.source[name].quads[i+(j-1)*math.floor(imageWidth/width)] = 
        love.graphics.newQuad((i-1)*(width),(j-1)*(height), width, height,
        imageWidth,imageHeight)
    end
  end
end

function AnimationDB:addAni(name,source,frames,duration)
	-- check, iff both input tables have the same length and add zeros, if necessary
	local frameLength = #frames
	local durationLength = #duration
	if frameLength > durationLength then
	  for excess = durationLength+1,frameLength do
	    duration[excess] = 0
	  end
	end
  self.animation[name] = {}
  self.animation[name].source = source
  self.animation[name].frames = frames
  self.animation[name].duration = duration
end

function AnimationDB:loadBackgrounds()
	local tileSize = Camera.scale*8
	local imageHeight = 15*tileSize
	local imageWidth = 10*tileSize
	local offSetY = 0.5*(Camera.height-imageHeight)
	self.backgroundQuad = love.graphics.newQuad(0,-offSetY,Camera.width,Camera.height,imageWidth,imageHeight)

	self.background = {}	
	for iWorld = 1,5 do
		local imagefilename = 'images/tilesets/'.. Camera.scale*8 .. 'parallax'.. iWorld ..'.png'
		self.background[iWorld] = love.graphics.newImage(imagefilename)	
		self.background[iWorld]:setWrap('repeat', 'clamp')
	end
	
	 
end

function AnimationDB:loadAll()
	local tileSize = Camera.scale*10
	AnimationDB:loadBackgrounds()
	
	AnimationDB:loadImage('player_white.png','whitePlayer',tileSize,tileSize)
	AnimationDB:addAni('whiteRun','whitePlayer',{3,1,2,1},{.08,.04,.08,.04})
	AnimationDB:addAni('whiteWalk','whitePlayer',{18,17,19,17},{.08,.04,.08,.04})
	AnimationDB:addAni('whiteJump','whitePlayer',{5},{1e6})
	AnimationDB:addAni('whiteFall','whitePlayer',{6,7},{.1,1e6})
	AnimationDB:addAni('whiteWall','whitePlayer',{9,10,11},{0.4,0.075,1e6})
	AnimationDB:addAni('whiteSliding','whitePlayer',{4},{1e6})
	AnimationDB:addAni('whiteStand','whitePlayer',{17},{1e6})
	AnimationDB:addAni('whiteLineSlide','whitePlayer',{8},{1e6})
	AnimationDB:addAni('whiteLineMove','whitePlayer',{13,14,15,14},{0.08,0.04,0.08,0.04})
	AnimationDB:addAni('whiteLineHang','whitePlayer',{16},{1e6})
	AnimationDB:addAni('whiteDead','whitePlayer',{20},{1e6})

	AnimationDB:loadImage('player_blue.png','bluePlayer',tileSize,tileSize)
	AnimationDB:addAni('blueRun','bluePlayer',{3,1,2,1},{.08,.04,.08,.04})
	AnimationDB:addAni('blueWalk','bluePlayer',{18,17,19,17},{.08,.04,.08,.04})
	AnimationDB:addAni('blueJump','bluePlayer',{5},{1e6})
	AnimationDB:addAni('blueFall','bluePlayer',{6,7},{.1,1e6})
	AnimationDB:addAni('blueWall','bluePlayer',{9,10,11},{0.4,0.075,1e6})
	AnimationDB:addAni('blueSliding','bluePlayer',{4},{1e6})
	AnimationDB:addAni('blueStand','bluePlayer',{17},{1e6})
	AnimationDB:addAni('blueLineSlide','bluePlayer',{8},{1e6})
	AnimationDB:addAni('blueLineMove','bluePlayer',{13,14,15,14},{0.08,0.04,0.08,0.04})
	AnimationDB:addAni('blueLineHang','bluePlayer',{16},{1e6})
	AnimationDB:addAni('blueGliding','bluePlayer',{21,22,23},{.1,.1,1e6})

	AnimationDB:loadImage('player_red.png','redPlayer',tileSize,tileSize)
	AnimationDB:addAni('redRun','redPlayer',{3,1,2,1},{.08,.04,.08,.04})
	AnimationDB:addAni('redWalk','redPlayer',{18,17,19,17},{.08,.04,.08,.04})
	AnimationDB:addAni('redJump','redPlayer',{5},{1e6})
	AnimationDB:addAni('redFall','redPlayer',{6,7},{.1,1e6})
	AnimationDB:addAni('redWall','redPlayer',{9,10,11},{0.4,0.075,1e6})
	AnimationDB:addAni('redSliding','redPlayer',{4},{1e6})
	AnimationDB:addAni('redStand','redPlayer',{17},{1e6})
	AnimationDB:addAni('redLineSlide','redPlayer',{8},{1e6})
	AnimationDB:addAni('redLineMove','redPlayer',{13,14,15,14},{0.08,0.04,0.08,0.04})
	AnimationDB:addAni('redLineHang','redPlayer',{16},{1e6})
	AnimationDB:addAni('redHooked','redPlayer',{12},{1e6})

	AnimationDB:loadImage('player_blank.png','blankPlayer',tileSize,tileSize)
	AnimationDB:addAni('blankRun','blankPlayer',{3,1,2,1},{.08,.04,.08,.04})
	AnimationDB:addAni('blankWalk','blankPlayer',{18,17,19,17},{.08,.04,.08,.04})
	AnimationDB:addAni('blankJump','blankPlayer',{5},{1e6})
	AnimationDB:addAni('blankFall','blankPlayer',{6,7},{.1,1e6})
	AnimationDB:addAni('blankWall','blankPlayer',{9,10,11},{0.4,0.075,1e6})
	AnimationDB:addAni('blankSliding','blankPlayer',{4},{1e6})
	AnimationDB:addAni('blankStand','blankPlayer',{17},{1e6})
	AnimationDB:addAni('blankLineSlide','blankPlayer',{8},{1e6})
	AnimationDB:addAni('blankLineMove','blankPlayer',{13,14,15,14},{0.08,0.04,0.08,0.04})
	AnimationDB:addAni('blankLineHang','blankPlayer',{16},{1e6})
	AnimationDB:addAni('blankHooked','blankPlayer',{12},{1e6})

	AnimationDB:loadImage('player_green.png','greenPlayer',tileSize,tileSize)
	AnimationDB:addAni('greenRun','greenPlayer',{3,1,2,1},{.08,.04,.08,.04})
	AnimationDB:addAni('greenWalk','greenPlayer',{18,17,19,17},{.08,.04,.08,.04})
	AnimationDB:addAni('greenJump','greenPlayer',{5},{1e6})
	AnimationDB:addAni('greenFall','greenPlayer',{6,7},{.1,1e6})
	AnimationDB:addAni('greenWall','greenPlayer',{9,10,11},{0.4,0.075,1e6})
	AnimationDB:addAni('greenSliding','greenPlayer',{4},{1e6})
	AnimationDB:addAni('greenStand','greenPlayer',{17},{1e6})
	AnimationDB:addAni('greenLineSlide','greenPlayer',{8},{1e6})
	AnimationDB:addAni('greenLineMove','greenPlayer',{13,14,15,14},{0.08,0.04,0.08,0.04})
	AnimationDB:addAni('greenLineHang','greenPlayer',{16},{1e6})

	AnimationDB:loadImage('imitator.png','imitator',tileSize,tileSize)
	AnimationDB:addAni('imitatorRun','imitator',{3,1,2,1},{.08,.04,.08,.04})
	AnimationDB:addAni('imitatorWalk','imitator',{11,9,10,9},{.08,.04,.08,.04})
	AnimationDB:addAni('imitatorJump','imitator',{5},{1e6})
	AnimationDB:addAni('imitatorFall','imitator',{6,7},{.1,1e6})
	AnimationDB:addAni('imitatorStand','imitator',{9},{1e6})
	AnimationDB:addAni('imitatorSliding','imitator',{4},{1e6})

	AnimationDB:loadImage('launcher.png','launcher',tileSize,tileSize)
	AnimationDB:addAni('launcherLoading','launcher',{1,2,3},{.45,.45,1e6})

	AnimationDB:loadImage('explosion.png','explosion',tileSize,tileSize)
	AnimationDB:addAni('explosionExplode','explosion',{1,2,3,4,5,6,6},{.05,.05,.1,.1,.1,.1,1e6})

	AnimationDB:loadImage('bandana.png','bandana',tileSize,tileSize)
	AnimationDB:addAni('starBandana','bandana',{1},{1e6})
	AnimationDB:addAni('whiteBandana','bandana',{2},{1e6})
	AnimationDB:addAni('greenBandana','bandana',{3},{1e6})
	AnimationDB:addAni('blueBandana','bandana',{4},{1e6})
	AnimationDB:addAni('redBandana','bandana',{5},{1e6})
	AnimationDB:addAni('chickenleg','bandana',{6},{1e6})

	AnimationDB:loadImage('poff.png','poff',tileSize*.6,tileSize*.6)
	AnimationDB:addAni('poff','poff',{1,2,3,4,5,5},{.05,.075,.15,.15,.1,1e6})

	AnimationDB:loadImage('particle.png','particle',0.4*tileSize,0.4*tileSize)
	AnimationDB:addAni('particle','particle',{1},{1e6})

	AnimationDB:loadImage('shuriken.png','shuriken',tileSize,tileSize)
	AnimationDB:addAni('shurikenDead','shuriken',{2},{1e6})
	AnimationDB:addAni('shuriken','shuriken',{1},{1e6})

	AnimationDB:loadImage('runner.png','runner',tileSize,tileSize)
	AnimationDB:addAni('runnerLeft','runner',{6},{1e6})
	AnimationDB:addAni('runnerRight','runner',{5},{1e6})
	AnimationDB:addAni('runnerSleep','runner',{1,2,3},{0.4,0.1,1e6})
	AnimationDB:addAni('runnerWait','runner',{1},{1e6})

	AnimationDB:loadImage('runnermouth.png','runnerMouth')
	AnimationDB:addAni('runnerMouth','runnerMouth',{1},{1e6})

	AnimationDB:loadImage('bouncer.png','bouncer',tileSize,tileSize)
	AnimationDB:addAni('bouncer','bouncer',{2,1},{0.1,1e6})

	AnimationDB:loadImage('button.png','button',tileSize,tileSize)
	AnimationDB:addAni('button','button',{1},{1e6})
	AnimationDB:addAni('buttonPressed','button',{3},{1e6})
	AnimationDB:addAni('buttonReleased','button',{2},{1e6})

	AnimationDB:loadImage('waitbar.png','waitbar')
	AnimationDB:addAni('waitbar','waitbar',{1},{1e6})

	AnimationDB:loadImage('appearblock.png','appearBlock',tileSize,tileSize)
	AnimationDB:addAni('appearBlockThere','appearBlock',{1},{1e6})
	AnimationDB:addAni('appearBlockNotThere','appearBlock',{2},{1e6})


	AnimationDB:loadImage('winddot.png','winddot',.6*tileSize,.2*tileSize)
	AnimationDB:addAni('wind1','winddot',{1},{1e6})
	AnimationDB:addAni('wind2','winddot',{2},{1e6})
	AnimationDB:addAni('wind3','winddot',{3},{1e6})

	AnimationDB:loadImage('cannon.png','cannon',tileSize,tileSize)
	AnimationDB:addAni('cannon','cannon',{1},{1e6})

	AnimationDB:loadImage('goalie.png','goalie',tileSize,tileSize)
	AnimationDB:addAni('goalie','goalie',{1},{1e6})

	AnimationDB:loadImage('launcher.png','launcher',tileSize,tileSize)
	AnimationDB:addAni('launcher','launcher',{1},{1e6})
	AnimationDB:loadImage('launcherSon.png','launcherSon',tileSize,tileSize)
	AnimationDB:addAni('launcherSon','launcherSon',{1},{1e6})

	AnimationDB:loadImage('missile.png','missile',tileSize,tileSize)
	AnimationDB:addAni('missile','missile',{1},{1e6})

	AnimationDB:loadImage('windmillwing.png','windmillwing')
	AnimationDB:addAni('windmillwing','windmillwing',{1},{1e6})
	
	AnimationDB:loadImage('crumbleblock.png','crumbleblock',tileSize,tileSize)
	AnimationDB:addAni('crumbleblock','crumbleblock',{1},{1e6})
	
	AnimationDB:loadImage('glassblock.png','glassblock',tileSize,tileSize)
	AnimationDB:addAni('glassblock','glassblock',{1},{1e6})
	
	AnimationDB:loadImage('bubble.png','bubble')
	AnimationDB:addAni('bubble','bubble',{1},{1e6})
	
	AnimationDB:loadImage('crumble.png','crumble',.4*tileSize,.4*tileSize)
	AnimationDB:addAni('crumble1','crumble',{1},{1e6})
	AnimationDB:addAni('crumble2','crumble',{2},{1e6})
	AnimationDB:addAni('crumble3','crumble',{3},{1e6})
	AnimationDB:addAni('crumble4','crumble',{4},{1e6})
	AnimationDB:addAni('glass1','crumble',{5},{1e6})
	AnimationDB:addAni('glass2','crumble',{6},{1e6})
	AnimationDB:addAni('glass3','crumble',{7},{1e6})
	AnimationDB:addAni('glass4','crumble',{8},{1e6})
	AnimationDB:addAni('door1','crumble',{9},{1e6})
	AnimationDB:addAni('door2','crumble',{10},{1e6})
	AnimationDB:addAni('door3','crumble',{11},{1e6})
	AnimationDB:addAni('door4','crumble',{12},{1e6})
	
	AnimationDB:loadImage('fixedcannon.png','fixedcannon')
	AnimationDB:addAni('fixedcannon','fixedcannon',{1},{1e6})
	
	AnimationDB:loadImage('butterfly.png','butterfly',.4*tileSize,.4*tileSize)
	AnimationDB:addAni('butterflybody','butterfly',{1},{1e6})	
	AnimationDB:addAni('butterflywing1','butterfly',{2},{1e6})
	AnimationDB:addAni('butterflywing2','butterfly',{3},{1e6})
	AnimationDB:addAni('butterflywing3','butterfly',{4},{1e6})
	
	AnimationDB:loadImage('meat.png','meat',.4*tileSize,.4*tileSize)	
	AnimationDB:addAni('meat1','meat',{1},{1e6})
	AnimationDB:addAni('meat2','meat',{2},{1e6})
	AnimationDB:addAni('meat3','meat',{3},{1e6})
	AnimationDB:addAni('meat4','meat',{4},{1e6})
	AnimationDB:addAni('meatWall','meat',{5},{1e6})
	AnimationDB:addAni('meatCorner','meat',{6},{1e6})
	
	AnimationDB:loadImage('exit.png','exit',tileSize,tileSize)	
	AnimationDB:addAni('exit','exit',{1,2,3,4,1,5,6},{.1,.1,.1,.1,.1,.1,.1})
	
	AnimationDB:loadImage('bungee.png','bungee',0.4*tileSize,0.4*tileSize)	
	AnimationDB:addAni('bungee','bungee',{1},{1e6})

	AnimationDB:loadImage('door.png','door',tileSize,tileSize)	
	AnimationDB:addAni('keyhole','door',{1},{1e6})	
	AnimationDB:addAni('door','door',{2},{1e6})	
	AnimationDB:addAni('key','door',{3},{1e6})			
	
	AnimationDB:loadImage('targetline.png','targetline')
	AnimationDB:addAni('targetline','targetline',{1},{1e6})
	
	AnimationDB:loadImage('bumper.png','bumper')
	AnimationDB:addAni('bumper','bumper',{1},{1e6})	
	
	AnimationDB:loadImage('clubber.png','clubber',tileSize,tileSize)
	AnimationDB:addAni('clubber','clubber',{1},{1e6})	
	AnimationDB:addAni('club','clubber',{2},{1e6})
	
	AnimationDB:loadImage('light.png','light',tileSize,tileSize)
	AnimationDB:addAni('candle','light',{1},{1e6})
	AnimationDB:addAni('candlelight','light',{2,3,4,3},{.2,.2,.2,.2})
	AnimationDB:addAni('torch','light',{6},{1e6})		
	AnimationDB:addAni('flame','light',{7,8,7,9},{.2,.2,.2,.2})
	AnimationDB:addAni('lamp','light',{5},{1e6})
	AnimationDB:addAni('lamplight','light',{10},{1e6})
	
	
	AnimationDB:loadImage('menuPlayer.png','menuPlayer',tileSize,tileSize, "menu")
	AnimationDB:addAni('lookWhite','menuPlayer',{1},{1e6})
	AnimationDB:addAni('moveUpWhite','menuPlayer',{6,7,8,9,10,9,8,7,},{.01,.02,.03,.06,.1,.06,.03,.02})
	AnimationDB:addAni('moveDownWhite','menuPlayer',{11,12,13,14,15,14,13,12},{.01,.02,.03,.06,.1,.06,.03,.02})
	AnimationDB:addAni('bandanaColor','menuPlayer',{2,3,4,5},{.05,.05,.05,.05})
	AnimationDB:addAni('jumpFallWhite','whitePlayer',{17,5,6,5,17},{.05,.05,.5,.05,.5})
	AnimationDB:addAni('playerScreenshot','menuPlayer',{21,22,23,24,25,21},{0.1,.01,.05,.02,.02,1})
	AnimationDB:addAni('playerFullscreen','menuPlayer',{26,27,28,29,30,31,32,33,34,35},{0.08,.04,.08,0.04,.2,.3,0.04,0.08,.08,.5})

	AnimationDB:loadImage('log.png','log')
	AnimationDB:addAni('log','log',{1},{1e6})
	
	AnimationDB:loadImage('walker.png','walker',tileSize,tileSize)
	AnimationDB:addAni('prewalker','walker',{1},{1e6})
	AnimationDB:addAni('walkerdown','walker',{2},{1e6})
	AnimationDB:addAni('walkerup','walker',{3},{1e6})
	AnimationDB:addAni('walker','walker',{4},{1e6})
	AnimationDB:addAni('walkerfoot','walker',{5},{1e6})
	AnimationDB:addAni('walkerfoot2','walker',{6},{1e6})
	
	AnimationDB:loadImage('spawner.png','spawner',tileSize,tileSize)
	AnimationDB:addAni('spawnerfront','spawner',{1},{1e6})	
	AnimationDB:addAni('spawnerback','spawner',{2},{1e6})
	AnimationDB:addAni('spawnerbar','spawner',{3},{1e6})
	
	AnimationDB:loadImage('button.png','editorButton',tileSize,tileSize, "editor")
	AnimationDB:addAni('LEGround1Off'  ,'editorButton',{1},{1e6})
	AnimationDB:addAni('LEGround1Hover','editorButton',{2},{1e6})
	AnimationDB:addAni('LEGround1On'   ,'editorButton',{3},{1e6})
	AnimationDB:addAni('LEGround2Off'  ,'editorButton',{4},{1e6})
	AnimationDB:addAni('LEGround2Hover','editorButton',{5},{1e6})
	AnimationDB:addAni('LEGround2On'   ,'editorButton',{6},{1e6})
	AnimationDB:addAni('LEGround3Off'  ,'editorButton',{7},{1e6})
	AnimationDB:addAni('LEGround3Hover','editorButton',{8},{1e6})
	AnimationDB:addAni('LEGround3On'   ,'editorButton',{9},{1e6})
	AnimationDB:addAni('LEGround4Off'  ,'editorButton',{10},{1e6})
	AnimationDB:addAni('LEGround4Hover','editorButton',{11},{1e6})
	AnimationDB:addAni('LEGround4On'   ,'editorButton',{12},{1e6})
	AnimationDB:addAni('LEGround5Off'  ,'editorButton',{13},{1e6})
	AnimationDB:addAni('LEGround5Hover','editorButton',{14},{1e6})
	AnimationDB:addAni('LEGround5On'   ,'editorButton',{15},{1e6})
	AnimationDB:addAni('LEGround6Off'  ,'editorButton',{16},{1e6})
	AnimationDB:addAni('LEGround6Hover','editorButton',{17},{1e6})
	AnimationDB:addAni('LEGround6On'   ,'editorButton',{18},{1e6})
	AnimationDB:addAni('LESpikes1Off'  ,'editorButton',{37},{1e6})
	AnimationDB:addAni('LESpikes1Hover','editorButton',{38},{1e6})
	AnimationDB:addAni('LESpikes1On'   ,'editorButton',{39},{1e6})
	AnimationDB:addAni('LESpikes2Off'  ,'editorButton',{40},{1e6})
	AnimationDB:addAni('LESpikes2Hover','editorButton',{41},{1e6})
	AnimationDB:addAni('LESpikes2On'   ,'editorButton',{42},{1e6})
	
	AnimationDB:addAni('LEPenOff'     ,'editorButton',{19},{1e6})
	AnimationDB:addAni('LEPenHover'   ,'editorButton',{20},{1e6})
	AnimationDB:addAni('LEPenOn'      ,'editorButton',{21},{1e6})
	AnimationDB:addAni('LEPenOff'     ,'editorButton',{19},{1e6})
	AnimationDB:addAni('LEPenHover'   ,'editorButton',{20},{1e6})
	AnimationDB:addAni('LEPenOn'      ,'editorButton',{21},{1e6})
	AnimationDB:addAni('LEStampOff'  ,'editorButton',{22},{1e6})
	AnimationDB:addAni('LEStampHover','editorButton',{23},{1e6})
	AnimationDB:addAni('LEStampOn'   ,'editorButton',{24},{1e6})
	AnimationDB:addAni('LEOpenOff'    ,'editorButton',{25},{1e6})
	AnimationDB:addAni('LEOpenHover'  ,'editorButton',{26},{1e6})
	AnimationDB:addAni('LEOpenOn'     ,'editorButton',{27},{1e6})
	AnimationDB:addAni('LESaveOff'    ,'editorButton',{28},{1e6})
	AnimationDB:addAni('LESaveHover'  ,'editorButton',{29},{1e6})
	AnimationDB:addAni('LESaveOn'     ,'editorButton',{30},{1e6})
	AnimationDB:addAni('LEExitOff'    ,'editorButton',{31},{1e6})
	AnimationDB:addAni('LEExitHover'  ,'editorButton',{32},{1e6})
	AnimationDB:addAni('LEExitOn'     ,'editorButton',{33},{1e6})
	AnimationDB:addAni('LEEditOff'  ,'editorButton',{34},{1e6})
	AnimationDB:addAni('LEEditHover','editorButton',{35},{1e6})
	AnimationDB:addAni('LEEditOn'   ,'editorButton',{36},{1e6})

	-- keyboard and gamepad keys for in-level display: (tutorial)
	AnimationDB:loadImage('keyOn.png','keyboardSmall',tileSize,tileSize, "menu")
	AnimationDB:addAni('keyboardSmall','keyboardSmall',{1},{1e6})
	AnimationDB:loadImage('keyLargeOn.png','keyboardLarge',tileSize,tileSize*2, "menu")
	AnimationDB:addAni('keyboardLarge','keyboardLarge',{1},{1e6})
	AnimationDB:loadImage('gamepadA.png','gamepadA',tileSize,tileSize, "menu")
	AnimationDB:addAni('gamepadA','gamepadA',{1},{1e6})
	AnimationDB:loadImage('gamepadB.png','gamepadB',tileSize,tileSize, "menu")
	AnimationDB:addAni('gamepadB','gamepadB',{1},{1e6})
	AnimationDB:loadImage('gamepadBack.png','gamepadBack',tileSize,tileSize, "menu")
	AnimationDB:addAni('gamepadBack','gamepadBack',{1},{1e6})
	AnimationDB:loadImage('gamepadDown.png','gamepadDown',tileSize,tileSize, "menu")
	AnimationDB:addAni('gamepadDown','gamepadDown',{1},{1e6})
	AnimationDB:loadImage('gamepadLB.png','gamepadLB',tileSize,tileSize*2, "menu")
	AnimationDB:addAni('gamepadLB','gamepadLB',{1},{1e6})
	AnimationDB:loadImage('gamepadLeft.png','gamepadLeft',tileSize,tileSize, "menu")
	AnimationDB:addAni('gamepadLeft','gamepadLeft',{1},{1e6})
	AnimationDB:loadImage('gamepadRB.png','gamepadRB',tileSize,tileSize*2, "menu")
	AnimationDB:addAni('gamepadRB','gamepadRB',{1},{1e6})
	AnimationDB:loadImage('gamepadRight.png','gamepadRight',tileSize,tileSize, "menu")
	AnimationDB:addAni('gamepadRight','gamepadRight',{1},{1e6})
	AnimationDB:loadImage('gamepadStart.png','gamepadStart',tileSize,tileSize, "menu")
	AnimationDB:addAni('gamepadStart','gamepadStart',{1},{1e6})
	AnimationDB:loadImage('gamepadUp.png','gamepadUp',tileSize,tileSize, "menu")
	AnimationDB:addAni('gamepadUp','gamepadUp',{1},{1e6})
	AnimationDB:loadImage('gamepadY.png','gamepadY',tileSize,tileSize, "menu")
	AnimationDB:addAni('gamepadY','gamepadY',{1},{1e6})
	AnimationDB:loadImage('gamepadX.png','gamepadX',tileSize,tileSize, "menu")
	AnimationDB:addAni('gamepadX','gamepadX',{1},{1e6})
	
	
	AnimationDB:loadImage('listCount.png','listCount',tileSize,tileSize)
	AnimationDB:addAni('listCount1','listCount',{1},{1e6})
	AnimationDB:addAni('listCount2','listCount',{2},{1e6})
	AnimationDB:addAni('listCount3','listCount',{3},{1e6})
	AnimationDB:addAni('listCount4','listCount',{4},{1e6})
	AnimationDB:addAni('listCount5','listCount',{5},{1e6})
	
	-- level end statistics:
	AnimationDB:loadImage('deaths.png','deaths',tileSize*2,tileSize*2)
	AnimationDB:addAni('deathSpikes1','deaths',{1},{1e6})
	AnimationDB:addAni('deathSpikes2','deaths',{2},{1e6})
	AnimationDB:addAni('deathSpikes3','deaths',{3},{1e6})
	AnimationDB:addAni('deathSpikes4','deaths',{4},{1e6})
	AnimationDB:addAni('deathFall1','deaths',{5},{1e6})
	AnimationDB:addAni('deathFall2','deaths',{6},{1e6})
	AnimationDB:addAni('deathFall3','deaths',{7},{1e6})
	AnimationDB:addAni('deathFall4','deaths',{8},{1e6})
	AnimationDB:addAni('deathShuriken1','deaths',{9},{1e6})
	AnimationDB:addAni('deathShuriken2','deaths',{10},{1e6})
	AnimationDB:addAni('deathShuriken3','deaths',{11},{1e6})
	AnimationDB:addAni('deathShuriken4','deaths',{12},{1e6})
	AnimationDB:addAni('deathMissile1','deaths',{13},{1e6})
	AnimationDB:addAni('deathMissile2','deaths',{14},{1e6})
	AnimationDB:addAni('deathMissile3','deaths',{15},{1e6})
	AnimationDB:addAni('deathMissile4','deaths',{16},{1e6})
	AnimationDB:addAni('deathWalker1','deaths',{17},{1e6})
	AnimationDB:addAni('deathWalker2','deaths',{18},{1e6})
	AnimationDB:addAni('deathWalker3','deaths',{19},{1e6})
	AnimationDB:addAni('deathWalker4','deaths',{20},{1e6})

	AnimationDB:loadImage('statIdle.png', 'statIdle', tileSize*2, tileSize*3 )
	AnimationDB:addAni('statIdle', 'statIdle', {1},{1e6})	
	AnimationDB:loadImage('statNoDeath1.png', 'statNoDeath1', tileSize*3, tileSize*3)
	AnimationDB:addAni('statNoDeath1', 'statNoDeath1', {1},{1e6})
	AnimationDB:loadImage('statNoDeath2.png', 'statNoDeath2', tileSize*3, tileSize*3)
	AnimationDB:addAni('statNoDeath2', 'statNoDeath2', {1,2,1,2},{10,0.2,0.3,0.2})
	AnimationDB:loadImage('statHighestJump.png', 'statHighestJump', tileSize*4, tileSize*2)
	AnimationDB:addAni('statHighestJump', 'statHighestJump', {1,2,3,4,5,6,7,8},{1.5,.05,.05,.05,.05,.05,.05,1e6})
	AnimationDB:loadImage('statLongestJump.png', 'statLongestJump', tileSize*2, tileSize*2 )
	AnimationDB:addAni('statLongestJump', 'statLongestJump', {1},{1e6})
	AnimationDB:loadImage('statTimeInAir.png', 'statTimeInAir', tileSize*2, tileSize*3 )
	AnimationDB:addAni('statTimeInAir', 'statTimeInAir', {1,2,3,4,3,2,1,5,6,7,6,5},
			{.1,.08,.05,.08,.05,.08,.1,.08,.05,.08,.05,.08})
	AnimationDB:loadImage('statNumberOfJumps.png', 'statNumberOfJumps', tileSize*2, tileSize*2 )
	AnimationDB:addAni('statNumberOfJumps', 'statNumberOfJumps', {1,2,3,4,5,6,7},{.1,.05,.05,.05,.05,.05,.05})
	AnimationDB:loadImage('statWallHang.png', 'statWallHang', tileSize*2, tileSize*2 )
	AnimationDB:addAni('statWallHang', 'statWallHang', {1},{1e6})
	AnimationDB:loadImage('statVelocity.png', 'statVelocity', tileSize*2, tileSize*4 )
	AnimationDB:addAni('statVelocity','statVelocity',{1,2,3,4},{.06,.03,.06,.03})
	AnimationDB:loadImage('statTime.png', 'statTime', tileSize*4, tileSize*2 )
	AnimationDB:addAni('statTime','statTime',{1,2,3,4},{.08,.08,.08,.08} )
	AnimationDB:loadImage('statNumberOfButtons.png', 'statNumberOfButtons', tileSize*4, tileSize*4)
	AnimationDB:addAni('statNumberOfButtons','statNumberOfButtons',
	{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,16,18,19,18,19,20,21,22,21,22,21,22,21,22,21,22,23,24,25,26,27,28,29,30,31},
	{1.5,.3,.03,.04,.06,.04,.03,.1,.9,.08,.05,.05,.08,.05,.2,1,.2,.5,.1,.1,.1,.1,.05,.2,.1,.3,.1,.2,.2,.1,.2,.1,.1,1,.03,.03,.03,.03,.9,.01,.9,1e6})
end
