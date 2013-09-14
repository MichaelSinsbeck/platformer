

Map = {}

local tileSize = 48		-- fallback

function Map:LoadFromFile(mapFile)
	mapFile = mapFile or 'n1.dat'
	mapFile = 'levels/' .. mapFile

	local o = {}
	setmetatable(o, self)
	self.__index = self	
	-- Define the meaning of the function in the level file	
	function mapSize(width,height)	o.width, o.height= width, height	end
	function loadFG (b) o.tileFG = b end
	function loadBG (b) o.tileBG = b end
	function loadOBJ (b) o.tileOBJ = b end
	function loadCollision (b) o.collisionSrc = b end
	function start (b) o.xStart = b.x o.yStart = b.y end

  -- Load File
	love.filesystem.load(mapFile)()
	
	-- Postprocess
  o.factoryList = Map:FactoryList(o.tileOBJ,o.height,o.width) -- see at the end of this file
  o.lineList = Map:LineList(o.tileOBJ,o.height,o.width)
  
  -- delete all "0" value
  for i = 1,o.width do
    for j = 1,o.height do
      if o.tileFG[i][j] == 0 then o.tileFG[i][j] = nil end
			if o.tileBG[i][j] == 0 then o.tileBG[i][j] = nil end
			if o.tileOBJ[i][j] == 0 then o.tileOBJ[i][j] = nil end
      if o.collisionSrc[i][j] == 0 then o.collisionSrc[i][j] = nil end
    end
  end

	o:loadImage()

	return o	
end

function Map:loadImage()
	self.tileSize = Camera.scale*8
	tileSize = self.tileSize
	self.graphicSize = Camera.scale*10
	--local img = love.graphics.newImage('images/'.. Camera.scale*8 ..self.imageFile)
	local imgFG = love.graphics.newImage('images/tilesets/'.. Camera.scale*8 ..'foreground'.. Campaign.worldNumber ..'.png')	
  imgFG:setFilter('nearest','nearest')	
	local imgBG = love.graphics.newImage('images/tilesets/'.. Camera.scale*8 ..'world'.. Campaign.worldNumber ..'.png')	
  imgBG:setFilter('nearest','nearest')
  self.spriteBatchFG = love.graphics.newSpriteBatch(imgFG, self.width*self.height)
	self.spriteBatchBG = love.graphics.newSpriteBatch(imgBG, self.width*self.height)
  self.offset = (self.tileSize-self.graphicSize)/2
	self:generateQuads(imgFG) -- assuming that both images have the same size
	self:updateSpritebatch()
end

function Map:convertForShadows( h, w )

	local map = {}
	h = math.ceil(h)
	w = math.ceil(w)
	for i = 0,h+1 do
		map[i+1] = {}
		for j = 0,w+1 do
			map[i+1][j+1] = {}
			if (self.collision[j] and self.collision[j][i] == 1)
				or i==0 or i==h+1 or j==0 or j==w+1 then
				map[i+1][j+1].solid = true
			else
				map[i+1][j+1].solid = false
			end 
		end
	end

	return map
end

function Map:initShadows( x, y )
	print(x, y)
	tablePrint(self.collisionSrc)
	tablePrint(self.collision)
  self.shadowMap = self:convertForShadows( self.height+1, self.width+1 )
  tablePrintBooleans(self.shadowMap)		-- debug
  print("tile size:", self.tileSize or tileSize)
  shadows:draw(x+1, y+1, self.shadowMap, self.tileSize or tileSize, false, draw_monocle)
end

