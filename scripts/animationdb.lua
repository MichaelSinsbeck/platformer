-- Animation Database

AnimationDB = {
image = {}, -- pure image
source = {}, -- collection of quad for an image
animation = {}, -- collection of specific frames and times to make an animation
silhouette = {}, -- these are only for the background silhouettes
}

local vectorAnimations = {}

local R = 3
local HR = 1.5

function AnimationDB:loadImage(imagefilename,name,subfolder) -- loads Image into database and returns its size
	if self.image[name] then
		print('Warning: Image "'.. name .. '" already exists')
	end
	if subfolder then
		imagefilename = 'images/'.. subfolder .. "/" .. Camera.scale*8 .. imagefilename
	else
		imagefilename = 'images/'.. Camera.scale*8 .. imagefilename
	end
	local image = love.graphics.newImage(imagefilename)
	image:setFilter('linear','linear')
	image:setWrap('clamp', 'clamp')
	self.image[name] = image

	return image, image:getWidth(), image:getHeight()
end

-- Loads an image (as in loadImage) and creates quads according to tile size
function AnimationDB:loadTiledImage(imagefilename,name,height,width,subfolder,generateMeshes)
	local image, imageWidth, imageHeight = self:loadImage(imagefilename,name,subfolder)
	local tileSize = Camera.scale*10
	if height then
		height = height * tileSize
	else
		height = imageHeight
	end
	if width then
		width = width * tileSize
	else
		width =  imageWidth
	end

	local thisSource = {}
	self.source[name] = thisSource
	
	thisSource.name = name
	thisSource.height = {}
	thisSource.width = {}
	thisSource.quads = {}
	thisSource.meshes = {}
   

  local tilesX, tilesY = math.floor(imageWidth/width), math.floor(imageHeight/height)
  for j = 1,tilesY do
    for i = 1,tilesX do
			local thisIndex = i+(j-1)*math.floor(imageWidth/width)
			thisSource.width[thisIndex] = width
			thisSource.height[thisIndex] = height
			
     thisSource.quads[thisIndex] = 
        love.graphics.newQuad((i-1)*(width),(j-1)*(height), width, height,
        imageWidth,imageHeight)

		if generateMeshes then
			local verts = {}
			-- place vert in center:
			verts[1] = {
				width*0.5, height*0.5,
				(i-0.5)/tilesX, (j-0.5)/tilesY
			}
			local k = 2
			verts[k] = {
				0+math.random(R)-HR, 0+math.random(R)-HR,
				(i-1)/tilesX, (j-1)/tilesY,
			} k = k + 1
			verts[k] = {
				width/2+math.random(R)-HR, 0+math.random(R)-HR,
				(i-0.5)/tilesX, (j-1)/tilesY,
			} k = k + 1
			verts[k] = {
				width+math.random(R)-HR, 0+math.random(R)-HR,
				(i)/tilesX, (j-1)/tilesY,
			} k = k + 1
			verts[k] = {
				width+math.random(R)-HR, height/2+math.random(R)-HR,
				(i)/tilesX, (j-0.5)/tilesY,
			} k = k + 1
			verts[k] = {
				width+math.random(R)-HR, height+math.random(R)-HR,
				(i)/tilesX, (j)/tilesY,
			} k = k + 1
			verts[k] = {
				width/2+math.random(R)-HR, height+math.random(R)-HR,
				(i-0.5)/tilesX, (j)/tilesY,
			} k = k + 1
			verts[k] = {
				0+math.random(R)-HR, height+math.random(R)-HR,
				(i-1)/tilesX, (j)/tilesY,
			} k = k + 1
			verts[k] = {
				0+math.random(R)-HR, height/2+math.random(R)-HR,
				(i-1)/tilesX, (j-0.5)/tilesY,
			} k = k + 1
			verts[k] = verts[2]
			
			thisSource.meshes[thisIndex] = 
				love.graphics.newMesh( verts, image )
		end
    end
  end
end

function AnimationDB:addTile(name,x,y,width,height) -- only use for irregular sprite atlasses
	local tileSize = Camera.scale*10 
	
	-- if source does not exist, create
	if not self.source[name] then
		self.source[name] = {}
		self.source[name].name = name
		self.source[name].width = {}
		self.source[name].height = {}
		self.source[name].quads = {}
		self.source[name].meshes = {}
	end
	local thisSource = self.source[name]
	local thisImage = self.image[name]
	local imageWidth, imageHeight = thisImage:getWidth(), thisImage:getHeight()
	
	local newIndex = #thisSource.quads + 1
	
	thisSource.width[newIndex] = tileSize * width
	thisSource.height[newIndex] = tileSize * height
	thisSource.quads[newIndex] = 
		love.graphics.newQuad(tileSize*x,tileSize*y,tileSize*width,tileSize*height,
		  imageWidth,imageHeight)
	
end

function AnimationDB:addAni(name,source,frames,duration,updateFunction)
	-- check, iff both input tables have the same length and add zeros, if necessary
	local frameLength = #frames
	local durationLength = #duration
	if frameLength > durationLength then
		for excess = durationLength+1,frameLength do
			duration[excess] = 0
		end
	end
	local thisAnimation = {}
	self.animation[name] = thisAnimation
	thisAnimation.source = source
	thisAnimation.frames = frames
	thisAnimation.duration = duration
	-- take first frame of the animation to determine size
	local thisSource = self.source[source]
	thisAnimation.width = thisSource.width[frames[1]]
	thisAnimation.height = thisSource.height[frames[1]]
	
	thisAnimation.updateFunction = updateFunction
	if name == "gamepadRB" then
		print( self.animation[name],
			source, frames, duration, updateFunction )
	end
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

function AnimationDB:addSilhouette(x,y,width,height,sw,sh)

	local tileSize = Camera.scale*8 -- (Different from the other code, there it is *10)
	local quad = love.graphics.newQuad(tileSize*x,tileSize*y+1,tileSize*width,tileSize*height-1,sw,sh)
	
	if not self.silhouette then self.silhouette = {} end
	table.insert(self.silhouette,quad)
end

function AnimationDB:loadAll()
	local tileSize = Camera.scale*10
	AnimationDB:loadBackgrounds()
	
	AnimationDB:clearImages()	
	AnimationDB:loadAllImages()
	AnimationDB:loadAnimations()
	AnimationDB:addAllSilhouettes()	
end

function AnimationDB:clearImages()
	self.source = {}
	self.image = {}
	--collectgarbage()
end

