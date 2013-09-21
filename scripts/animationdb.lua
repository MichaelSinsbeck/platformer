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
	AnimationDB:addAni('exit','exit',{1},{1e6})
	
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
	AnimationDB:addAni('moveUpWhite','menuPlayer',{6,7,8,9,10,6},{.01,.03,.02,.01,.5,.5})
	AnimationDB:addAni('moveDownWhite','menuPlayer',{11,12,13,14,15,11},{.01,.03,.02,.01,.5,.5})
	AnimationDB:addAni('bandanaColor','menuPlayer',{16,17,18,19,20},{.5,.5,.5,.5,.5})
	AnimationDB:addAni('jumpFallWhite','whitePlayer',{17,5,6,5,17},{.05,.05,.5,.05,.5})
	
	--AnimationDB:loadImage('startAnimated.png','startButton',tileSize,tileSize, "menu")
	--AnimationDB:addAni('startOn','startButton',{1,2,3,4,3,2},{.5,.1,.05,.05,.05,.1})
	--AnimationDB:addAni('startOff','startButton',{1,2,3,4,3,2},{.5,.2,.1,.1,.1,.2})
end
