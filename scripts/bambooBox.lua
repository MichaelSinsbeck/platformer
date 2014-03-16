--------------------------------------------------------------------------
-- Bamboo Box class:
--------------------------------------------------------------------------
-- Each box consists of a background, borders and a shadow line for the
-- borders. The background can be moved ("waving in the wind") by calling
-- box:update(dt) each frame.
-- The borders are 8 units thick - so draw anything that should be on the
-- boxes with a mimumum offset of 8x8, otherwise it will overlap with the
-- borders and look weird.

local Box = {}
Box.__index = Box

local IDEAL_RECT_SIZE = 40
local fabric_IMG, bamboo_IMG

local bamboo_quads_hor = {}
local bamboo_quads_vert = {}
local bamboo_quads_left = {}
local bamboo_quads_end_left = {}
local bamboo_quads_end_right = {}
local bamboo_quads_end_top = {}
local bamboo_quads_end_bottom = {}
local bamboo_s_quads_hor = {}
local bamboo_s_quads_vert = {}
local bamboo_s_quads_left = {}
local bamboo_s_quads_end_left = {}
local bamboo_s_quads_end_right = {}
local bamboo_s_quads_end_top = {}
local bamboo_s_quads_end_bottom = {}

-- Call this function every time the resolution changes!
-- Additionally each box has to be recreated after a resolution change
function Box:init()
	local prefix = Camera.scale * 8
	fabric_IMG = love.graphics.newImage("images/menu/"..prefix.."fabric.png")
	fabric_IMG:setWrap( "repeat", "repeat" )

	bamboo_IMG = love.graphics.newImage("images/menu/"..prefix.."bamboo.png")

	-- borders:
	bamboo_quads_hor[1] = love.graphics.newQuad( 0, 0, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_hor[2] = love.graphics.newQuad( prefix*2, 0, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_hor[3] = love.graphics.newQuad( prefix*4, 0, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_hor[4] = love.graphics.newQuad( prefix*6, 0, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )

	bamboo_quads_vert[1] = love.graphics.newQuad( 0, prefix*2, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_vert[2] = love.graphics.newQuad( prefix, prefix*2, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_vert[3] = love.graphics.newQuad( prefix*2, prefix*2, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_vert[4] = love.graphics.newQuad( prefix*3, prefix*2, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )

	-- corners:
	bamboo_quads_end_left[1] = love.graphics.newQuad( 0, prefix, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_end_left[2] = love.graphics.newQuad( prefix*2, prefix, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_end_right[1] = love.graphics.newQuad( prefix*4, prefix, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_end_right[2] = love.graphics.newQuad( prefix*6, prefix, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )

	bamboo_quads_end_top[1] = love.graphics.newQuad( prefix*4, prefix*2, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_end_top[2] = love.graphics.newQuad( prefix*5, prefix*2, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_end_bottom[1] = love.graphics.newQuad( prefix*6, prefix*2, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_quads_end_bottom[2] = love.graphics.newQuad( prefix*7, prefix*2, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )

	-- shadows for borders:
	bamboo_s_quads_hor[1] = love.graphics.newQuad( 0, 0+prefix*4, prefix*2, prefix, bamboo_IMG:getWidth()+prefix*4, bamboo_IMG:getHeight() )
	bamboo_s_quads_hor[2] = love.graphics.newQuad( prefix*2, 0+prefix*4, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_hor[3] = love.graphics.newQuad( prefix*4, 0+prefix*4, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_hor[4] = love.graphics.newQuad( prefix*6, 0+prefix*4, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )

	bamboo_s_quads_vert[1] = love.graphics.newQuad( 0, prefix*2+prefix*4, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_vert[2] = love.graphics.newQuad( prefix, prefix*2+prefix*4, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_vert[3] = love.graphics.newQuad( prefix*2, prefix*2+prefix*4, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_vert[4] = love.graphics.newQuad( prefix*3, prefix*2+prefix*4, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )

	-- shadows for corners:
	bamboo_s_quads_end_left[1] = love.graphics.newQuad( 0, prefix+prefix*4, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_end_left[2] = love.graphics.newQuad( prefix*2, prefix+prefix*4, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_end_right[1] = love.graphics.newQuad( prefix*4, prefix+prefix*4, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_end_right[2] = love.graphics.newQuad( prefix*6, prefix+prefix*4, prefix*2, prefix, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )

	bamboo_s_quads_end_top[1] = love.graphics.newQuad( prefix*4, prefix*2+prefix*4, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_end_top[2] = love.graphics.newQuad( prefix*5, prefix*2+prefix*4, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_end_bottom[1] = love.graphics.newQuad( prefix*6, prefix*2+prefix*4, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )
	bamboo_s_quads_end_bottom[2] = love.graphics.newQuad( prefix*7, prefix*2+prefix*4, prefix, prefix*2, bamboo_IMG:getWidth(), bamboo_IMG:getHeight() )

end

-- Idea: "borders" lets caller choose which borders should be set (left, right, up, down).
-- Not used yet.
function Box:new( borders, width, height )
	b = {}
	setmetatable(b, self)
	b.width = width or 32
	b.height = height or 32

	-- Minimum of two bamboo parts (a 2 tiles) must fit in. So 4*8 = 32:
	b.width = math.max( b.width, 32 )
	b.height = math.max( b.height, 32 )

	-- Only allow multiples of the bamboo tile width.
	-- Scale up if necessary:
	b.width = math.ceil(b.width/16)*16
	b.height = math.ceil(b.height/16)*16

	local pixelHeight = b.height*Camera.scale
	local pixelWidth = b.width*Camera.scale

	-- devide plane into rectangles, which are as close as possible to
	-- IDEAL_RECT_SIZE in size.
	local numX = math.max(math.ceil(pixelWidth/IDEAL_RECT_SIZE), 1)
	local numY = math.max(math.ceil(pixelHeight/IDEAL_RECT_SIZE), 1)
	local rectWidth = pixelWidth/numX
	local rectHeight = pixelHeight/numY
	local relWidth = rectWidth/fabric_IMG:getWidth()
	local relHeight = rectWidth/fabric_IMG:getHeight()

	local randOffsetX = math.random()
	local randOffsetY = math.random()

	local verts = {}

	-- create matrix of vertevies:
	for x = 1, numX do
		verts[x] = {}
		for y = 1, numY do
			verts[x][y] = {}
			verts[x][y].current = {
				(x-1)*rectWidth, (y-1)*rectHeight,
				(x-1)*relWidth + randOffsetX, (y-1)*relHeight + randOffsetY,
			}
			-- save an original version for future manipulation:
			verts[x][y].original = {
				(x-1)*rectWidth, (y-1)*rectHeight,
				(x-1)*relWidth + randOffsetX, (y-1)*relHeight + randOffsetY,
			}
		end
	end
	b.verts = verts
	b.rectWidth = rectWidth
	b.rectHeight = rectHeight

	-- create a linear list of the vertecies as used by a mesh:
	b.vertList = {}
	local i = 1
	local dir = 1	-- go back and forth from left to right
	for y = 1, numY-1 do
		if dir == 1 then
			for x = 1, numX do
				b.vertList[i] = verts[x][y].current
				i = i + 1
				b.vertList[i] = verts[x][y+1].current
				i = i + 1
			end
		else
			for x = numX, 1, -1 do
				b.vertList[i] = verts[x][y].current
				i = i + 1
				b.vertList[i] = verts[x][y+1].current
				i = i + 1
			end
		end
		dir = -dir
	end
	
	b.mesh = love.graphics.newMesh( b.vertList, fabric_IMG, "strip" )

	-- random starting time for animation:
	b.t = math.random(1000)

	-- Add the borders:	
	b.batch = love.graphics.newSpriteBatch( bamboo_IMG )
	--shadow top right:
	b.batch:add( bamboo_s_quads_end_top[ math.random( #bamboo_s_quads_end_top ) ], (b.width-8)*Camera.scale, 0 )
	--shadow bottom right:
	b.batch:add( bamboo_s_quads_end_bottom[ math.random( #bamboo_s_quads_end_bottom ) ], (b.width-8)*Camera.scale, (b.height-16)*Camera.scale )
	-- shadow top left:
	b.batch:add( bamboo_s_quads_end_left[ math.random( #bamboo_s_quads_end_left ) ], 0, 0 )
	-- shadow top right:
	b.batch:add( bamboo_s_quads_end_right[ math.random( #bamboo_s_quads_end_right ) ], (b.width-16)*Camera.scale, 0 )

	local tileSize = 8*Camera.scale
	for x = 16, b.width-32, 16 do
		-- shadow:
		b.batch:add( bamboo_s_quads_hor[ math.random( #bamboo_s_quads_hor ) ], x*Camera.scale, 0 )
		-- bamboo:
		b.batch:add( bamboo_quads_hor[ math.random( #bamboo_quads_hor ) ], x*Camera.scale, 0 )
		b.batch:add( bamboo_quads_hor[ math.random( #bamboo_quads_hor ) ], x*Camera.scale, (b.height - 8)*Camera.scale )
	end
	for y = 16, b.height-32, 16 do
		-- shadow:
		b.batch:add( bamboo_s_quads_vert[ math.random( #bamboo_s_quads_vert ) ], (b.width - 8)*Camera.scale, y*Camera.scale )
		-- bamboo:
		b.batch:add( bamboo_quads_vert[ math.random( #bamboo_quads_vert ) ], 0, y*Camera.scale )
		b.batch:add( bamboo_quads_vert[ math.random( #bamboo_quads_vert ) ], (b.width - 8)*Camera.scale, y*Camera.scale )
	end

	-- add corners:
	b.batch:add( bamboo_quads_end_top[ math.random( #bamboo_quads_end_top ) ], 0, 0 )
	b.batch:add( bamboo_quads_end_top[ math.random( #bamboo_quads_end_top ) ], (b.width-8)*Camera.scale, 0 )
	b.batch:add( bamboo_quads_end_bottom[ math.random( #bamboo_quads_end_bottom ) ], 0, (b.height-16)*Camera.scale )
	b.batch:add( bamboo_quads_end_bottom[ math.random( #bamboo_quads_end_bottom ) ], (b.width-8)*Camera.scale, (b.height-16)*Camera.scale )

	b.batch:add( bamboo_quads_end_left[ math.random( #bamboo_quads_end_left ) ], 0, 0 )
	b.batch:add( bamboo_quads_end_left[ math.random( #bamboo_quads_end_left ) ], 0, (b.height-8)*Camera.scale )
	b.batch:add( bamboo_quads_end_right[ math.random( #bamboo_quads_end_right ) ], (b.width-16)*Camera.scale, 0 )
	b.batch:add( bamboo_quads_end_right[ math.random( #bamboo_quads_end_right ) ], (b.width-16)*Camera.scale, (b.height-8)*Camera.scale )

	return b
end

function Box:update( dt )
	self.t = self.t + dt

	local xMin, yMin, dist		-- stores distance to the nearest border
	local numX, numY = #self.verts or 1, #self.verts[1] or 1
	local distortX, distortY
	for x = 1, numX do
		xMin = math.min( x-1, numX - x )/numX
		for y = 1, numY do
			yMin = math.min( y-1, numY - y )/numY
			dist = math.min( xMin, yMin )
			distortX = 0.5*math.sin( self.t + x ) + 0.5*math.cos( self.t*0.5 + y )
			distortY = 0.5*math.sin( self.t*0.5 + y + x )
			
			-- modify some of the vertice's coordinates:
			self.verts[x][y].current[1] = self.verts[x][y].original[1] + self.rectWidth*dist*distortX
			self.verts[x][y].current[2] = self.verts[x][y].original[2] + self.rectWidth*dist*distortY
		end
	end

	self.mesh:setVertices( self.vertList )
end

function Box:draw( x, y )
	love.graphics.draw( self.mesh, (x+4)*Camera.scale, (y+4)*Camera.scale )
	love.graphics.draw( self.batch, x*Camera.scale, y*Camera.scale )
end

return Box