function AnimationDB:loadAllImages()
	local tileSize = Camera.scale*10
	-- tiles
	AnimationDB:loadImage('grounds.png','tilesetGround','tilesets')
	AnimationDB:loadImage('backgrounds.png','tilesetBackground','tilesets')
	AnimationDB:loadImage('background1.png','background1','tilesets')
	-- editor stuff
	AnimationDB:loadImage('cell.png','cell','editor')
	AnimationDB.image['cell']:setWrap('repeat', 'repeat')
	
	AnimationDB:loadImage('fill.png','fill','editor')
	AnimationDB:loadImage('pinLeft.png','pinLeft','editor')
	AnimationDB:loadImage('pinRight.png','pinRight','editor')
	AnimationDB:loadTiledImage('highlight.png','highlight',1.4,1.4,'editor')
	AnimationDB:loadTiledImage('button.png','editorButton',1,1, "editor", true)
	AnimationDB:loadTiledImage('buttonProperties.png','editorButtonProperties',0.5,0.5, "editor", true )
	AnimationDB:loadTiledImage('buttonPages.png','editorButtonPages',0.5,1, "editor", true)
	
	-- menu stuff
	AnimationDB:loadImage('logo.png','logo','menu')
	AnimationDB:loadImage('startOff.png','startOff','menu')
	AnimationDB:loadImage('startOn.png','startOn','menu')
	AnimationDB:loadImage('settingsOff.png','settingsOff','menu')
	AnimationDB:loadImage('settingsOn.png','settingsOn','menu')
	AnimationDB:loadImage('editorOff.png','editorOff','menu')
	AnimationDB:loadImage('editorOn.png','editorOn','menu')
	AnimationDB:loadImage('exitOff.png','exitOff','menu')
	AnimationDB:loadImage('exitOn.png','exitOn','menu')
	AnimationDB:loadImage('downloadOff.png','downloadOff','menu')
	AnimationDB:loadImage('downloadOn.png','downloadOn','menu')
	AnimationDB:loadImage('creditsOff.png','creditsOff','menu')
	AnimationDB:loadImage('creditsOn.png','creditsOn','menu')
	AnimationDB:loadImage('worldItemOff.png','worldItemOff','menu')
	AnimationDB:loadImage('worldItemOn.png','worldItemOn','menu')
	AnimationDB:loadImage('worldItemInactive.png','worldItemInactive','menu')
	--[[AnimationDB:loadImage('gamepadA.png','gamepadA','menu')
	AnimationDB:loadImage('gamepadB.png','gamepadB','menu')
	AnimationDB:loadImage('gamepadX.png','gamepadX','menu')
	AnimationDB:loadImage('gamepadY.png','gamepadY','menu')
	AnimationDB:loadImage('gamepadUp.png','gamepadUp','menu')
	AnimationDB:loadImage('gamepadDown.png','gamepadDown','menu')
	AnimationDB:loadImage('gamepadRight.png','gamepadRight','menu')
	AnimationDB:loadImage('gamepadLeft.png','gamepadLeft','menu')
	AnimationDB:loadImage('gamepadLB.png','gamepadLB','menu')
	AnimationDB:loadImage('gamepadRB.png','gamepadRB','menu')
	AnimationDB:loadImage('gamepadStart.png','gamepadStart','menu')
	AnimationDB:loadImage('gamepadBack.png','gamepadBack','menu')]]
	AnimationDB:loadImage('keyNone.png','keyNone','menu')
	AnimationDB:loadImage('restartOff.png','restartOff','menu')
	AnimationDB:loadImage('restartOn.png','restartOn','menu')
	AnimationDB:loadImage('paused.png','paused','menu')
	AnimationDB:loadImage('world1.png','world1','world')
	AnimationDB:loadImage('world2.png','world2','world')
	AnimationDB:loadImage('world3.png','world3','world')
	AnimationDB:loadImage('world4.png','world4','world')
	AnimationDB:loadImage('world5.png','world5','world')
	AnimationDB:loadImage('silhouette1.png','silhouette1','menu')
	AnimationDB:loadImage('silhouette2.png','silhouette2','menu')
	AnimationDB:loadImage('silhouette3.png','silhouette3','menu')
	AnimationDB:loadImage('silhouette4.png','silhouette4','menu')
	AnimationDB:loadImage('silhouette5.png','silhouette5','menu')
	AnimationDB:loadImage('silhouette6.png','silhouette6','menu')
	AnimationDB:loadImage('silhouette7.png','silhouette7','menu')
	AnimationDB:loadImage('silhouette8.png','silhouette8','menu')
	AnimationDB:loadImage('silhouette9.png','silhouette9','menu')
	AnimationDB:loadImage('silhouette10.png','silhouette10','menu')
	AnimationDB:loadImage('silhouette11.png','silhouette11','menu')
	AnimationDB:loadImage('mountain1.png','mountain1','menu')
	AnimationDB:loadImage('mountain2.png','mountain2','menu')
	AnimationDB:loadImage('mountain3.png','mountain3','menu')
	AnimationDB:loadImage('mountain4.png','mountain4','menu')
	AnimationDB:loadImage('mountain5.png','mountain5','menu')
	
	AnimationDB:loadTiledImage('stars.png','stars', 1, 2, 'menu')
	AnimationDB:loadTiledImage('skulls.png','skulls', 1, 2, 'menu')
	AnimationDB:loadTiledImage('userlevelState.png','userlevelStates', 1, 1, 'menu')
	AnimationDB:loadTiledImage('authorizationState.png','authorizationState', 1, 1, 'menu')
	AnimationDB:loadTiledImage('acceptOff.png','acceptOff', 1, 1, 'menu')
	AnimationDB:loadTiledImage('acceptOn.png','acceptOn', 1, 1, 'menu')
	AnimationDB:loadTiledImage('cancelOff.png','cancelOff', 1, 1, 'menu')
	AnimationDB:loadTiledImage('cancelOn.png','cancelOn', 1, 1, 'menu')

	AnimationDB:loadTiledImage('menuButtons.png','menuButtons', 1, 1, 'menu')
	AnimationDB:loadTiledImage('keyLargeOn.png','keyLargeOn', 1, 2, 'menu')
	AnimationDB:loadTiledImage('keyLargeOff.png','keyLargeOff', 1, 2, 'menu')
	AnimationDB:loadTiledImage('keyOn.png','keyOn', 1, 1, 'menu')
	AnimationDB:loadTiledImage('keyOff.png','keyOff', 1, 1, 'menu')
	AnimationDB:loadTiledImage('keyAssignment.png','keyAssignment', 1, 3, 'menu')
	AnimationDB:loadTiledImage('soundButton.png','soundButton', 1, 1, 'menu')
	AnimationDB:loadTiledImage('graphicsButton.png','graphicsButton', 1, 1, 'menu')
	AnimationDB:loadTiledImage('fullscreenButton.png','fullscreenButton', 1, 1, 'menu')
	AnimationDB:loadTiledImage('shadersButton.png','shadersButton', 1, 1, 'menu')
	AnimationDB:loadTiledImage('gamepadA.png','gamepadA',1,1,'menu')
	AnimationDB:loadTiledImage('gamepadB.png','gamepadB',1,1,'menu')
	AnimationDB:loadTiledImage('gamepadX.png','gamepadX',1,1,'menu')
	AnimationDB:loadTiledImage('gamepadY.png','gamepadY',1,1,'menu')
	AnimationDB:loadTiledImage('gamepadUp.png','gamepadUp',1,1,'menu')
	AnimationDB:loadTiledImage('gamepadDown.png','gamepadDown',1,1,'menu')
	AnimationDB:loadTiledImage('gamepadRight.png','gamepadRight',1,1,'menu')
	AnimationDB:loadTiledImage('gamepadLeft.png','gamepadLeft',1,1,'menu')
	AnimationDB:loadTiledImage('gamepadLB.png','gamepadLB',1,2,'menu')
	AnimationDB:loadTiledImage('gamepadRB.png','gamepadRB',1,2,'menu')
	AnimationDB:loadTiledImage('gamepadStart.png','gamepadStart',1,1,'menu')
	AnimationDB:loadTiledImage('gamepadBack.png','gamepadBack',1,1,'menu')
	AnimationDB:loadTiledImage('keyNone.png','keyNone',1,1,'menu')
	
	-- gui stuff
	AnimationDB:loadTiledImage('bean.png','bean',1,1,'gui')
	AnimationDB:loadTiledImage('guiBandanas.png','guiBandanas',2,2,'gui')
	AnimationDB:loadTiledImage('upgrades.png','upgrades',4,6,'gui')
	AnimationDB:loadTiledImage('banner.png','banner',2,9,'gui')
	
	-- ingame stuff
	AnimationDB:loadTiledImage('objects.png','objects',1,1)
	AnimationDB:loadTiledImage('small_objects.png','small',0.4,0.4)
	AnimationDB:loadTiledImage('player.png','player',1,1)
	AnimationDB:loadTiledImage('icons.png','icons',1,1)
	AnimationDB:loadImage('irregular.png','irregular')
	
	AnimationDB:addTile('irregular',0,0,0.6,0.6) -- poff
	AnimationDB:addTile('irregular',0.6,0,0.6,0.6)
	AnimationDB:addTile('irregular',1.2,0,0.6,0.6)
	AnimationDB:addTile('irregular',1.8,0,0.6,0.6)
	AnimationDB:addTile('irregular',2.4,0,0.6,0.6)
	AnimationDB:addTile('irregular',3,0,1,2) -- npc
	AnimationDB:addTile('irregular',0,0.6,1.4,1.4) -- cross
	AnimationDB:addTile('irregular',1.4,0.8,0.8,1.2) -- log
	AnimationDB:addTile('irregular',2.4,1.4,0.2,0.6) -- winddots
	AnimationDB:addTile('irregular',2.6,1.4,0.2,0.6)
	AnimationDB:addTile('irregular',2.8,1.4,0.2,0.6)
	AnimationDB:addTile('irregular',0,2,4,1) -- woosh
	AnimationDB:addTile('irregular',0,3,4,2.2)
	

	AnimationDB:loadTiledImage('door.png','door',1,1)	
	AnimationDB:loadTiledImage('bumper.png','bumper')
	AnimationDB:loadTiledImage('light.png','light',1,1)	
	AnimationDB:loadTiledImage('menuPlayer.png','menuPlayer',1,1, "menu")
	AnimationDB:loadTiledImage('blockblock.png','blockblock',1,1)
	AnimationDB:loadTiledImage('shurikenlarge.png','shurikenlarge')
	
	-- for prototyping - remove later
	AnimationDB:loadTiledImage('placeholder.png','placeholder',1,1)
	
	--AnimationDB:loadTiledImage('lineHook.png','lineHook',1,1)

	--AnimationDB:loadTiledImage('listCount.png','listCount',1,1)
	AnimationDB:loadTiledImage('deaths.png','deaths',2,2,'statistics')
	AnimationDB:loadTiledImage('statIdle.png', 'statIdle', 2, 3 ,'statistics')
	AnimationDB:loadTiledImage('statNoDeath1.png', 'statNoDeath1', 3, 3,'statistics')
	AnimationDB:loadTiledImage('statNoDeath2.png', 'statNoDeath2', 3, 3,'statistics')
	AnimationDB:loadTiledImage('statHighestJump.png', 'statHighestJump', 4, 2,'statistics')
	AnimationDB:loadTiledImage('statLongestJump.png', 'statLongestJump', 2, 2 ,'statistics')
	AnimationDB:loadTiledImage('statTimeInAir.png', 'statTimeInAir', 2, 3 ,'statistics')
	AnimationDB:loadTiledImage('statNumberOfJumps.png', 'statNumberOfJumps', 2, 2 ,'statistics')
	AnimationDB:loadTiledImage('statWallHang.png', 'statWallHang', 2, 2 ,'statistics')
	AnimationDB:loadTiledImage('statVelocity.png', 'statVelocity', 2, 4 ,'statistics')
	AnimationDB:loadTiledImage('statTime.png', 'statTime', 4, 2 ,'statistics')
	AnimationDB:loadTiledImage('statNumberOfButtons.png', 'statNumberOfButtons', 4, 4,'statistics')
	-- credits
	AnimationDB:loadImage('creditsDesign.png', 'creditsDesign', 'credits')
	AnimationDB:loadImage('creditsGraphics.png', 'creditsGraphics', 'credits')
	AnimationDB:loadImage('creditsProgramming.png', 'creditsProgramming', 'credits')
	AnimationDB:loadImage('creditsMusic.png', 'creditsMusic', 'credits')
	AnimationDB:loadImage('creditsSound.png', 'creditsSound', 'credits')
	AnimationDB:loadImage('creditsFramework.png', 'creditsFramework', 'credits')