function Map:start(p)

	game.deathtimer = 0
  -- reset collision table
	self.collision = utility.copy(self.collisionSrc,true)

	-- empty spriteEngine and add player
  spriteEngine:empty()
  spriteEngine:insert(p)
  if p.originalSemiwidth and p.originalSemiheight then
		p:resize(p.originalSemiwidth, p.originalSemiheight)
	end
  p.x = self.xStart+0.5
  p.y = self.yStart+1-p.semiheight
  p.newX = p.x
  p.newY = p.y
  p.vx = 0
  p.vy = 0
  p.bandana = 'white'
  p.alpha = 255
  p.status = 'stand'
  p:setAnim(1,'whiteStand')
  p:flip(false)
  p:update(0)
  p.dead = nil
  mode = 'intro'
  timer = 0
  Camera:jumpTo(p.x,p.y)
  
  if USE_SHADOWS then
	self:initShadows(p.x, p.y)
  end

  for i = 1,#self.factoryList do
    local constructor = self.factoryList[i].constructor
    local nx = self.factoryList[i].x +0.5
    local ny = self.factoryList[i].y +1 - constructor.semiheight
    if constructor.layout == "top" then
			ny = self.factoryList[i].y + constructor.semiheight
    elseif constructor.layout == "left" then
			nx = self.factoryList[i].x + constructor.semiwidth
			ny = self.factoryList[i].y + 0.5
    elseif constructor.layout == "right" then
			nx = self.factoryList[i].x + 1 - constructor.semiwidth
			ny = self.factoryList[i].y + 0.5
    elseif constructor.layout == "center" then
			ny = self.factoryList[i].y + 0.5
    end
    local newObject = constructor:New({x = nx, y = ny})
    newObject:update(0)
    spriteEngine:insert(newObject)
  end
  for i = 1,#self.lineList do
    local newObject = Line:New({
			x = self.lineList[i].x,
			y = self.lineList[i].y,
			x2 = self.lineList[i].x2,
			y2 = self.lineList[i].y2,
			})
		spriteEngine:insert(newObject)
  end

end

--[[function Map:New(imageFile,tileSize)
  tileSize = tileSize or 32
  local gapSize = 0
  local o ={}
	setmetatable(o, self)
	self.__index = self
  
  local img = love.graphics.newImage(imageFile)
  img:setFilter('linear','linear')
  o.imageFile = imageFile
  o.tileSize = tileSize
  o.spriteBatch = love.graphics.newSpriteBatch(img, (math.floor(camWidth/tileSize)+1) * (math.floor(camHeight/tileSize)+1))
  -- Quads erzeugen für SpriteBatch
  o.quads = {}
  local imageWidth = img:getWidth() 
  local imageHeight = img:getHeight()
  for j = 1,math.floor(imageHeight/(tileSize+gapSize)) do
    for i = 1,math.floor(imageWidth/(tileSize+gapSize)) do
      o.quads[i+(j-1)*math.floor(imageWidth/tileSize)] = 
        love.graphics.newQuad((i-1)*(tileSize+gapSize),(j-1)*(tileSize+gapSize), tileSize, tileSize,
        imageWidth,imageHeight)
    end
  end
  
  o.height = 30
  o.width = 45
  o.tile = {}
  o.collision = {}
  for i = 1,o.width do
    o.tile[i]={}
    o.collision[i] = {}
  end
  for i = 1,o.width do
    o.tile[i][1] = 2
    o.tile[i][o.height] = 1
    o.collision[i][1] = 1
    o.collision[i][o.height] = 1    
  end
  for i = 1,o.height do
    o.tile[1][i] = 2
    o.tile[o.width][i] = 2
    
    o.collision[1][i] = 1
    o.collision[o.width][i] = 1
  end
  
  for i = 3,13 do
      o.collision[i][o.height-1] = 1
      o.tile[i][o.height-1] = 4
    for j = 4,i do
      o.tile[i][o.height-j] = 5
      o.collision[i][o.height-j] =1
    end
  end
  
  o.tile[15][15] = 3
  return o
end --]]

function Map:generateQuads(img)
  self.quads = {}
	self.tileSize = Camera.scale*8
	tileSize = self.tileSize
	self.graphicSize = Camera.scale*10  
  local imageWidth = img:getWidth()
  local imageHeight = img:getHeight()
  for j = 1,math.floor(imageHeight/(self.graphicSize)) do
    for i = 1,math.floor(imageWidth/(self.graphicSize)) do
      self.quads[i+(j-1)*math.floor(imageWidth/self.graphicSize)] = 
        love.graphics.newQuad((i-1)*(self.graphicSize),(j-1)*(self.graphicSize), self.graphicSize, self.graphicSize,
        imageWidth,imageHeight)
    end
  end
end

