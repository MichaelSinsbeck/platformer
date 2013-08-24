-- Animation Database

AnimationDB = {
source = {},
animation = {}
}

function AnimationDB:loadImage(imagefilename,name,height,width)
	-- Load image and prepare quads (height and width are optional)
	imagefilename = 'images/'.. Camera.scale*8 .. imagefilename
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

function AnimationDB:loadAll()
	local tileSize = Camera.scale*10
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

	AnimationDB:loadImage('tiles6_gapped.png','tiles',tileSize,tileSize)
	AnimationDB:addAni('Spikey1','tiles',{25},{1e6})
	AnimationDB:addAni('Spikey2','tiles',{26},{1e6})
	AnimationDB:addAni('Spikey3','tiles',{27},{1e6})
	AnimationDB:addAni('Spikey4','tiles',{28},{1e6})
	AnimationDB:addAni('Spikey5','tiles',{31},{1e6})
	AnimationDB:addAni('Spikey6','tiles',{32},{1e6})
	AnimationDB:addAni('Spikey7','tiles',{33},{1e6})
	AnimationDB:addAni('Spikey8','tiles',{34},{1e6})
	AnimationDB:addAni('Spikey9','tiles',{37},{1e6})
	AnimationDB:addAni('Spikey10','tiles',{38},{1e6})
	AnimationDB:addAni('Spikey11','tiles',{39},{1e6})
	AnimationDB:addAni('Spikey12','tiles',{40},{1e6})
	AnimationDB:addAni('Spikey13','tiles',{43},{1e6})
	AnimationDB:addAni('Spikey14','tiles',{44},{1e6})
	AnimationDB:addAni('Spikey15','tiles',{45},{1e6})
	AnimationDB:addAni('Spikey16','tiles',{46},{1e6})

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
end