end

function AnimationDB:loadAnimations()
	
	-- for prototyping - remove later	
	AnimationDB:addAni('placeholder08','placeholder',{1},{1e6})
	AnimationDB:addAni('placeholder06','placeholder',{2},{1e6})
	AnimationDB:addAni('placeholder04','placeholder',{3},{1e6})
	AnimationDB:addAni('placeholder02','placeholder',{4},{1e6})

  -- player related
	AnimationDB:addAni('playerRun','player',{6,4,5,4},{.08,.04,.08,.04})
	AnimationDB:addAni('playerWalk','player',{2,1,3,1},{.08,.04,.08,.04})
	AnimationDB:addAni('playerJump','player',{7},{1e6})
	AnimationDB:addAni('playerFall','player',{8,9},{.1,1e6})
	AnimationDB:addAni('playerWall','player',{10,11,12},{0.4,0.075,1e6})
	AnimationDB:addAni('playerSliding','player',{18},{1e6})
	AnimationDB:addAni('playerStand','player',{1},{1e6})
	AnimationDB:addAni('playerLineSlide','player',{17},{1e6})
	AnimationDB:addAni('playerLineMove','player',{13,14,15,14},{0.08,0.04,0.08,0.04})
	AnimationDB:addAni('playerLineHang','player',{16},{1e6})
	AnimationDB:addAni('playerDoubleJump','player',{9,8,7},{.1,.1,1e6})
	AnimationDB:addAni('playerHooked','player',{22},{1e6})
	AnimationDB:addAni('playerGliding','player',{19,20,21},{.1,.1,1e6})
	
	AnimationDB:addAni('smoke','player',{25,26,27,28,29,29},{.1,.1,.15,.15,.1,1e6})

	AnimationDB:addAni('bandanaRun','player',{36,34,35,34},{.08,.04,.08,.04})
	AnimationDB:addAni('bandanaWalk','player',{32,31,33,31},{.08,.04,.08,.04})
	AnimationDB:addAni('bandanaJump','player',{37},{1e6})
	AnimationDB:addAni('bandanaFall','player',{38,39},{.1,1e6})
	AnimationDB:addAni('bandanaWall','player',{40,41,42},{0.4,0.075,1e6})
	AnimationDB:addAni('bandanaSliding','player',{48},{1e6})
	AnimationDB:addAni('bandanaStand','player',{31},{1e6})
	AnimationDB:addAni('bandanaLineSlide','player',{47},{1e6})
	AnimationDB:addAni('bandanaLineMove','player',{43,44,45,44},{0.08,0.04,0.08,0.04})
	AnimationDB:addAni('bandanaLineHang','player',{46},{1e6})
	AnimationDB:addAni('bandanaDoubleJump','player',{39,38,37},{.1,.1,1e6})
	AnimationDB:addAni('bandanaHooked','player',{52},{1e6})	
	AnimationDB:addAni('bandanaGliding','player',{49,50,51},{.1,.1,1e6})

	-- objects
	AnimationDB:addAni('shuriken','objects',{1},{1e6})
	AnimationDB:addAni('shurikenDead','objects',{2},{1e6})
	AnimationDB:addAni('anchor','objects',{3},{1e6})
	AnimationDB:addAni('redBlockSolid','objects',{4},{1e6})
	AnimationDB:addAni('redBlockPassable','objects',{5},{1e6})
	AnimationDB:addAni('blueBlockSolid','objects',{6},{1e6})
	AnimationDB:addAni('blueBlockPassable','objects',{7},{1e6})
	AnimationDB:addAni('greenBlockSolid','objects',{8},{1e6})
	AnimationDB:addAni('greenBlockPassable','objects',{9},{1e6})
	AnimationDB:addAni('yellowBlockSolid','objects',{10},{1e6})

	AnimationDB:addAni('yellowBlockPassable','objects',{11},{1e6})
	AnimationDB:addAni('starBandana','objects',{12},{1e6})
	AnimationDB:addAni('whiteBandana','objects',{13},{1e6})
	AnimationDB:addAni('chickenleg','objects',{14},{1e6})
	AnimationDB:addAni('bean','objects',{15},{1e6})
	AnimationDB:addAni('strongBouncer','objects',{18,17},{0.1,1e6})
	AnimationDB:addAni('mediumBouncer','objects',{20,19},{0.1,1e6})

	AnimationDB:addAni('weakBouncer','objects',{22,21},{0.1,1e6})
	AnimationDB:addAni('button','objects',{24},{1e6})
	AnimationDB:addAni('buttonPressed','objects',{26},{1e6})
	AnimationDB:addAni('buttonReleased','objects',{25},{1e6})
	AnimationDB:addAni('redButton','objects',{27},{1e6})
	AnimationDB:addAni('blueButton','objects',{28},{1e6})
	AnimationDB:addAni('greenButton','objects',{29},{1e6})
	AnimationDB:addAni('yellowButton','objects',{30},{1e6})

	AnimationDB:addAni('cannon','objects',{33},{1e6})
	AnimationDB:addAni('followerBack','objects',{38},{1e6})
	AnimationDB:addAni('followerOpen','objects',{34,35,36,37},{0.1,0.1,0.1,1e6})
	AnimationDB:addAni('followerClose','objects',{37,36,35,34},{0.1,0.1,0.1,1e6})
	AnimationDB:addAni('followerPupil','objects',{39},{1e6})

	AnimationDB:addAni('exit','objects',{40,41,42,43,40,44,45},{.1,.1,.1,.1,.1,.1,.1})
	AnimationDB:addAni('explosionExplode','objects',{46,47,48,49,50,51,51},{.05,.05,.1,.1,.1,.1,1e6})
	AnimationDB:addAni('fixedcannon','objects',{54},{1e6})
	AnimationDB:addAni('glassblock','objects',{53},{1e6})
	AnimationDB:addAni('goalie','objects',{54},{1e6})

	AnimationDB:addAni('imitatorRun','objects',{58,56,57,56},{.08,.04,.08,.04})
	AnimationDB:addAni('imitatorWalk','objects',{65,63,64,63},{.08,.04,.08,.04})
	AnimationDB:addAni('imitatorJump','objects',{60},{1e6})
	AnimationDB:addAni('imitatorFall','objects',{61,62},{.1,1e6})
	AnimationDB:addAni('imitatorStand','objects',{63},{1e6})
	AnimationDB:addAni('imitatorSliding','objects',{59},{1e6})
	
	AnimationDB:addAni('laser','objects',{66},{1e6})
	AnimationDB:addAni('laserDot','objects',{67,68},{0.1,0.1})
	AnimationDB:addAni('launcher','objects',{69},{1e6})

	AnimationDB:addAni('missile','objects',{70},{1e6})
	AnimationDB:addAni('rock','objects',{71},{1e6})
	AnimationDB:addAni('rotatorBlock','objects',{72},{1e6})
	AnimationDB:addAni('rotatorCap','objects',{73},{1e6})
	AnimationDB:addAni('rotatorStick','objects',{74},{1e6})
	AnimationDB:addAni('signEmpty','objects',{75},{1e6})
	AnimationDB:addAni('signBandana','objects',{76},{1e6})
	AnimationDB:addAni('signCross','objects',{77},{1e6})
	AnimationDB:addAni('signText','objects',{78},{1e6})
	AnimationDB:addAni('signLeft','objects',{79},{1e6})

	AnimationDB:addAni('signRight','objects',{80},{1e6})
	AnimationDB:addAni('spawnerfront','objects',{81},{1e6})	
	AnimationDB:addAni('spawnerback','objects',{82},{1e6})
	AnimationDB:addAni('spawnerbar','objects',{83},{1e6})
	AnimationDB:addAni('spawnersymbolenemy','objects',{84},{1e6})
	AnimationDB:addAni('spawnersymbolbouncy','objects',{85},{1e6})

	AnimationDB:addAni('enemyprewalker','objects',{97},{1e6})
	AnimationDB:addAni('enemywalker','objects',{90},{1e6})
	AnimationDB:addAni('enemywalkerfoot','objects',{91},{1e6})
	AnimationDB:addAni('enemywalkerfoot2','objects',{92},{1e6})
	AnimationDB:addAni('bouncyprewalker','objects',{96},{1e6})
	AnimationDB:addAni('bouncywalker1','objects',{93},{1e6})
	AnimationDB:addAni('bouncywalker2','objects',{99},{1e6})
	AnimationDB:addAni('bouncywalkerfoot','objects',{94},{1e6})
	AnimationDB:addAni('bouncywalkerfoot2','objects',{95},{1e6})	
	AnimationDB:addAni('bouncywalkerblink1','objects',{98,93},{0.1,1e6})
	AnimationDB:addAni('bouncywalkerblink2','objects',{100,99},{0.1,1e6})

	-- small objects
	AnimationDB:addAni('crumble1','small',{1},{1e6})
	AnimationDB:addAni('crumble2','small',{2},{1e6})
	AnimationDB:addAni('crumble3','small',{3},{1e6})
	AnimationDB:addAni('crumble4','small',{4},{1e6})
	AnimationDB:addAni('crumble5','small',{5},{1e6})
	AnimationDB:addAni('crumble6','small',{6},{1e6})
	AnimationDB:addAni('crumble7','small',{7},{1e6})
	AnimationDB:addAni('crumble8','small',{8},{1e6})
	AnimationDB:addAni('crumble9','small',{9},{1e6})
	AnimationDB:addAni('crumble10','small',{10},{1e6})
	AnimationDB:addAni('crumble11','small',{11},{1e6})
	AnimationDB:addAni('crumble12','small',{12},{1e6})

	AnimationDB:addAni('glass1','small',{13},{1e6})
	AnimationDB:addAni('glass2','small',{14},{1e6})
	AnimationDB:addAni('glass3','small',{15},{1e6})
	AnimationDB:addAni('glass4','small',{16},{1e6})	
	AnimationDB:addAni('anchor1','small',{17},{1e6})
	AnimationDB:addAni('anchor2','small',{18},{1e6})
	AnimationDB:addAni('anchor3','small',{19},{1e6})
	AnimationDB:addAni('anchor4','small',{20},{1e6})	
	AnimationDB:addAni('meat1','small',{21},{1e6})
	AnimationDB:addAni('meat2','small',{22},{1e6})
	AnimationDB:addAni('meat3','small',{23},{1e6})
	AnimationDB:addAni('meat4','small',{24},{1e6})
	
	AnimationDB:addAni('droplet1','small',{25},{1e6})
	AnimationDB:addAni('droplet2','small',{26},{1e6})
	AnimationDB:addAni('droplet3','small',{27},{1e6})
	AnimationDB:addAni('droplet4','small',{28},{1e6})
	AnimationDB:addAni('meatWall','small',{29},{1e6})
	AnimationDB:addAni('meatCorner','small',{30},{1e6})
	AnimationDB:addAni('dropletWall','small',{31},{1e6})
	AnimationDB:addAni('dropletCorner','small',{32},{1e6})	

	AnimationDB:addAni('particle1','small',{33},{1e6})
	AnimationDB:addAni('particle2','small',{34},{1e6})
	AnimationDB:addAni('particle3','small',{35},{1e6})
	AnimationDB:addAni('bungee','small',{36},{1e6})

	-- icons
	AnimationDB:addAni('cameraRound','icons',{1},{1e6})
	AnimationDB:addAni('cameraRectangle','icons',{2},{1e6})
	AnimationDB:addAni('parallaxConfig','icons',{3},{1e6})
	AnimationDB:addAni('lineHook'  ,'icons',{4},{1e6})
	AnimationDB:addAni('windmillpreview','icons',{5},{1e6})

	AnimationDB:addAni('speechbubbleSector','icons',{6},{1e6})
	AnimationDB:addAni('speechbubbleTimer','icons',{7},{1e6})
	AnimationDB:addAni('speechbubblepointer','icons',{8},{1e6})
	AnimationDB:addAni('upwind','icons',{9},{1e6})

	AnimationDB:addAni('listCount1','icons',{11},{1e6})
	AnimationDB:addAni('listCount2','icons',{12},{1e6})
	AnimationDB:addAni('listCount3','icons',{13},{1e6})
	AnimationDB:addAni('listCount4','icons',{14},{1e6})
	AnimationDB:addAni('listCount5','icons',{15},{1e6})

	-- irregular sprites
	
	AnimationDB:addAni('poff','irregular',{1,2,3,4,5,5},{.05,.075,.15,.15,.1,1e6})
	AnimationDB:addAni('npc','irregular',{6},{1e6})
	AnimationDB:addAni('crosshairs','irregular',{7},{1e6})
	AnimationDB:addAni('log','irregular',{8},{1e6})
	AnimationDB:addAni('wind1','irregular',{9},{1e6})
	AnimationDB:addAni('wind2','irregular',{10},{1e6})
	AnimationDB:addAni('wind3','irregular',{11},{1e6})
	AnimationDB:addAni('woosh','irregular',{12},{1e6})
	AnimationDB:addAni('windmillwing','irregular',{13},{1e6})
	
	


	-- maybe delete these
	AnimationDB:addAni('blockblock','blockblock',{1},{1e6})
	AnimationDB:addAni('shurikenlarge','shurikenlarge',{1},{1e6})
	AnimationDB:addAni('keyhole','door',{1},{1e6})	
	AnimationDB:addAni('door','door',{2},{1e6})	
	AnimationDB:addAni('key','door',{3},{1e6})				
	AnimationDB:addAni('bumper','bumper',{1},{1e6})
	AnimationDB:addAni('candle','light',{1},{1e6})
	AnimationDB:addAni('candlelight','light',{2,3,4,3},{.2,.2,.2,.2})
	AnimationDB:addAni('torch','light',{6},{1e6})		
	AnimationDB:addAni('flame','light',{7,8,7,9},{.2,.2,.2,.2})
	AnimationDB:addAni('lamp','light',{5},{1e6})
	AnimationDB:addAni('lamplight','light',{10},{1e6})


	
	AnimationDB:addAni('lookWhite','menuPlayer',{1},{1e6})
	AnimationDB:addAni('moveUpWhite','menuPlayer',{6,7,8,9,10,9,8,7,},{.01,.02,.03,.06,.1,.06,.03,.02})
	AnimationDB:addAni('moveDownWhite','menuPlayer',{11,12,13,14,15,14,13,12},{.01,.02,.03,.06,.1,.06,.03,.02})
	AnimationDB:addAni('bandanaColor','menuPlayer',{2,3,4,5},{.05,.05,.05,.05})
