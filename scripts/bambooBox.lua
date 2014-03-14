local Box = {}
Box.__index = Box

local IDEAL_RECT_SIZE = 40
local fabric_IMG

-- Call this function every time the resolution changes!
function Box:init()
	local prefix = Camera.scale * 8
	fabric_IMG = love.graphics.newImage("images/menu/"..prefix.."fabric.png")
	fabric_IMG:setWrap( "repeat", "repeat" )
end

function Box:new( borders, width, height )
	b = {}
	setmetatable(b, self)
	b.width = width or 5
	b.height = height or 5

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

	-- random starting time:
	b.t = math.random(1000)

	return b
end

function Box:update( dt )
	self.t = self.t + dt

	local xMin, yMin, dist		-- stores distance to the nearest border
	local numX, numY = #self.verts or 1, #self.verts[1] or 1
	local distort
	for x = 1, numX do
		xMin = math.min( x-1, numX - x )/numX
		for y = 1, numY do
			yMin = math.min( y-1, numY - y )/numY
			dist = math.min( xMin, yMin )
			distort = math.sin( self.t + x ) + 0.75*math.cos( self.t*0.5 + y )
			
			-- modify some of the vertice's coordinates:
			self.verts[x][y].current[1] = self.verts[x][y].original[1] + self.rectWidth*dist*distort
		end
	end

	self.mesh:setVertices( self.vertList )
end

function Box:draw( x, y )
	love.graphics.draw( self.mesh, x*Camera.scale, y*Camera.scale )
end

return Box
