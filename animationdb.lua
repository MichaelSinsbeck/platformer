-- Animation Database

AnimationDB = {
source = {},
animation = {}
}

function AnimationDB:loadImage(imagefile,name,height,width)
	-- Load image and prepare quads
	self.source[name] = {}
	self.source[name].image = love.graphics.newImage(imagefile)
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

AnimationDB:loadImage('images/player_white.png','whitePlayer',50,50)
AnimationDB:addAni('whiteRun','whitePlayer',{2,1,3,1},{.08,.04,.08,.04})
AnimationDB:addAni('whiteJump','whitePlayer',{5},{1e6})
AnimationDB:addAni('whiteFall','whitePlayer',{6,7},{.1,1e6})
AnimationDB:addAni('whiteWall','whitePlayer',{9,10,11},{0.4,0.075,1e6})
AnimationDB:addAni('whiteSliding','whitePlayer',{4},{1e6})
AnimationDB:addAni('whiteStand','whitePlayer',{1},{1e6})

AnimationDB:loadImage('images/player_blue.png','bluePlayer',50,50)
AnimationDB:addAni('blueRun','bluePlayer',{2,1,3,1},{.08,.04,.08,.04})
AnimationDB:addAni('blueJump','bluePlayer',{5},{1e6})
AnimationDB:addAni('blueFall','bluePlayer',{6,7},{.1,1e6})
AnimationDB:addAni('blueWall','bluePlayer',{9,10,11},{0.4,0.075,1e6})
AnimationDB:addAni('blueSliding','bluePlayer',{4},{1e6})
AnimationDB:addAni('blueGliding','bluePlayer',{13,14,15},{.1,.1,1e6})
AnimationDB:addAni('blueStand','bluePlayer',{1},{1e6})

AnimationDB:loadImage('images/player_red.png','redPlayer',50,50)
AnimationDB:addAni('redRun','redPlayer',{2,1,3,1},{.08,.04,.08,.04})
AnimationDB:addAni('redJump','redPlayer',{5},{1e6})
AnimationDB:addAni('redFall','redPlayer',{6,7},{.1,1e6})
AnimationDB:addAni('redWall','redPlayer',{9,10,11},{0.4,0.075,1e6})
AnimationDB:addAni('redSliding','redPlayer',{4},{1e6})
AnimationDB:addAni('redStand','redPlayer',{1},{1e6})

AnimationDB:loadImage('images/player_green.png','greenPlayer',50,50)
AnimationDB:addAni('greenRun','greenPlayer',{2,1,3,1},{.08,.04,.08,.04})
AnimationDB:addAni('greenJump','greenPlayer',{5},{1e6})
AnimationDB:addAni('greenFall','greenPlayer',{6,7},{.1,1e6})
AnimationDB:addAni('greenWall','greenPlayer',{9,10,11},{0.4,0.075,1e6})
AnimationDB:addAni('greenSliding','greenPlayer',{4},{1e6})
AnimationDB:addAni('greenStand','greenPlayer',{1},{1e6})
AnimationDB:addAni('greenInvisible','greenPlayer',{13,14,15,16,200},{0.08,0.08,0.08,0.08,1e6})

AnimationDB:loadImage('images/launcher.png','launcher',50,50)
AnimationDB:addAni('launcherLoading','launcher',{1,2,3},{.45,.45,1e6})

AnimationDB:loadImage('images/explosion.png','explosion',50,50)
AnimationDB:addAni('explosionExplode','explosion',{1,2,3,4,5,6,6},{.05,.05,.1,.1,.1,.1,1e6})

AnimationDB:loadImage('images/tiles6_gapped.png','tiles',50,50)
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

AnimationDB:loadImage('images/bandana.png','bandana',50,50)
AnimationDB:addAni('whiteBandana','bandana',{1,2,3,4,5,6,7,8},{.05,.05,.05,.05,.05,.05,.05,.05})
AnimationDB:addAni('blueBandana','bandana',{9,10,11,12,13,14,15,16},{.05,.05,.05,.05,.05,.05,.05,.05})
AnimationDB:addAni('redBandana','bandana',{17,18,19,20,21,22,23,24},{.05,.05,.05,.05,.05,.05,.05,.05})
AnimationDB:addAni('greenBandana','bandana',{25,26,27,28,29,30,31,32},{.05,.05,.05,.05,.05,.05,.05,.05})

AnimationDB:loadImage('images/poff.png','poff',20,20)
AnimationDB:addAni('poff','poff',{1,2,3,4,4},{.05,.05,.1,.1,1e6})