--	AnimationDB:addAni('jumpFallWhite','whitePlayer',{17,5,6,5,17},{.05,.05,.5,.05,.5})
	AnimationDB:addAni('playerScreenshot','menuPlayer',{21,22,23,24,25,21},{0.1,.01,.05,.02,.02,1})
	AnimationDB:addAni('playerFullscreen','menuPlayer',{26,27,28,29,30,31,32,33,34,35},{0.08,.04,.08,0.04,.2,.3,0.04,0.08,.08,.5})

	
	

	--[[AnimationDB:addAni('anchorprewalker','walker',{12},{1e6})
	AnimationDB:addAni('anchorwalker','walker',{15},{1e6})
	AnimationDB:addAni('anchorwalkerfoot','walker',{13},{1e6})
	AnimationDB:addAni('anchorwalkerfoot2','walker',{14},{1e6})--]]
	
	-- gui stuff
	AnimationDB:addAni('guiBeanFull','bean',{1},{1e6})
	AnimationDB:addAni('guiBeanEmpty','bean',{2},{1e6})
	AnimationDB:addAni('guiBandanaWhite','guiBandanas',{1},{1e6})
	AnimationDB:addAni('guiBandanaYellow','guiBandanas',{2},{1e6})
	AnimationDB:addAni('guiBandanaGreen','guiBandanas',{3},{1e6})
	AnimationDB:addAni('guiBandanaBlue','guiBandanas',{4},{1e6})
	AnimationDB:addAni('guiBandanaRed','guiBandanas',{5},{1e6})
	AnimationDB:addAni('guiBandanaNone','guiBandanas',{6},{1e6})	
	AnimationDB:addAni('banner','banner',{1},{1e6})
	
	AnimationDB:addAni('upgradeRice','upgrades',{1},{1e6})
	AnimationDB:addAni('upgradeWhite','upgrades',{2},{1e6})
	AnimationDB:addAni('upgradeYellow','upgrades',{3},{1e6})
	AnimationDB:addAni('upgradeGreen','upgrades',{4},{1e6})
	AnimationDB:addAni('upgradeBlue','upgrades',{5},{1e6})
	AnimationDB:addAni('upgradeRed','upgrades',{6},{1e6})
	
	-- editor stuff
	AnimationDB:addAni('clickableHighlight' ,'highlight',{1},{1e6})
	AnimationDB:addAni('clickableActive' ,'highlight',{2},{1e6})
	
	-- ground tiles
	AnimationDB:addAni('LEc','editorButton',{1},{1e6})
	AnimationDB:addAni('LEd','editorButton',{2},{1e6})
	AnimationDB:addAni('LEg','editorButton',{3},{1e6})
	AnimationDB:addAni('LEr','editorButton',{4},{1e6})
	AnimationDB:addAni('LEy','editorButton',{5},{1e6})
	AnimationDB:addAni('LEo','editorButton',{7},{1e6})
	AnimationDB:addAni('LEb','editorButton',{6},{1e6})
	AnimationDB:addAni('LEw','editorButton',{13},{1e6})
	-- spikes	
	AnimationDB:addAni('LE1','editorButton',{8},{1e6})
	AnimationDB:addAni('LE2','editorButton',{9},{1e6})
	AnimationDB:addAni('LE3','editorButton',{10},{1e6})
	AnimationDB:addAni('LE4','editorButton',{11},{1e6})
	AnimationDB:addAni('LE5','editorButton',{12},{1e6})
	-- backgrounds
	AnimationDB:addAni('LEBG1','editorButton',{28},{1e6})
	AnimationDB:addAni('LEBG2','editorButton',{29},{1e6})
	AnimationDB:addAni('LEBG3','editorButton',{30},{1e6})
	-- tool-panel
	AnimationDB:addAni('LEPen','editorButton',{14},{1e6})
	AnimationDB:addAni('LEStamp','editorButton',{15},{1e6})
	AnimationDB:addAni('LEOpen','editorButton',{16},{1e6})
	AnimationDB:addAni('LEDelete','editorButton',{17},{1e6})
	AnimationDB:addAni('LESave','editorButton',{18},{1e6})
	AnimationDB:addAni('LEExit','editorButton',{19},{1e6})
	AnimationDB:addAni('LEEdit','editorButton',{20},{1e6})
	AnimationDB:addAni('LELayerDown','editorButton',{21},{1e6})
	AnimationDB:addAni('LELayerUp','editorButton',{22},{1e6})
	AnimationDB:addAni('LEPlay','editorButton',{23},{1e6})
	AnimationDB:addAni('LEObject','editorButton',{24},{1e6})
	AnimationDB:addAni('LENew','editorButton',{25},{1e6})
	AnimationDB:addAni('LEAccept','editorButton',{26},{1e6})
	AnimationDB:addAni('LEMenu','editorButton',{27},{1e6})
	AnimationDB:addAni('LEDuplicate','editorButton',{31},{1e6})
	AnimationDB:addAni('LEUpload','editorButton',{32},{1e6})

	AnimationDB:addAni('LEUp'   ,'editorButtonProperties',{1},{1e6})
	AnimationDB:addAni('LEDown'   ,'editorButtonProperties',{2},{1e6})	
	AnimationDB:addAni('LELeft'   ,'editorButtonPages',{1},{1e6})
	AnimationDB:addAni('LERight'   ,'editorButtonPages',{2},{1e6})


	AnimationDB:addAni('cancelOn'   ,'cancelOn',{1},{1e6})
	AnimationDB:addAni('acceptOn'   ,'acceptOn',{1},{1e6})

	-- Menu Buttons:
	AnimationDB:addAni('startOn','menuButtons',{1},{1e6}, 
		vectorAnimations.startAniUpdate )
	AnimationDB:addAni('startOff','menuButtons',{2},{1e6} )
	AnimationDB:addAni('exitOn','menuButtons',{3},{1e6},
		vectorAnimations.defaultAniUpdate )
	AnimationDB:addAni('exitOff','menuButtons',{4},{1e6})
	AnimationDB:addAni('downloadOn','menuButtons',{5},{1e6}, 
		vectorAnimations.defaultAniUpdate )
	AnimationDB:addAni('downloadOff','menuButtons',{6},{1e6})
	AnimationDB:addAni('restartOn','menuButtons',{7},{1e6},
		vectorAnimations.restartAniUpdate )
	AnimationDB:addAni('restartOff','menuButtons',{8},{1e6})
	AnimationDB:addAni('editorOn','menuButtons',{9},{1e6},
		vectorAnimations.defaultAniUpdate )
	AnimationDB:addAni('editorOff','menuButtons',{10},{1e6})
	AnimationDB:addAni('acceptOn','menuButtons',{11},{1e6})
	AnimationDB:addAni('acceptOff','menuButtons',{12},{1e6})
	AnimationDB:addAni('settingsOn','menuButtons',{13},{1e6},
		vectorAnimations.settingsAniRestart )
	AnimationDB:addAni('settingsOff','menuButtons',{14},{1e6})
	AnimationDB:addAni('cancelOn','menuButtons',{15},{1e6})
	AnimationDB:addAni('cancelOff','menuButtons',{16},{1e6})
	AnimationDB:addAni('creditsOn','menuButtons',{17},{1e6},
		vectorAnimations.defaultAniUpdate )
	AnimationDB:addAni('creditsOff','menuButtons',{18},{1e6})
	AnimationDB:addAni('worldItemOn','menuButtons',{23},{1e6},
		vectorAnimations.pulseAniUpdate )
	AnimationDB:addAni('worldItemOff','menuButtons',{24},{1e6},
		vectorAnimations.resetAniUpdate )

	AnimationDB:addAni('sliderSegmentOff','menuButtons',{19},{1e6})
	AnimationDB:addAni('sliderSegmentOn','menuButtons',{20},{1e6})
	AnimationDB:addAni('sliderSegmentOffEnd','menuButtons',{21},{1e6})
	AnimationDB:addAni('sliderSegmentOnEnd','menuButtons',{22},{1e6})
	
	AnimationDB:addAni('keyAssignmentOn','menuButtons',{25,26},{0.25,0.25})
	AnimationDB:addAni('keyAssignmentOff','menuButtons',{27},{1e6})
	AnimationDB:addAni('musicOn','menuButtons',{29,30,29,31},{0.2,0.2,0.2,0.2})
	AnimationDB:addAni('musicOff','menuButtons',{28},{1e6})
	AnimationDB:addAni('soundOptionsOn','menuButtons',{32,33,34,35},{0.15, 0.15, 0.15, 0.5})
	AnimationDB:addAni('soundOptionsOff','menuButtons',{35},{1e6})	
		
	--AnimationDB:addAni('sliderSegmentOnEnd','menuButtons',{24},{1e6})

	--AnimationDB:addAni('keyAssignmentOn','keyAssignment',{1},{1e6},
	--	vectorAnimations.userlevelsAniUpdate )
	--AnimationDB:addAni('keyAssignmentOff','keyAssignment',{2},{1e6})
	--AnimationDB:addAni('soundOptionsOn','soundButton',{1,2,3,4},
	--	{0.15, 0.15, 0.15, 0.5}, vectorAnimations.soundAniUpdate )
	--AnimationDB:addAni('soundOptionsOff','soundButton',{5},{1e6})
	AnimationDB:addAni('graphicsOptionsOn','graphicsButton',{1,2,3,4,5},
		{0.5, 0.25, 0.25, 0.25, 1.25}, vectorAnimations.graphicsAniUpdate )
	AnimationDB:addAni('graphicsOptionsOff','graphicsButton',{1},{1e6})
	AnimationDB:addAni('fullscreenOn','fullscreenButton',{2,3,4,5,6,7,6,5,4,3,2},
		{.15, .15, .15, .15, .15, .5, .15, .15, .15, .15, .5} )
	AnimationDB:addAni('fullscreenOff','fullscreenButton',{1},{1e6})
	AnimationDB:addAni('toFullscreenOff','fullscreenButton',{1},{1e6} )
	AnimationDB:addAni('toFullscreenOn','fullscreenButton',{2,3,4,5,6},{.1,.1,.1,.1,.6},
		vectorAnimations.fullscreenAniUpdate )
	AnimationDB:addAni('toWindowedOff','fullscreenButton',{7},{1e6} )
	AnimationDB:addAni('toWindowedOn','fullscreenButton',{8,9,10,11,12},{.1,.1,.1,.1,.6},
		vectorAnimations.fullscreenAniUpdate )
	AnimationDB:addAni('shadersOff','shadersButton',{1},{1e6} )
	AnimationDB:addAni('shadersOn','shadersButton',{2},{1e6}, vectorAnimations.userlevelsAniUpdate )
	AnimationDB:addAni('noShadersOff','shadersButton',{3},{1e6} )
	AnimationDB:addAni('noShadersOn','shadersButton',{4},{1e6}, vectorAnimations.userlevelsAniUpdate )

	-- keyboard and gamepad keys for in-level display: (tutorial)
	AnimationDB:addAni('keyboardSmall','keyOff',{1},{1e6})
	AnimationDB:addAni('keyboardLarge','keyLargeOff',{1},{1e6})
	AnimationDB:addAni('gamepadA','gamepadA',{1},{1e6})
	AnimationDB:addAni('gamepadB','gamepadB',{1},{1e6})
	AnimationDB:addAni('gamepadBack','gamepadBack',{1},{1e6})
	AnimationDB:addAni('gamepadDown','gamepadDown',{1},{1e6})
	AnimationDB:addAni('gamepadLB','gamepadLB',{1},{1e6})
	AnimationDB:addAni('gamepadLeft','gamepadLeft',{1},{1e6})
	AnimationDB:addAni('gamepadRB','gamepadRB',{1},{1e6})
	AnimationDB:addAni('gamepadRight','gamepadRight',{1},{1e6})
	AnimationDB:addAni('gamepadStart','gamepadStart',{1},{1e6})
	AnimationDB:addAni('gamepadUp','gamepadUp',{1},{1e6})
	AnimationDB:addAni('gamepadY','gamepadY',{1},{1e6})
	AnimationDB:addAni('gamepadX','gamepadX',{1},{1e6})
	AnimationDB:addAni('keyNone','keyNone',{1},{1e6})

	AnimationDB:addAni('stars0','stars',{1},{1e6})
	AnimationDB:addAni('stars1','stars',{2},{1e6})
	AnimationDB:addAni('stars2','stars',{3},{1e6})
	AnimationDB:addAni('stars3','stars',{4},{1e6})
	AnimationDB:addAni('stars4','stars',{5},{1e6})
	AnimationDB:addAni('stars5','stars',{6},{1e6})
	AnimationDB:addAni('skulls0','skulls',{1},{1e6})
	AnimationDB:addAni('skulls1','skulls',{2},{1e6})
	AnimationDB:addAni('skulls2','skulls',{3},{1e6})
	AnimationDB:addAni('skulls3','skulls',{4},{1e6})
	AnimationDB:addAni('skulls4','skulls',{5},{1e6})
	AnimationDB:addAni('skulls5','skulls',{6},{1e6})
	AnimationDB:addAni('userlevelDownload','userlevelStates',{1},{1e6})
	AnimationDB:addAni('userlevelPlay','userlevelStates',{2},{1e6})
	AnimationDB:addAni('userlevelBusy','userlevelStates',{3},{1e6})
	AnimationDB:addAni('userlevelError','userlevelStates',{4},{1e6})
	AnimationDB:addAni('authorizationFalse','authorizationState', {1}, {1e6} )
	AnimationDB:addAni('authorizationTrue','authorizationState', {2}, {1e6} )
	
	-- level end statistics:
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

	AnimationDB:addAni('statIdle', 'statIdle', {1},{1e6})	
	AnimationDB:addAni('statNoDeath1', 'statNoDeath1', {1},{1e6})
	AnimationDB:addAni('statNoDeath2', 'statNoDeath2', {1,2,1,2},{10,0.2,0.3,0.2})
	AnimationDB:addAni('statHighestJump', 'statHighestJump', {1,2,3,4,5,6,7,8},{1.5,.05,.05,.05,.05,.05,.05,1e6})
	AnimationDB:addAni('statLongestJump', 'statLongestJump', {1},{1e6})
	AnimationDB:addAni('statTimeInAir', 'statTimeInAir', {1,2,3,4,3,2,1,5,6,7,6,5},
			{.1,.08,.05,.08,.05,.08,.1,.08,.05,.08,.05,.08})
	AnimationDB:addAni('statNumberOfJumps', 'statNumberOfJumps', {1,2,3,4,5,6,7},{.1,.05,.05,.05,.05,.05,.05})
	AnimationDB:addAni('statWallHang', 'statWallHang', {1},{1e6})
	AnimationDB:addAni('statVelocity','statVelocity',{1,2,3,4},{.06,.03,.06,.03})
	AnimationDB:addAni('statTime','statTime',{1,2,3,4},{.08,.08,.08,.08} )
	AnimationDB:addAni('statNumberOfButtons','statNumberOfButtons',
	{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,16,18,19,18,19,20,21,22,21,22,21,22,21,22,21,22,23,24,25,26,27,28,29,30,31},
	{1.5,.3,.03,.04,.06,.04,.03,.1,.9,.08,.05,.05,.08,.05,.2,1,.2,.5,.1,.1,.1,.1,.05,.2,.1,.3,.1,.2,.2,.1,.2,.1,.1,1,.03,.03,.03,.03,.9,.01,.9,1e6})
