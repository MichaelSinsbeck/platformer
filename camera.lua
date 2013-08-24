Camera = {
  x = 0,
  y = 0,
  xTarget = 0,
  yTarget = 0,
  xWorld = 0,
  yWorld = 0,
  --width = love.graphics.getWidth(),
	--height = love.graphics.getHeight(),
	scale = 1,
	desiredWidth = 32,
  }

function Camera:update(dt)
  local tileSize = myMap.tileSize
  self.x = self.x + 0.1*(self.xTarget-self.x)
  self.y = self.y + 0.1*(self.yTarget-self.y)
  self.xWorld = math.floor(-Camera.x*myMap.tileSize*self.zoom+self.width/2)/self.zoom
  self.yWorld = math.floor(-Camera.y*myMap.tileSize*self.zoom+self.height/2)/self.zoom
  
  if self.xWorld > -1*tileSize then self.xWorld = -1*tileSize end
  if self.yWorld > -1*tileSize then self.yWorld = -1*tileSize end
  if self.xWorld < self.width/self.zoom - (myMap.width+1)*tileSize then
    self.xWorld = self.width/self.zoom - (myMap.width+1)*tileSize
  end  
  if self.yWorld < self.height/self.zoom - (myMap.height+1)*tileSize then
    self.yWorld = self.height/self.zoom - (myMap.height+1)*tileSize
  end    
end

function Camera:init()
	-- change screen resolution
	local modes = love.graphics.getModes()
	table.sort(modes, function(a, b) return a.width*a.height > b.width*b.height end)
	--love.graphics.setMode(modes[1].width, modes[1].height, true)
	love.graphics.setMode(800, 600, false)

	-- check screen resolution and set Camera scale accordingly.
	-- Camera.scale can have the values 4,5,6,7,8
	self.scale = 4
	local target = 640
	local nTiles = modes[1].width/32 * modes[1].height/32
	for scale = 5,8 do
		local nNewTiles = modes[1].width*modes[1].height/(scale*scale*8*8)
		if math.abs(nNewTiles - 640) < math.abs(nTiles - 640) then
		-- accept new value
			self.scale = scale
			nTiles = nNewTiles
		end
	end
	
	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()
	self.zoom = 1

end

-- sets the new scale and reloads all images
function Camera:setScale(scale)
-- scale has to have one of the values 4,5,6,7 or 8
	self.scale = scale
	menu:init()
	AnimationDB:loadAll()	
	myMap:loadImage()
end

function Camera:setTarget()
  self.xTarget = p.x
  self.yTarget = p.y
end

function Camera:jumpTo(x,y)
  self.x = x
  self.y = y
end

function Camera:apply()
	love.graphics.scale(self.zoom,self.zoom)
  love.graphics.translate(self.xWorld,self.yWorld)
end