function Map:updateSpritebatch()
  -- Update Spritebatch
  self.spriteBatchFG:clear()
  self.spriteBatchBG:clear()
  
  for x in pairs(self.tileBG) do
		for y in pairs(self.tileBG[x]) do
			if self.quads[self.tileBG[x][y]] then
				self.spriteBatchBG:addq(self.quads[self.tileBG[x][y] ], x*self.tileSize+self.offset, y*self.tileSize+self.offset)
			end
		end
  end
  
  for x in pairs(self.tileFG) do
		for y in pairs(self.tileFG[x]) do
			if self.quads[self.tileFG[x][y]] then
				self.spriteBatchFG:addq(self.quads[self.tileFG[x][y] ], x*self.tileSize+self.offset, y*self.tileSize+self.offset)
			end
		end
  end  
end

function Map:drawBG()
	-- draw background color
	--love.graphics.setColor(80,150,205) -- blue (world 1)
	love.graphics.setColor(244,238,215)
	love.graphics.rectangle('fill',self.tileSize,self.tileSize,self.tileSize*self.width,self.tileSize*self.height)
	love.graphics.setColor(255,255,255)
end

function Map:drawWalls()
	love.graphics.draw(self.spriteBatchBG,0,0)
end

function Map:drawFG()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.spriteBatchFG,0,0)
end

function Map:collisionTest(x,y,direction,tag)
-- Given the (integer) coordinates of a cell, check if there is a
-- collision entry in this cell and then check if collisionNumber causes
-- a collision


	local collisionNumber
	-- check if entry exists at all
	if self.collision[x] and self.collision[x][y] then
		collisionNumber = self.collision[x][y]
	else
		return false
	end
	
--print ('collisionTest with direction '..direction..' and tag ' .. tag .. ', CollisionNr: '..collisionNumber)	
	
	if tag == 'player' then -- player does not collide with spikes
		if direction == 'down' then -- down collides with 1 and 2
		  if collisionNumber == 1 or collisionNumber == 2 then
				return true
			else
				return false
			end
		else -- other direction collides with 1 only
			if collisionNumber == 1 then
				return true
			else
				return false
			end
		end
	else -- everything else collides with spikes
		if direction == 'down' then -- down collides with 1, 2 and 3
		  if collisionNumber == 1 or collisionNumber == 2 or collisionNumber == 3 then
				return true
			else
				return false
			end
		else -- other directions collides with 1 and 3
		  if collisionNumber == 1 or collisionNumber == 3 then
				return true
			else
				return false
			end			
		end
	end
end

function lineOfSight(x1,y1,x2,y2)
-- Determines if a straight line between two points collides with the map
  local fx1,fy1,fx2,fy2 = math.floor(x1),math.floor(y1),math.floor(x2),math.floor(y2)
  local dx,dy = fx1-fx2,fy1-fy2
  if dy > 0 then sy = -1 else sy = 1 end
  if dx > 0 then sx = -1 else sx = 1 end  
  
  local ok
  ok = function(number)
		if not number then return false end
		if number == 1 or number == 3 then return true end
    if sy == 1 and number == 2 then return true end
  end

  if fx1 == fx2 then
    for yy = fy1,fy2,sy do
      if myMap.collision[fx1] and ok(myMap.collision[fx1][yy]) then
        return false,fx1,yy
      end
		end
    return true
  end

	if fy1 == fy2 then
    for xx = fx1,fx2,sx do
      if myMap.collision[xx] and myMap.collision[xx][fy1] then
        return false,xx,fy1
      end
		end
    return true
  end 

  

  if math.abs(dx) > math.abs(dy) then -- schleife über y
    local m = (x2-x1)/(y2-y1)
    local xx2 = math.floor(m*(fy1+math.max(0, sy))-m*y1+x1)
    for xx = fx1,xx2,sx do
      if myMap.collision[xx] and ok(myMap.collision[xx][fy1]) then
        return false,xx,fy1
      end
    end
    for yy = fy1+sy,fy2-sy,sy do
      local xx1 = math.floor(m*(yy+math.max(0,-sy))-m*y1+x1)
			local xx2 = math.floor(m*(yy+math.max(0, sy))-m*y1+x1)
			for xx = xx1,xx2,sx do
			  if myMap.collision[xx] and ok(myMap.collision[xx][yy]) then
			    return false,xx,yy
				end
      end
    end
    local xx1 = math.floor(m*(fy2+math.max(0, -sy))-m*y1+x1)
    for xx = xx1,fx2,sx do
      if myMap.collision[xx] and ok(myMap.collision[xx][fy2]) then
        return false,xx,fy2
      end
    end
	  return true
  else -- schleife über x
		local m = (y2-y1)/(x2-x1)
    local yy2 = math.floor(m*(fx1+math.max(0, sx))-m*x1+y1)
    if myMap.collision[fx1] then
			for yy = fy1,yy2,sy do
			  if ok(myMap.collision[fx1][yy]) then
			    return false,fx1,yy
			  end
			end
    end
    for xx = fx1+sx,fx2-sx,sx do
      if myMap.collision[xx] then
				local yy1 = math.floor(m*(xx+math.max(0,-sx))-m*x1+y1)
				local yy2 = math.floor(m*(xx+math.max(0, sx))-m*x1+y1)
				for yy = yy1,yy2,sy do
				  if ok(myMap.collision[xx][yy]) then
				    return false,xx,yy
					end
				end
      end
    end
    local yy1 = math.floor(m*(fx2+math.max(0, -sx))-m*x1+y1)
    if myMap.collision[fx2] then
			for yy = yy1,fy2,sy do
				if ok(myMap.collision[fx2][yy]) then
				  return false,fx2,yy
				end
			end
    end
	  return true
	end