end

function AnimationDB:addAllSilhouettes()
	--local img,sw,sh = self:loadImage('silhouettes.png','silhouettes','silhouettes')
	--local img,sw,sh = self:loadImage('mountain.png','silhouettes','silhouettes')
	local img,sw,sh = self:loadImage('village.png','silhouette1','silhouettes')
	
	self:loadImage('forest.png','silhouette2','silhouettes')
	self:loadImage('mountain.png','silhouette3','silhouettes')
	self:loadImage('desert.png','silhouette4','silhouettes')
	self:loadImage('sky.png','silhouette5','silhouettes')
	self:loadImage('mountain.png','silhouetteback','silhouettes')
	
	self:addSilhouette(0,0,8,4,sw,sh)
	self:addSilhouette(8,0,8,4,sw,sh)
	self:addSilhouette(0,4,8,4,sw,sh)
	self:addSilhouette(8,4,8,4,sw,sh)
	self:addSilhouette(0,8,8,4,sw,sh)
	self:addSilhouette(8,8,8,4,sw,sh)
	self:addSilhouette(0,12,8,4,sw,sh)
	self:addSilhouette(8,12,8,4,sw,sh)
	

end


function vectorAnimations.startAniUpdate( anim )
	anim.ox = 6 - 1.5*math.abs(math.sin(5*anim.vectorTimer))
	anim.sy = 1-0.1*math.abs(math.cos(5*anim.vectorTimer))
	anim.sx = 1/anim.sy
