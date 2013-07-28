Map = {}

function Map:LoadFromFile(mapFile)
	mapFile = mapFile or 'level1.lua'

	local o = {}
	setmetatable(o, self)
	self.__index = self	
	-- Define the meaning of the function in the level file	
	function mapSize(width,height,tileSize,graphicSize)	o.width, o.height, o.tileSize, o.graphicSize = width, height, tileSize, graphicSize	end
	function imageFilename(b) o.imageFile = b end
	function loadTiles (b) o.tile = b end
	function loadCollision (b) o.collisionSrc = b end
	function start (b) o.xStart = b.x o.yStart = b.y end

  -- Load File
	love.filesystem.load(mapFile)()
	
	-- Postprocess
	local img = love.graphics.newImage(o.imageFile)
  --img:setFilter('linear','linear')
  img:setFilter('nearest','nearest')
  o.spriteBatch = love.graphics.newSpriteBatch(img, o.width*o.height)
  o.offset = (o.tileSize-o.graphicSize)/2
  o.factoryList = Map:FactoryList(o.tile,o.height,o.width) -- see at the end of this file
  o.lineList = Map:LineList(o.tile,o.height,o.width)
  
  -- delete all "0" value
  for i = 1,o.width do
    for j = 1,o.height do
      if o.tile[i][j] == 0 then o.tile[i][j] = nil end
      if o.tile[i][j] == 65 then o.tile[i][j] = nil end
      if o.collisionSrc[i][j] == 0 then o.collisionSrc[i][j] = nil end
    end
  end
    
  -- Generate Quads for Spritebatch
  o.quads = {}
  local imageWidth = img:getWidth()
  local imageHeight = img:getHeight()
  for j = 1,math.floor(imageHeight/(o.graphicSize)) do
    for i = 1,math.floor(imageWidth/(o.graphicSize)) do
      o.quads[i+(j-1)*math.floor(imageWidth/o.graphicSize)] = 
        love.graphics.newQuad((i-1)*(o.graphicSize),(j-1)*(o.graphicSize), o.graphicSize, o.graphicSize,
        imageWidth,imageHeight)
    end
  end
	o:updateSpritebatch()
	return o	
end

function Map:start(p)

  -- reset collision table
	self.collision = utility.copy(self.collisionSrc,true)

	-- empty spriteEngine and add player
  spriteEngine:empty()
  spriteEngine:insert(p)
  p.x = self.xStart+0.5
  p.y = self.yStart+1-p.semiheight
  p.vx = 0
  p.vy = 0
  p.bandana = 'white'
  p.alpha = 255
  p.status = 'stand'
  p:setAnim('whiteStand')
  p:flip(false)
  p:update(0)
  mode = 'intro'
  timer = 0
  Camera:jumpTo(p.x,p.y)

  for i = 1,#self.factoryList do
    local constructor = self.factoryList[i].constructor
    local nx = self.factoryList[i].x +0.5
    local ny = self.factoryList[i].y +1 - constructor.semiheight
    local newObject = constructor:New({x = nx, y = ny})
    --newObject:updateAnimation(0)
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

function Map:New(imageFile,tileSize)
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
end

function Map:updateSpritebatch()
  -- Update Spritebatch
  self.spriteBatch:clear()
  
  -- Erste Möglichkeit: Schleife über alle nicht-leeren self.tile-Einträge
  for x in pairs(self.tile) do
    if x+1 > Camera.x-Camera.width/2 and x < Camera.x+Camera.width/2 then
      for y in pairs(self.tile[x]) do
        if y+1 > Camera.y-Camera.height/2 and y < Camera.y+Camera.height/2 then
          if self.quads[self.tile[x][y]] then
            self.spriteBatch:addq(self.quads[self.tile[x][y] ], x*self.tileSize+self.offset, y*self.tileSize+self.offset)
          end
        end
      end
    end
  end
  
  -- Zweite Möglichkeit: Schleife über alle x und y, die im Sichtbereich sind.
  --[[for x=math.floor(Camera.x-Camera.width/2),math.floor(Camera.x+Camera.width/2) do
    if self.tile[x] then
      for y = math.floor(Camera.y-Camera.height/2),math.floor(Camera.y+Camera.height/2) do
        if self.tile[x][y] and self.quads[self.tile[x][y] ] then
          self.spriteBatch:addq(self.quads[self.tile[x][y] ], x*self.tileSize, y*self.tileSize)        
        end
      end
    end
  end]]
  
  
end

function Map:draw()
  love.graphics.draw(self.spriteBatch,0,0)
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
			if tile[i][j] == 35 then
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
  [25] = Spikeys[1],
  [26] = Spikeys[2],
  [27] = Spikeys[3],
  [28] = Spikeys[4],
  [31] = Spikeys[5],
  [32] = Spikeys[6],
  [33] = Spikeys[7],
  [34] = Spikeys[8],
  [37] = Spikeys[9],
  [38] = Spikeys[10],
  [39] = Spikeys[11],
  [40] = Spikeys[12],
  [43] = Spikeys[13],
  [44] = Spikeys[14],
  [45] = Spikeys[15],
  [46] = Spikeys[16],
  
  [36] = Windmill,
  [50] = Runner,
  [51] = Goalie,
  [52] = Spikey,
  [53] = Bouncer,
  [54] = Launcher,
  [55] = Cannon,
  [56] = Bandana.white,
  [57] = Bandana.blue,
  [58] = Bandana.red,
  [59] = Bandana.green,
  [61] = Button,
  [62] = Appearblock,
  [63] = Disappearblock,
	[64] = Imitator,
	[66] = Emitter,
  
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
