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

	new.shadowVerts = {}
	for k, v in ipairs(new.verts) do
		new.shadowVerts[k] = {}
		for i,p in pairs(v) do
			new.shadowVerts[k][i] = p
		end
	end
	
	local blue = math.random(32) + 128
	new.col = { blue/3, blue/2, blue, 255 }
	new.timer = 0
	--new.mesh = love.graphics.newMesh( new.verts, bannerImg, "strip" )
	new.mesh = love.graphics.newMesh( new.verts, nil, "strip" )
	new.shadow = love.graphics.newMesh( new.shadowVerts, nil, "strip" )

	return new
end

function banner:update( dt )
	self.timer = self.timer + dt
	for k = 1, #self.verts, 2 do
		local dx = self.verts[k][1]
		local amount = (self.width-dx)/self.width
		self.verts[k][2] = amount*math.sin(dx/self.width*5 + self.timer*2)*self.height/10
		self.shadowVerts[k][2] = (self.width - dx)/self.width*math.sin(dx/self.width*5 + self.timer*2)*self.height/15
	end
	for k = 2, #self.verts, 2 do
		local dx = self.verts[k][1]
		local amount = (self.width-dx)/self.width
		self.verts[k][2] = self.height+amount*math.sin(dx/self.width*5 + self.timer*2)*self.height/10
		self.shadowVerts[k][2] = self.height+(self.width - dx)/self.width*math.sin(dx/self.width*5 + self.timer*2)*self.height/15
	end
	self.mesh:setVertices(self.verts)
	self.shadow:setVertices(self.shadowVerts)
end

function banner:draw()

	love.graphics.setColor( 0, 0, 0, 50 )
	love.graphics.draw( self.shadow, self.x, self.y + 20 )
	love.graphics.setColor( 255, 255, 255, 255 )
	--love.graphics.draw( logImg, self.x + self.width - logImg:getWidth() - 20, self.y, 0, self.sx, self.sy )
	love.graphics.setColor( self.col )
	love.graphics.draw( self.mesh, self.x, self.y )
	love.graphics.setColor( 255, 255, 255, 255 )
	--love.graphics.draw( nailsImg, self.x + self.width - logImg:getWidth() - 20, self.y + 20, 0, self.sx, self.sy )
end

return banner