end

function vectorAnimations.settingsAniRestart( anim )
	anim.angle = anim.vectorTimer * 5
end

function vectorAnimations.defaultAniUpdate( anim )
	anim.angle = 0+0.1 * math.sin(7*anim.vectorTimer)
end

function vectorAnimations.pulseAniUpdate( anim )
	anim.sx = 1 + 0.3*math.max(0,1-5*anim.vectorTimer)
	anim.sy = anim.sx
	--anim.sx = 1 + 0.1 * math.sin(7*anim.vectorTimer)
	--anim.sy = anim.sx
end

function vectorAnimations.resetAniUpdate( anim )
	anim.sx = 1
	anim.sy = 1
	anim.angle = 0
	anim.vectorTimer = 0
end

function vectorAnimations.creditsAniUpdate( anim )
	anim.sx = 1+0.15*math.abs(math.sin(6*anim.vectorTimer))
	anim.sy = anim.sx
	anim.angle = 0.2*math.sin(- anim.vectorTimer * 6)
	anim.oy = 4 + 1-1*math.abs(math.sin(6*anim.vectorTimer))
end
function vectorAnimations.exitAniUpdate( anim )
	anim.oy = 4+1-2*math.abs(math.sin(5*anim.vectorTimer))
	anim.sy = 1-0.05*math.abs(math.cos(5*anim.vectorTimer))
	anim.sx = 1/anim.sy
