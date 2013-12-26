local banner = {}
banner.__index = banner

local bannerImg = love.graphics.newImage( "banner.png" )
--local logImg = love.graphics.newImage( "log.png" )
--local nailsImg = love.graphics.newImage( "nails.png" )

function banner:new( x, y, width, height )
	local new = {}
	setmetatable( new, banner )

	new.x = x or 0
	new.y = y or 0
	new.width = width or love.graphics.getWidth()
	new.height = height or love.graphics.getHeight()/3
	new.sx = new.width/bannerImg:getWidth()
	new.sy = new.height/bannerImg:getHeight()

	new.verts = {}

	for dx = 0, 1, .1 do
		--top
		new.verts[#new.verts+1] = {
			dx*new.width, 0,	-- position
			dx, 0,		-- texture coords
			255,255,255,		-- colour
		}
		--bottom	
		new.verts[#new.verts+1] = {
			dx*new.width, new.height,	-- position
			dx, 1,		-- texture coords
			255,255,255,		-- colour
		}
	end
	
	local blue = math.random(128) + 128
	new.col = { blue/5, blue/5, blue, 255 }
	new.timer = 0
	new.mesh = love.graphics.newMesh( new.verts, bannerImg, "strip" )

	return new
end

function banner:update( dt )
	self.timer = self.timer + dt
	for k = 1, #self.verts, 2 do
		local dx = self.verts[k][1]
		self.verts[k][2] = (self.width - dx)/self.width*math.sin(dx/self.width*5 + self.timer*5)*self.height/10
	end
	for k = 2, #self.verts, 2 do
		local dx = self.verts[k][1]
		self.verts[k][2] = self.height+(self.width - dx)/self.width*math.sin(dx/self.width*5 + self.timer*5)*self.height/10
	end
	self.mesh:setVertices(self.verts)
end

function banner:draw()

	love.graphics.setColor( 0, 0, 0, 50 )
	love.graphics.draw( self.mesh, self.x, self.y + 20 )
	love.graphics.setColor( 255, 255, 255, 255 )
	--love.graphics.draw( logImg, self.x + self.width - logImg:getWidth() - 20, self.y, 0, self.sx, self.sy )
	love.graphics.setColor( self.col )
	love.graphics.draw( self.mesh, self.x, self.y )
	love.graphics.setColor( 255, 255, 255, 255 )
	--love.graphics.draw( nailsImg, self.x + self.width - logImg:getWidth() - 20, self.y + 20, 0, self.sx, self.sy )
end

return banner
