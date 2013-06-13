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

AnimationDB:loadImage('images/player_blue.png','player',50,50)
AnimationDB:addAni('playerRun','player',{2,1,3,1},{.08,.04,.08,.04})
AnimationDB:addAni('playerJump','player',{5},{1e6})
AnimationDB:addAni('playerFall','player',{6,7},{.1,1e6})
AnimationDB:addAni('playerWall','player',{9,10,11},{0.4,0.075,1e6})
AnimationDB:addAni('playerSliding','player',{4},{1e6})
AnimationDB:addAni('playerGliding','player',{13,14,15},{.1,.1,1e6})
AnimationDB:addAni('playerStand','player',{1},{1e6})

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