end
function vectorAnimations.editorAniUpdate( anim )
	anim.angle = 0+0.1 * math.sin(7*anim.vectorTimer)
	--anim.oy = 4 -1*math.abs(math.sin(5*anim.vectorTimer))
	--anim.sx = 1-0.05*math.abs(math.cos(5*anim.vectorTimer))
	--anim.sy = 1/anim.sx
end
function vectorAnimations.userlevelsAniUpdate( anim )
	anim.yShift = -0.4*math.sin(5*anim.vectorTimer)
	anim.xShift = -anim.yShift
	anim.sx = 1+0.1*math.abs(math.cos(5*anim.vectorTimer))
	anim.sy = anim.sx
end
function vectorAnimations.keyboardAniUpdate( anim )
	anim.sx = 1-0.1*math.abs(math.cos(5*anim.vectorTimer))
	anim.sy = 1-0.05*math.abs(math.cos(5*anim.vectorTimer))
end
function vectorAnimations.gamepadAniUpdate( anim )
	anim.sx = 1-0.1*math.abs(math.cos(5*anim.vectorTimer))
	anim.sy = 1-0.05*math.abs(math.cos(5*anim.vectorTimer))
end
function vectorAnimations.restartAniUpdate( anim )
	anim.angle = anim.angle - math.pow(math.sin(anim.vectorTimer), 2)/5
end
function vectorAnimations.soundAniUpdate( anim )
	anim.angle = math.cos( 3*anim.vectorTimer )/3
end
function vectorAnimations.graphicsAniUpdate( anim )
	local t = anim.vectorTimer - 2.5*math.floor(anim.vectorTimer / 2.5)
	if t < 2 then
		anim.sx = 1 + 0.1*t
		anim.sy = anim.sx
	end
end
function vectorAnimations.fullscreenAniUpdate( anim )
	anim.yShift = -0.4*math.cos(math.pi*anim.vectorTimer)
	anim.xShift = -anim.yShift
	anim.sx = 1+0.1*math.abs(math.sin(math.pi*anim.vectorTimer))
	anim.sy = anim.sx
end