end

function Map:LineList(tile,height,width)
	local lineList = {}
	local nodeList = {}
	
	for i=1,width do
    for j = 1,height do
			if tile[i][j] == 8 then
				table.insert(nodeList,{x=i+0.5,y=j+0.5})
			end             
    end
  end
  -- traverse node list and add line for two nodes
  local nLines = math.floor((#nodeList)/2)
  for iLine = 1,nLines do
		table.insert(lineList,{
				x = nodeList[2*iLine-1].x,
				y = nodeList[2*iLine-1].y,
				x2 = nodeList[2*iLine].x,
				y2 = nodeList[2*iLine].y})
  end
	return lineList
end

function Map:FactoryList(tile,height,width)
  
  local factoryList = {} 
  -- find all entities, add objects to spriteEngine and replace by zero
  
  local objectList ={
  [ 2] = Exit,
  [ 3] = Bandana.white,
  [ 4] = Bandana.blue,
  [ 5] = Bandana.red,
  [ 6] = Bandana.green,    
  [ 7] = Bouncer,
  [ 9] = Runner,
  [10] = Goalie, 
  
	[11] = Imitator,
	[12] = Launcher,
  [13] = Cannon,
  [16] = Emitter,
  [17] = Button,
  [18] = Appearblock,
	[19] = Disappearblock,
	[20] = Crumbleblock,
	[21] = Glassblock,
	[22] = Keyhole,
	[23] = Door,
	[24] = Key,
	[25] = Windmill,
	[26] = BouncerLeft,
	[27] = BouncerTop,
	[28] = BouncerRight,
	[29] = Bumper,
	[30] = Clubber,

  [33] = Spikey,

	[37] = FixedCannon1r,
	[38] = FixedCannon2r,
	[39] = FixedCannon3r,
	[40] = FixedCannon4r,
	[45] = FixedCannon1d,
	[46] = FixedCannon2d,
	[47] = FixedCannon3d,
	[48] = FixedCannon4d,
	[53] = FixedCannon1l,
	[54] = FixedCannon2l,
	[55] = FixedCannon3l,
	[56] = FixedCannon4l,
	[61] = FixedCannon1u,
	[62] = FixedCannon2u,
	[63] = FixedCannon3u,
	[64] = FixedCannon4u,
	
	[65] = Light,
	[66] = Torch,
	[67] = Lamp,
}
  
  for i=1,width do
    for j = 1,height do
			if objectList[tile[i][j]] then
				local constr = objectList[tile[i][j]]
					tile[i][j] = 0
			  local newObject = {constructor = constr, x = i, y = j}
			  table.insert(factoryList,newObject)
			end             
    end
  end
return factoryList  
end
