-- Animation Database

AnimationDB = {
image = {},
source = {},
animation = {},
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
	local height = height or imageHeight
	local width = width or imageWidth

	self.source[name] = {}
	self.source[name].name = name
	--self.source[name].image = image

	self.source[name].height = height
	self.source[name].width = width
	self.source[name].quads = {}
	self.source[name].meshes = {}
  

  local tilesX, tilesY = math.floor(imageWidth/width), math.floor(imageHeight/height)
  for j = 1,tilesY do
    for i = 1,tilesX do
      self.source[name].quads[i+(j-1)*math.floor(imageWidth/width)] = 
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
			--[[
			-- upper:
			for x = 0,1,STEP_SIZE do
				print(x)
				verts[k] = {
					50*x, 0,
					x, 0,
				}
				k = k+1
			end
			-- right:
			for y = 0,1,STEP_SIZE do
				verts[k] = {
					50*1, y*50,
					1, y,
				}
				k = k+1
			end
			-- bottom:
			for x = 1,0,-STEP_SIZE do
				verts[k] = {
					50*x, 1,
					x, 1,
				}
				k = k+1
			end
			-- left:
			for y = 1,0,-STEP_SIZE do
				verts[k] = {
					0, y*50,
					0, y,
				}
				k = k+1
			end]]
      		self.source[name].meshes[i+(j-1)*math.floor(imageWidth/width)] = 
				love.graphics.newMesh( verts, image )
		end
    end
  end
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
	self.animation[name] = {}
	self.animation[name].source = source
	self.animation[name].frames = frames
	self.animation[name].duration = duration

	self.animation[name].updateFunction = updateFunction
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

function AnimationDB:addSilhouette(name,x,y,width,height,sw,sh)

	local tileSize = Camera.scale*8 -- (Different from the other code, there it is *10)
	local quad = love.graphics.newQuad(tileSize*x,tileSize*y+1,tileSize*width,tileSize*height-1,sw,sh)
	
	if not self.silhouette[name] then self.silhouette[name] = {} end
	table.insert(self.silhouette[name],quad)
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
	AnimationDB:loadImage('buttonHighlight.png','highlight','editor')
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
	
	AnimationDB:loadTiledImage('stars.png','stars', tileSize, 2*tileSize, 'menu')
	AnimationDB:loadTiledImage('skulls.png','skulls', tileSize, 2*tileSize, 'menu')
	AnimationDB:loadTiledImage('userlevelState.png','userlevelStates', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('authorizationState.png','authorizationState', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('acceptOff.png','acceptOff', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('acceptOn.png','acceptOn', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('cancelOff.png','cancelOff', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('cancelOn.png','cancelOn', tileSize, tileSize, 'menu')

	AnimationDB:loadTiledImage('menuButtons.png','menuButtons', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('keyLargeOn.png','keyLargeOn', tileSize, tileSize*2, 'menu')
	AnimationDB:loadTiledImage('keyLargeOff.png','keyLargeOff', tileSize, tileSize*2, 'menu')
	AnimationDB:loadTiledImage('keyOn.png','keyOn', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('keyOff.png','keyOff', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('keyAssignment.png','keyAssignment', tileSize, tileSize*3, 'menu')
	AnimationDB:loadTiledImage('soundButton.png','soundButton', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('graphicsButton.png','graphicsButton', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('fullscreenButton.png','fullscreenButton', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('shadersButton.png','shadersButton', tileSize, tileSize, 'menu')
	AnimationDB:loadTiledImage('gamepadA.png','gamepadA',tileSize,tileSize,'menu')
	AnimationDB:loadTiledImage('gamepadB.png','gamepadB',tileSize,tileSize,'menu')
	AnimationDB:loadTiledImage('gamepadX.png','gamepadX',tileSize,tileSize,'menu')
	AnimationDB:loadTiledImage('gamepadY.png','gamepadY',tileSize,tileSize,'menu')
	AnimationDB:loadTiledImage('gamepadUp.png','gamepadUp',tileSize,tileSize,'menu')
	AnimationDB:loadTiledImage('gamepadDown.png','gamepadDown',tileSize,tileSize,'menu')
	AnimationDB:loadTiledImage('gamepadRight.png','gamepadRight',tileSize,tileSize,'menu')
	AnimationDB:loadTiledImage('gamepadLeft.png','gamepadLeft',tileSize,tileSize,'menu')
	AnimationDB:loadTiledImage('gamepadLB.png','gamepadLB',tileSize,tileSize*2,'menu')
	AnimationDB:loadTiledImage('gamepadRB.png','gamepadRB',tileSize,tileSize*2,'menu')
	AnimationDB:loadTiledImage('gamepadStart.png','gamepadStart',tileSize,tileSize,'menu')
	AnimationDB:loadTiledImage('gamepadBack.png','gamepadBack',tileSize,tileSize,'menu')
	AnimationDB:loadTiledImage('keyNone.png','keyNone',tileSize,tileSize,'menu')
	
	-- gui stuff
	AnimationDB:loadTiledImage('bean.png','bean',tileSize,tileSize,'gui')
	AnimationDB:loadTiledImage('guiBandanas.png','guiBandanas',tileSize*2,tileSize*2,'gui')
	
	-- ingame stuff
	AnimationDB:loadTiledImage('player.png','player',tileSize,tileSize)
	AnimationDB:loadTiledImage('player_white.png','whitePlayer',tileSize,tileSize)
	AnimationDB:loadTiledImage('player_blue.png','bluePlayer',tileSize,tileSize)
	AnimationDB:loadTiledImage('player_red.png','redPlayer',tileSize,tileSize)
	AnimationDB:loadTiledImage('player_blank.png','blankPlayer',tileSize,tileSize)
	AnimationDB:loadTiledImage('player_green.png','greenPlayer',tileSize,tileSize)
	AnimationDB:loadTiledImage('player_yellow.png','yellowPlayer',tileSize,tileSize)
	AnimationDB:loadTiledImage('imitator.png','imitator',tileSize,tileSize)
	AnimationDB:loadTiledImage('explosion.png','explosion',tileSize,tileSize)
	AnimationDB:loadTiledImage('bandana.png','bandana',tileSize,tileSize)
	AnimationDB:loadTiledImage('poff.png','poff',tileSize*.6,tileSize*.6)
	AnimationDB:loadTiledImage('smoke.png','smoke',tileSize,tileSize)
	AnimationDB:loadTiledImage('particle.png','particle',0.4*tileSize,0.4*tileSize)
	AnimationDB:loadTiledImage('shuriken.png','shuriken',tileSize,tileSize)
	AnimationDB:loadTiledImage('runner.png','runner',tileSize,tileSize)
	AnimationDB:loadTiledImage('runnermouth.png','runnerMouth')
	AnimationDB:loadTiledImage('bouncer.png','bouncer',tileSize,tileSize)
	AnimationDB:loadTiledImage('button.png','button',tileSize,tileSize)
	AnimationDB:loadTiledImage('waitbar.png','waitbar')
	AnimationDB:loadTiledImage('appearblock.png','appearBlock',tileSize,tileSize)
	AnimationDB:loadTiledImage('winddot.png','winddot',.6*tileSize,.2*tileSize)
	AnimationDB:loadTiledImage('cannon.png','cannon',tileSize,tileSize)
	AnimationDB:loadTiledImage('goalie.png','goalie',tileSize,tileSize)
	AnimationDB:loadTiledImage('launcher.png','launcher',tileSize,tileSize)
	AnimationDB:loadTiledImage('launcherSon.png','launcherSon',tileSize,tileSize)
	AnimationDB:loadTiledImage('missile.png','missile',tileSize,tileSize)
	AnimationDB:loadTiledImage('windmillwing.png','windmillwing')
	AnimationDB:loadTiledImage('windmillpreview.png','windmillpreview')
	AnimationDB:loadTiledImage('crumbleblock.png','crumbleblock',tileSize,tileSize)
	AnimationDB:loadTiledImage('glassblock.png','glassblock',tileSize,tileSize)
	AnimationDB:loadTiledImage('bubble.png','bubble')
	AnimationDB:loadTiledImage('crumble.png','crumble',.4*tileSize,.4*tileSize)	
	AnimationDB:loadTiledImage('fixedcannon.png','fixedcannon')
	AnimationDB:loadTiledImage('butterfly.png','butterfly',.4*tileSize,.4*tileSize)
	AnimationDB:loadTiledImage('meat.png','meat',.4*tileSize,.4*tileSize)	
	AnimationDB:loadTiledImage('droplet.png','droplet',.4*tileSize,.4*tileSize)	
	AnimationDB:loadTiledImage('exit.png','exit',tileSize,tileSize)	
	AnimationDB:loadTiledImage('bungee.png','bungee',0.4*tileSize,0.4*tileSize)	
	AnimationDB:loadTiledImage('door.png','door',tileSize,tileSize)	
	AnimationDB:loadTiledImage('bumper.png','bumper')
	AnimationDB:loadTiledImage('anchor.png','anchor')
	AnimationDB:loadTiledImage('crosshairs.png','crosshairs')
	AnimationDB:loadTiledImage('clubber.png','clubber',tileSize,tileSize)	
	AnimationDB:loadTiledImage('light.png','light',tileSize,tileSize)	
	AnimationDB:loadTiledImage('menuPlayer.png','menuPlayer',tileSize,tileSize, "menu")
	AnimationDB:loadTiledImage('log.png','log')
	AnimationDB:loadTiledImage('walker.png','walker',tileSize,tileSize)
	AnimationDB:loadTiledImage('spawner.png','spawner',tileSize,tileSize)
	AnimationDB:loadTiledImage('rock.png','rock',tileSize,tileSize)	
	AnimationDB:loadTiledImage('woosh.png','woosh')
	AnimationDB:loadTiledImage('medusa.png','medusa')
	AnimationDB:loadTiledImage('upwind.png','upwind')
	AnimationDB:loadTiledImage('medusaSpawner.png','medusaSpawner',tileSize,tileSize)
	AnimationDB:loadTiledImage('rotator.png','rotator',tileSize,tileSize)
	AnimationDB:loadTiledImage('miniFlame.png','miniFlame',0.4*tileSize,0.4*tileSize)
	AnimationDB:loadTiledImage('npc.png','npc')
	AnimationDB:loadTiledImage('speechbubble.png','speechbubble',tileSize,tileSize)
	AnimationDB:loadTiledImage('camera.png','camera',tileSize,tileSize)
	AnimationDB:loadTiledImage('horizon.png','horizon',tileSize,tileSize)
	
	-- for prototyping - remove later
	AnimationDB:loadTiledImage('placeholder.png','placeholder',tileSize,tileSize)
	
	AnimationDB:loadTiledImage('lineHook.png','lineHook',tileSize,tileSize)
	AnimationDB:loadTiledImage('button.png','editorButton',tileSize,tileSize, "editor", true)
	AnimationDB:loadTiledImage('buttonProperties.png','editorButtonProperties',tileSize*0.5,tileSize*0.5, "editor", true )
	AnimationDB:loadTiledImage('buttonPages.png','editorButtonPages',tileSize*0.5,tileSize, "editor", true)
	AnimationDB:loadTiledImage('listCount.png','listCount',tileSize,tileSize)
	AnimationDB:loadTiledImage('deaths.png','deaths',tileSize*2,tileSize*2)
	AnimationDB:loadTiledImage('statIdle.png', 'statIdle', tileSize*2, tileSize*3 )
	AnimationDB:loadTiledImage('statNoDeath1.png', 'statNoDeath1', tileSize*3, tileSize*3)
	AnimationDB:loadTiledImage('statNoDeath2.png', 'statNoDeath2', tileSize*3, tileSize*3)
	AnimationDB:loadTiledImage('statHighestJump.png', 'statHighestJump', tileSize*4, tileSize*2)
	AnimationDB:loadTiledImage('statLongestJump.png', 'statLongestJump', tileSize*2, tileSize*2 )
	AnimationDB:loadTiledImage('statTimeInAir.png', 'statTimeInAir', tileSize*2, tileSize*3 )
	AnimationDB:loadTiledImage('statNumberOfJumps.png', 'statNumberOfJumps', tileSize*2, tileSize*2 )
	AnimationDB:loadTiledImage('statWallHang.png', 'statWallHang', tileSize*2, tileSize*2 )
	AnimationDB:loadTiledImage('statVelocity.png', 'statVelocity', tileSize*2, tileSize*4 )
	AnimationDB:loadTiledImage('statTime.png', 'statTime', tileSize*4, tileSize*2 )
	AnimationDB:loadTiledImage('statNumberOfButtons.png', 'statNumberOfButtons', tileSize*4, tileSize*4)
	-- credits
	AnimationDB:loadImage('creditsDesign.png', 'creditsDesign', 'credits')
	AnimationDB:loadImage('creditsGraphics.png', 'creditsGraphics', 'credits')
	AnimationDB:loadImage('creditsProgramming.png', 'creditsProgramming', 'credits')
	AnimationDB:loadImage('creditsMusic.png', 'creditsMusic', 'credits')
end

function AnimationDB:loadAnimations()
	
	-- for prototyping - remove later	
	AnimationDB:addAni('placeholder08','placeholder',{1},{1e6})
	AnimationDB:addAni('placeholder06','placeholder',{2},{1e6})
	AnimationDB:addAni('placeholder04','placeholder',{3},{1e6})
	AnimationDB:addAni('placeholder02','placeholder',{4},{1e6})

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

	AnimationDB:addAni('imitatorRun','imitator',{3,1,2,1},{.08,.04,.08,.04})
	AnimationDB:addAni('imitatorWalk','imitator',{11,9,10,9},{.08,.04,.08,.04})
	AnimationDB:addAni('imitatorJump','imitator',{5},{1e6})
	AnimationDB:addAni('imitatorFall','imitator',{6,7},{.1,1e6})
	AnimationDB:addAni('imitatorStand','imitator',{9},{1e6})
	AnimationDB:addAni('imitatorSliding','imitator',{4},{1e6})

	AnimationDB:addAni('launcherLoading','launcher',{1,2,3},{.45,.45,1e6})
	AnimationDB:addAni('npc','npc',{1},{1e6})
	AnimationDB:addAni('speechbubbleSector','speechbubble',{1},{1e6})
	AnimationDB:addAni('speechbubbleTimer','speechbubble',{2},{1e6})
	AnimationDB:addAni('speechbubblepointer','speechbubble',{3},{1e6})
	AnimationDB:addAni('cameraRound','camera',{1},{1e6})
	AnimationDB:addAni('cameraRectangle','camera',{2},{1e6})
	AnimationDB:addAni('parallaxConfig','horizon',{1},{1e6})
	

	AnimationDB:addAni('explosionExplode','explosion',{1,2,3,4,5,6,6},{.05,.05,.1,.1,.1,.1,1e6})

	AnimationDB:addAni('starBandana','bandana',{1},{1e6})
	AnimationDB:addAni('whiteBandana','bandana',{2},{1e6})
	AnimationDB:addAni('yellowBandana','bandana',{9},{1e6}) --todo
	AnimationDB:addAni('greenBandana','bandana',{3},{1e6})
	AnimationDB:addAni('blueBandana','bandana',{4},{1e6})
	AnimationDB:addAni('redBandana','bandana',{5},{1e6})
	AnimationDB:addAni('chickenleg','bandana',{6},{1e6})
	AnimationDB:addAni('bean','bandana',{7},{1e6})

	AnimationDB:addAni('poff','poff',{1,2,3,4,5,5},{.05,.075,.15,.15,.1,1e6})
	AnimationDB:addAni('smoke','smoke',{1,2,3,4,5,5},{.1,.1,.15,.15,.1,1e6})
	AnimationDB:addAni('woosh','woosh',{1},{1e6})
	
	AnimationDB:addAni('rotatorBlock','rotator',{1},{1e6})
	AnimationDB:addAni('rotatorCap','rotator',{2},{1e6})
	AnimationDB:addAni('rotatorStick','rotator',{3},{1e6})
	AnimationDB:addAni('miniFlame','miniFlame',{1},{1e6})
	AnimationDB:addAni('vine1','miniFlame',{2},{1e6})
	AnimationDB:addAni('vine2','miniFlame',{3},{1e6})
	AnimationDB:addAni('vine3','miniFlame',{4},{1e6})
	AnimationDB:addAni('vineEnd','miniFlame',{5},{1e6})

	AnimationDB:addAni('particle','particle',{1},{1e6})
	AnimationDB:addAni('rock','rock',{1},{1e6})

	AnimationDB:addAni('shurikenDead','shuriken',{2},{1e6})
	AnimationDB:addAni('shuriken','shuriken',{1},{1e6})

	AnimationDB:addAni('runnerLeft','runner',{6},{1e6})
	AnimationDB:addAni('runnerRight','runner',{5},{1e6})
	AnimationDB:addAni('runnerSleep','runner',{1,2,3},{0.4,0.1,1e6})
	AnimationDB:addAni('runnerWait','runner',{1},{1e6})

	AnimationDB:addAni('runnerMouth','runnerMouth',{1},{1e6})

	AnimationDB:addAni('strongBouncer','bouncer',{2,1},{0.1,1e6})
	AnimationDB:addAni('mediumBouncer','bouncer',{4,3},{0.1,1e6})
	AnimationDB:addAni('weakBouncer','bouncer',{6,5},{0.1,1e6})

	AnimationDB:addAni('button','button',{1},{1e6})
	AnimationDB:addAni('buttonPressed','button',{3},{1e6})
	AnimationDB:addAni('buttonReleased','button',{2},{1e6})
	AnimationDB:addAni('redButton','button',{5},{1e6})
	AnimationDB:addAni('blueButton','button',{6},{1e6})
	AnimationDB:addAni('greenButton','button',{7},{1e6})
	AnimationDB:addAni('yellowButton','button',{8},{1e6})

	AnimationDB:addAni('waitbar','waitbar',{1},{1e6})

	AnimationDB:addAni('redBlockSolid','appearBlock',{1},{1e6})
	AnimationDB:addAni('redBlockPassable','appearBlock',{2},{1e6})
	AnimationDB:addAni('blueBlockSolid','appearBlock',{3},{1e6})
	AnimationDB:addAni('blueBlockPassable','appearBlock',{4},{1e6})
	AnimationDB:addAni('greenBlockSolid','appearBlock',{5},{1e6})
	AnimationDB:addAni('greenBlockPassable','appearBlock',{6},{1e6})
	AnimationDB:addAni('yellowBlockSolid','appearBlock',{7},{1e6})
	AnimationDB:addAni('yellowBlockPassable','appearBlock',{8},{1e6})

	AnimationDB:addAni('wind1','winddot',{1},{1e6})
	AnimationDB:addAni('wind2','winddot',{2},{1e6})
	AnimationDB:addAni('wind3','winddot',{3},{1e6})
	AnimationDB:addAni('upwind','upwind',{1},{1e6})
	

	AnimationDB:addAni('cannon','cannon',{1},{1e6})

	AnimationDB:addAni('goalie','goalie',{1},{1e6})
	AnimationDB:addAni('medusa','medusa',{1},{1e6})
	AnimationDB:addAni('medusaSpawner','medusaSpawner',{1},{1e6})
	AnimationDB:addAni('medusaVortex','medusaSpawner',{2},{1e6})

	AnimationDB:addAni('launcher','launcher',{1},{1e6})
	AnimationDB:addAni('launcherSon','launcherSon',{1},{1e6})

	AnimationDB:addAni('missile','missile',{1},{1e6})

	AnimationDB:addAni('windmillwing','windmillwing',{1},{1e6})
	AnimationDB:addAni('windmillpreview','windmillpreview',{1},{1e6})	
	
	AnimationDB:addAni('crumbleblock','crumbleblock',{1},{1e6})
	
	AnimationDB:addAni('glassblock','glassblock',{1},{1e6})
	
	AnimationDB:addAni('bubble','bubble',{1},{1e6})
	
	AnimationDB:addAni('crumble1','crumble',{1},{1e6})
	AnimationDB:addAni('crumble2','crumble',{2},{1e6})
	AnimationDB:addAni('crumble3','crumble',{3},{1e6})
	AnimationDB:addAni('crumble4','crumble',{4},{1e6})
	AnimationDB:addAni('crumble5','crumble',{5},{1e6})
	AnimationDB:addAni('crumble6','crumble',{6},{1e6})
	AnimationDB:addAni('crumble7','crumble',{7},{1e6})
	AnimationDB:addAni('crumble8','crumble',{8},{1e6})
	AnimationDB:addAni('crumble9','crumble',{9},{1e6})
	AnimationDB:addAni('crumble10','crumble',{10},{1e6})
	AnimationDB:addAni('crumble11','crumble',{11},{1e6})
	AnimationDB:addAni('crumble12','crumble',{12},{1e6})
	AnimationDB:addAni('glass1','crumble',{12},{1e6})
	AnimationDB:addAni('glass2','crumble',{13},{1e6})
	AnimationDB:addAni('glass3','crumble',{14},{1e6})
	AnimationDB:addAni('glass4','crumble',{15},{1e6})
	AnimationDB:addAni('door1','crumble',{17},{1e6})
	AnimationDB:addAni('door2','crumble',{18},{1e6})
	AnimationDB:addAni('door3','crumble',{19},{1e6})
	AnimationDB:addAni('door4','crumble',{20},{1e6})	
	
	AnimationDB:addAni('fixedcannon','fixedcannon',{1},{1e6})
	
	AnimationDB:addAni('butterflybody','butterfly',{1},{1e6})	
	AnimationDB:addAni('butterflywing1','butterfly',{2},{1e6})
	AnimationDB:addAni('butterflywing2','butterfly',{3},{1e6})
	AnimationDB:addAni('butterflywing3','butterfly',{4},{1e6})
	
	AnimationDB:addAni('meat1','meat',{1},{1e6})
	AnimationDB:addAni('meat2','meat',{2},{1e6})
	AnimationDB:addAni('meat3','meat',{3},{1e6})
	AnimationDB:addAni('meat4','meat',{4},{1e6})
	AnimationDB:addAni('meatWall','meat',{5},{1e6})
	AnimationDB:addAni('meatCorner','meat',{6},{1e6})
	
	AnimationDB:addAni('droplet1','droplet',{1},{1e6})
	AnimationDB:addAni('droplet2','droplet',{2},{1e6})
	AnimationDB:addAni('droplet3','droplet',{3},{1e6})
	AnimationDB:addAni('droplet4','droplet',{4},{1e6})
	AnimationDB:addAni('dropletWall','droplet',{5},{1e6})
	AnimationDB:addAni('dropletCorner','droplet',{6},{1e6})	
	
	AnimationDB:addAni('exit','exit',{1,2,3,4,1,5,6},{.1,.1,.1,.1,.1,.1,.1})
	
	AnimationDB:addAni('bungee','bungee',{1},{1e6})

	AnimationDB:addAni('keyhole','door',{1},{1e6})	
	AnimationDB:addAni('door','door',{2},{1e6})	
	AnimationDB:addAni('key','door',{3},{1e6})			
	
	AnimationDB:addAni('bumper','bumper',{1},{1e6})
	AnimationDB:addAni('anchor','anchor',{1},{1e6})
	AnimationDB:addAni('crosshairs','crosshairs',{1},{1e6})
	
	AnimationDB:addAni('clubber','clubber',{1},{1e6})	
	AnimationDB:addAni('club','clubber',{2},{1e6})
	
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
	AnimationDB:addAni('jumpFallWhite','whitePlayer',{17,5,6,5,17},{.05,.05,.5,.05,.5})
	AnimationDB:addAni('playerScreenshot','menuPlayer',{21,22,23,24,25,21},{0.1,.01,.05,.02,.02,1})
	AnimationDB:addAni('playerFullscreen','menuPlayer',{26,27,28,29,30,31,32,33,34,35},{0.08,.04,.08,0.04,.2,.3,0.04,0.08,.08,.5})

	AnimationDB:addAni('log','log',{1},{1e6})
	
	AnimationDB:addAni('enemyprewalker','walker',{8},{1e6})
	AnimationDB:addAni('enemywalker','walker',{1},{1e6})
	AnimationDB:addAni('enemywalkerfoot','walker',{2},{1e6})
	AnimationDB:addAni('enemywalkerfoot2','walker',{3},{1e6})
	AnimationDB:addAni('bouncyprewalker','walker',{7},{1e6})
	AnimationDB:addAni('bouncywalker1','walker',{4},{1e6})
	AnimationDB:addAni('bouncywalker2','walker',{10},{1e6})
	AnimationDB:addAni('bouncywalkerfoot','walker',{5},{1e6})
	AnimationDB:addAni('bouncywalkerfoot2','walker',{6},{1e6})	
	AnimationDB:addAni('bouncywalkerblink1','walker',{9,4},{0.1,1e6})
	AnimationDB:addAni('bouncywalkerblink2','walker',{11,10},{0.1,1e6})
	--[[AnimationDB:addAni('anchorprewalker','walker',{12},{1e6})
	AnimationDB:addAni('anchorwalker','walker',{15},{1e6})
	AnimationDB:addAni('anchorwalkerfoot','walker',{13},{1e6})
	AnimationDB:addAni('anchorwalkerfoot2','walker',{14},{1e6})--]]
	
	AnimationDB:addAni('spawnerfront','spawner',{1},{1e6})	
	AnimationDB:addAni('spawnerback','spawner',{2},{1e6})
	AnimationDB:addAni('spawnerbar','spawner',{3},{1e6})
	AnimationDB:addAni('spawnersymbolenemy','spawner',{4},{1e6})
	AnimationDB:addAni('spawnersymbolbouncy','spawner',{5},{1e6})
	
	-- gui stuff
	AnimationDB:addAni('guiBeanFull','bean',{1},{1e6})
	AnimationDB:addAni('guiBeanEmpty','bean',{2},{1e6})
	AnimationDB:addAni('guiBandanaWhite','guiBandanas',{1},{1e6})
	AnimationDB:addAni('guiBandanaYellow','guiBandanas',{2},{1e6})
	AnimationDB:addAni('guiBandanaGreen','guiBandanas',{3},{1e6})
	AnimationDB:addAni('guiBandanaBlue','guiBandanas',{4},{1e6})
	AnimationDB:addAni('guiBandanaRed','guiBandanas',{5},{1e6})
	
	-- editor stuff
	AnimationDB:addAni('lineHook'  ,'lineHook',{1},{1e6})
	
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
	AnimationDB:addAni('LEBGround1Off'  ,'editorButton',{67},{1e6})
	AnimationDB:addAni('LEBGround1Hover','editorButton',{68},{1e6})
	AnimationDB:addAni('LEBGround1On'   ,'editorButton',{69},{1e6})	
	AnimationDB:addAni('LEBGround2Off'  ,'editorButton',{70},{1e6})
	AnimationDB:addAni('LEBGround2Hover','editorButton',{71},{1e6})
	AnimationDB:addAni('LEBGround2On'   ,'editorButton',{72},{1e6})	
	AnimationDB:addAni('LEBGround3Off'  ,'editorButton',{73},{1e6})
	AnimationDB:addAni('LEBGround3Hover','editorButton',{74},{1e6})
	AnimationDB:addAni('LEBGround3On'   ,'editorButton',{75},{1e6})
	AnimationDB:addAni('LECloudOff'  ,'editorButton',{85},{1e6})
	AnimationDB:addAni('LECloudOn','editorButton',{86},{1e6})
	AnimationDB:addAni('LECloudHover'   ,'editorButton',{87},{1e6})	

	
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
	AnimationDB:addAni('LEDeleteOff'  ,'editorButton',{43},{1e6})
	AnimationDB:addAni('LEDeleteHover','editorButton',{44},{1e6})
	AnimationDB:addAni('LEDeleteOn'   ,'editorButton',{45},{1e6})
	AnimationDB:addAni('LELayerDownOff'  ,'editorButton',{46},{1e6})
	AnimationDB:addAni('LELayerDownHover','editorButton',{47},{1e6})
	AnimationDB:addAni('LELayerDownOn'   ,'editorButton',{48},{1e6})
	AnimationDB:addAni('LELayerUpOff'  ,'editorButton',{49},{1e6})
	AnimationDB:addAni('LELayerUpHover','editorButton',{50},{1e6})
	AnimationDB:addAni('LELayerUpOn'   ,'editorButton',{51},{1e6})
	AnimationDB:addAni('LEPlayOff'  ,'editorButton',{52},{1e6})
	AnimationDB:addAni('LEPlayHover','editorButton',{53},{1e6})
	AnimationDB:addAni('LEPlayOn'   ,'editorButton',{54},{1e6})
	AnimationDB:addAni('LEObjectOff'  ,'editorButton',{55},{1e6})
	AnimationDB:addAni('LEObjectHover','editorButton',{56},{1e6})
	AnimationDB:addAni('LEObjectOn'   ,'editorButton',{57},{1e6})
	AnimationDB:addAni('LENewOff'  ,'editorButton',{58},{1e6})
	AnimationDB:addAni('LENewHover','editorButton',{59},{1e6})
	AnimationDB:addAni('LENewOn'   ,'editorButton',{60},{1e6})
	AnimationDB:addAni('LEAcceptOff'   ,'editorButton',{61},{1e6})
	AnimationDB:addAni('LEAcceptHover'   ,'editorButton',{62},{1e6})
	AnimationDB:addAni('LEAcceptOn'   ,'editorButton',{63},{1e6})
	AnimationDB:addAni('LEMenuOff'   ,'editorButton',{64},{1e6})
	AnimationDB:addAni('LEMenuHover'   ,'editorButton',{65},{1e6})
	AnimationDB:addAni('LEMenuOn'   ,'editorButton',{66},{1e6})
	AnimationDB:addAni('LEDuplicateOff'   ,'editorButton',{76},{1e6})
	AnimationDB:addAni('LEDuplicateHover'   ,'editorButton',{77},{1e6})
	AnimationDB:addAni('LEDuplicateOn'   ,'editorButton',{78},{1e6})
	AnimationDB:addAni('LEUploadOff'   ,'editorButton',{79},{1e6})
	AnimationDB:addAni('LEUploadHover'   ,'editorButton',{80},{1e6})
	AnimationDB:addAni('LEUploadOn'   ,'editorButton',{81},{1e6})

	AnimationDB:addAni('LEUpOff'   ,'editorButtonProperties',{1},{1e6})
	AnimationDB:addAni('LEUpHover'   ,'editorButtonProperties',{2},{1e6})
	AnimationDB:addAni('LEUpOn'   ,'editorButtonProperties',{3},{1e6})
	AnimationDB:addAni('LEDownOff'   ,'editorButtonProperties',{4},{1e6})
	AnimationDB:addAni('LEDownHover'   ,'editorButtonProperties',{5},{1e6})
	AnimationDB:addAni('LEDownOn'   ,'editorButtonProperties',{6},{1e6})
	AnimationDB:addAni('LELeftOff'   ,'editorButtonPages',{1},{1e6})
	AnimationDB:addAni('LELeftHover'   ,'editorButtonPages',{2},{1e6})
	AnimationDB:addAni('LELeftOn'   ,'editorButtonPages',{3},{1e6})
	AnimationDB:addAni('LERightOff'   ,'editorButtonPages',{4},{1e6})
	AnimationDB:addAni('LERightHover'   ,'editorButtonPages',{5},{1e6})
	AnimationDB:addAni('LERightOn'   ,'editorButtonPages',{6},{1e6})

	AnimationDB:addAni('cancelOn'   ,'cancelOn',{1},{1e6})
	AnimationDB:addAni('acceptOn'   ,'acceptOn',{1},{1e6})

	-- Menu Buttons:
	AnimationDB:addAni('startOn','menuButtons',{1},{1e6}, 
		vectorAnimations.startAniUpdate )
	AnimationDB:addAni('startOff','menuButtons',{2},{1e6} )
	AnimationDB:addAni('exitOn','menuButtons',{3},{1e6},
		vectorAnimations.exitAniUpdate )
	AnimationDB:addAni('exitOff','menuButtons',{4},{1e6})
	AnimationDB:addAni('downloadOn','menuButtons',{5},{1e6}, 
		vectorAnimations.userlevelsAniUpdate )
	AnimationDB:addAni('downloadOff','menuButtons',{6},{1e6})
	AnimationDB:addAni('restartOn','menuButtons',{7},{1e6},
		vectorAnimations.restartAniUpdate )
	AnimationDB:addAni('restartOff','menuButtons',{8},{1e6})
	AnimationDB:addAni('editorOn','menuButtons',{9},{1e6},
		vectorAnimations.editorAniUpdate )
	AnimationDB:addAni('editorOff','menuButtons',{10},{1e6})
	AnimationDB:addAni('acceptOn','menuButtons',{11},{1e6})
	AnimationDB:addAni('acceptOff','menuButtons',{12},{1e6})
	AnimationDB:addAni('settingsOn','menuButtons',{13},{1e6},
		vectorAnimations.settingsAniRestart )
	AnimationDB:addAni('settingsOff','menuButtons',{14},{1e6})
	AnimationDB:addAni('cancelOn','menuButtons',{15},{1e6})
	AnimationDB:addAni('cancelOff','menuButtons',{16},{1e6})
	AnimationDB:addAni('creditsOn','menuButtons',{17},{1e6},
		vectorAnimations.creditsAniUpdate )
	AnimationDB:addAni('creditsOff','menuButtons',{18},{1e6})
	AnimationDB:addAni('worldItemOn','menuButtons',{19},{1e6},
		vectorAnimations.userlevelsAniUpdate )
	AnimationDB:addAni('worldItemOff','menuButtons',{20},{1e6})

	AnimationDB:addAni('sliderSegmentOff','menuButtons',{21},{1e6})
	AnimationDB:addAni('sliderSegmentOn','menuButtons',{22},{1e6})
	AnimationDB:addAni('sliderSegmentOffEnd','menuButtons',{23},{1e6})
	AnimationDB:addAni('sliderSegmentOnEnd','menuButtons',{24},{1e6})

	AnimationDB:addAni('keyAssignmentOn','keyAssignment',{1},{1e6},
		vectorAnimations.userlevelsAniUpdate )
	AnimationDB:addAni('keyAssignmentOff','keyAssignment',{2},{1e6})
	AnimationDB:addAni('soundOptionsOn','soundButton',{1,2,3,4},
		{0.15, 0.15, 0.15, 0.5}, vectorAnimations.soundAniUpdate )
	AnimationDB:addAni('soundOptionsOff','soundButton',{5},{1e6})
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
		
	AnimationDB:addAni('listCount1','listCount',{1},{1e6})
	AnimationDB:addAni('listCount2','listCount',{2},{1e6})
	AnimationDB:addAni('listCount3','listCount',{3},{1e6})
	AnimationDB:addAni('listCount4','listCount',{4},{1e6})
	AnimationDB:addAni('listCount5','listCount',{5},{1e6})
	
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
	local img,sw,sh = self:loadImage('silhouettes.png','silhouettes','silhouettes')
	
	self:addSilhouette('town',0,6,8,1,sw,sh)
	self:addSilhouette('town',0,7,5,5,sw,sh)
	self:addSilhouette('town',0,14,1,2,sw,sh)
	self:addSilhouette('town',0,16,1,1,sw,sh)
	self:addSilhouette('town',1,12,6,5,sw,sh)
	self:addSilhouette('town',7,12,8,5,sw,sh)
	self:addSilhouette('town',5,7,7,5,sw,sh)
	self:addSilhouette('town',12,7,5,4,sw,sh)
	self:addSilhouette('town',17,7,5,4,sw,sh)
	self:addSilhouette('town',12,11,2,1,sw,sh)
	self:addSilhouette('town',15,11,5,6,sw,sh)
	self:addSilhouette('town',20,15,2,2,sw,sh)

	self:addSilhouette('mountain',0,0,7,3,sw,sh)
	self:addSilhouette('mountain',7,0,8,3,sw,sh)
	self:addSilhouette('mountain',15,0,7,3,sw,sh)
	self:addSilhouette('mountain',0,3,6,3,sw,sh)
	self:addSilhouette('mountain',6,3,8,3,sw,sh)
	self:addSilhouette('mountain',14,3,8,4,sw,sh)
	
	self:addSilhouette('sky',0,12,3,1,sw,sh)
	self:addSilhouette('sky',5,12,3,1,sw,sh)
end


function vectorAnimations.startAniUpdate( anim )
	anim.ox = 4 + 1-2*math.abs(math.sin(5*anim.vectorTimer))
	anim.sy = 1-0.1*math.abs(math.cos(5*anim.vectorTimer))
	anim.sx = 1/anim.sy
end

function vectorAnimations.settingsAniRestart( anim )
	anim.angle = anim.vectorTimer * 5
end

function vectorAnimations.creditsAniUpdate( anim )
	--anim.sx = 1-0.1*math.abs(math.cos(6*anim.vectorTimer))
	--anim.sx = 1-2*math.abs(math.sin(6*anim.vectorTimer))
	anim.sx = 1+0.15*math.abs(math.sin(6*anim.vectorTimer))
	anim.sy = anim.sx
	anim.angle = 0.2*math.sin(- anim.vectorTimer * 6)
	anim.oy = 4 + 1-1*math.abs(math.sin(6*anim.vectorTimer))
end
function vectorAnimations.exitAniUpdate( anim )
	anim.oy = 4+1-2*math.abs(math.sin(5*anim.vectorTimer))
	anim.sx = 1-0.05*math.abs(math.cos(5*anim.vectorTimer))
	anim.sy = 1/anim.sx
end
function vectorAnimations.editorAniUpdate( anim )
	anim.oy = 4 -1*math.abs(math.sin(5*anim.vectorTimer))
	anim.sx = 1-0.05*math.abs(math.cos(5*anim.vectorTimer))
	anim.sy = 1/anim.sx
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
