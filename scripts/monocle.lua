
local index = require 'scripts/index'
local tuple = require 'scripts/tuple'

local _lg = love.graphics

local Monocle = {
	edges = index(),
	canvas = nil,
	lights = {}
}

function Monocle:init( useCanvas, r, g, b, a )
	self.useCanvas = useCanvas
	self.blur = false
	
	self.shadow = {
		r=r or 0,
		g=g or 0,
		b=b or 0,
		a=a or 255,
	}
end

function Monocle:setGrid( grid, tileSize )
	if not tonumber(tileSize) then
		error("Wrong usage of Monocle:setGrid, second argument needs to give tileSize!")
	end
	self.grid = grid
	self.tileSize = tileSize
	if self.useCanvas then
		local x, y = tileSize*#grid[1], tileSize*#grid
		print( tileSize*#grid[1], tileSize*#grid, #grid[1], #grid )
		self.canvas = _lg.newCanvas( x, y )
	end
end

function Monocle:setBlur( blurAmount )
	print("Added blur!")
	if not blurAmount or blurAmount == 0 then
		self.blur = false
	elseif self.useCanvas then	-- only allow blurring when canvas is enabled, too:
		self.blur = true
		self.blurAmount = tonumber(blurAmount)
	end
	
	if self.blur then
		--self.blurAmount = 0
		self.gaussianV = _lg.newPixelEffect(love.filesystem.read("scripts/shaders/gaussianV.glsl"))
		self.gaussianH = _lg.newPixelEffect(love.filesystem.read("scripts/shaders/gaussianH.glsl"))
		self.gaussianV:send("amount", self.blurAmount)
		self.gaussianV:send("screenSize", self.canvas:getWidth())
		self.gaussianH:send("amount", self.blurAmount)
		self.gaussianH:send("screenSize", self.canvas:getWidth())
		
		self.gaussCanvas = _lg.newCanvas(self.canvas:getWidth(), self.canvas:getHeight())
	end
end

function Monocle:addLight( x, y, r, g, b, a )
	local light = {
		x=x or 1,
		y=y or 1,
		r=r or 255,
		g=g or 255,
		b=b or 255,
		a=a or 255,
	}
	print("New light @:", light.x, light.y)
	self.lights[#self.lights+1] = light
	return light
end

function Monocle:removeLight( light )	-- find light in list and remove:
	for k = 1, #self.lights do
		if self.lights[k] == light then
			-- move all other lights in the list up one:
			for i = k, #self.lights-1 do
				self.lights[i] = self.lights[i+1]
			end
			self.lights[#self.lights] = nil	-- remove last
			break
		end
	end
end

function Monocle:reset()
	self.lights = {}
end

local prevMode, prevEffect

function Monocle:update( debug )
	if self.useCanvas then
		self.canvas:clear(self.shadow.r, self.shadow.g,self.shadow.b,self.shadow.a)
		--_lg.setCanvas(self.canvas)
		--_lg.setColor(self.shadow.r, self.shadow.g, self.shadow.b, self.shadow.a)
		-- _lg.rectangle('fill', 0, 0, _lg.getWidth(), _lg.getHeight())
		_lg.setCanvas()
	--[[if self.useCanvas then
		_lg.setCanvas(self.canvas)	
		_lg.setColor(0,0,0)
		_lg.rectangle('fill', 0, 0, _lg.getWidth(), _lg.getHeight())
		_lg.setCanvas()
	end]]--
	end
	
	for k = 1, #self.lights do
	
		--light.x = self.lights[k].x
		--light.y = self.lights[k].y

		if self.round(self.lights[k].x,5) == self.round(self.lights[k].x) then
			self.lights[k].x = self.lights[k].x + 0.00001
		end
		if self.round(self.lights[k].y,5) == self.round(self.lights[k].y) then
			self.lights[k].y = self.lights[k].y + 0.000015
		end
		if self.lights[k].x - self.round(self.lights[k].x) ==
				self.lights[k]. y - self.round(self.lights[k].y) then
			self.lights[k].x = self.lights[k].x + 0.000012
		end

		self.debug = debug or false
		--self.draw_mode = draw_mode or true
		self.lights[k].edges = index()
		self:get_forward_edges( self.lights[k] )
		self:link_edges( self.lights[k] )
		self:add_projections( self.lights[k] )
		
		if self.useCanvas then
			-- fill the canvas:
			self:draw_triangles( self.lights[k] )
		end
	end
	
	if self.useCanvas then
		if self.blur then
			
			-- store any effects the user has set up before:
			prevMode = _lg.getBlendMode()
			prevEffect = love.graphics.getPixelEffect()
			
			self.gaussCanvas:clear()
			_lg.setCanvas(self.gaussCanvas)
		
			_lg.setPixelEffect( self.gaussianH )
			_lg.setColor(255,255,255,255)
			
			_lg.setBlendMode('premultiplied')
			
			_lg.draw(self.canvas)
			_lg.setPixelEffect()
			self.canvas:clear()
	
			_lg.setCanvas(self.canvas)
			_lg.setPixelEffect( self.gaussianV )
			_lg.setColor(255,255,255,255)
			_lg.draw(self.gaussCanvas)
			_lg.setPixelEffect()
			_lg.setCanvas()

			-- restore any other shaders the user used before:
			_lg.setBlendMode( prevMode )
			_lg.setPixelEffect( prevEffect )
		end
	end
end


function Monocle:draw()
	love.graphics.setColor(255, 255, 255, 255)
	if self.debug then
		self:draw_debug( self.lights[1] )
	else
		-- If a canvas has already been calculated, then use this.
		-- Otherwise, draw triangles:
		if self.useCanvas then
			prevMode = _lg.getBlendMode()
			-- _lg.setBlendMode('premultiplied')
			_lg.setBlendMode('additive')
			_lg.draw( self.canvas )
			_lg.setBlendMode(prevMode)
		else
			for k = 1, #self.lights do
				self:draw_triangles( self.lights[k] )
			end
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function Monocle:get_forward_edges( light )
	for i, row in ipairs(self.grid) do
		for j, point in ipairs(row) do
			if point.solid then
				if light.x<j and self.grid[i][j-1] and not self.grid[i][j-1].solid then
					self:add_edge(light, j,i,j,i+1) --left
				elseif light.x > j + 1 and self.grid[i][j+1] and not self.grid[i][j+1].solid then
					self:add_edge(light, j+1,i+1,j+1,i) --right
				end

				if light.y < i and self.grid[i-1] and not self.grid[i-1][j].solid then 
					self:add_edge(light, j+1,i,j,i) -- top
				elseif light.y > i + 1 and self.grid[i+1] and not self.grid[i+1][j].solid then
					self:add_edge(light, j,i+1,j+1,i+1) --bottom
				end
			end
		end
	end
end

function Monocle:link_edges( light )
	for e in light.edges:values() do
		local x1,y1,x2,y2 = unpack(e[1])
		next_candidate = tuple(x2,y2,x2,y2-1)
		if x2 < light.x and light.edges[next_candidate] then
			e[2] = next_candidate
			light.edges[next_candidate][3] = e[1]
		end
		next_candidate = tuple(x2,y2,x2,y2+1)
		if x2 >= light.x and light.edges[next_candidate] then
			e[2] = next_candidate
			light.edges[next_candidate][3] = e[1]
		end
		next_candidate = tuple(x2,y2,x2+1,y2)
		if y2 < light.y and light.edges[next_candidate] then
			e[2] = next_candidate
			light.edges[next_candidate][3] = e[1]
		end
		next_candidate = tuple(x2,y2,x2-1,y2)
		if y2 >= light.y and light.edges[next_candidate] then
			e[2] = next_candidate
			light.edges[next_candidate][3] = e[1]
		end
	end
end

function Monocle:add_projections( light )
	local edges_to_add = {}
	for e in light.edges:values() do
		local x1,y1,x2,y2 = unpack(e[1])
		if not e.projection and not e.split then
			--add Next
			if not e[2] then
				table.insert(edges_to_add, {e,x2,y2, true,
								['distance'] = self.dist_points(light.x,light.y,x2,y2)})
			end
			--add Previous
			if not e[3] then
				table.insert(edges_to_add, {e, x1,y1, false, 
								['distance'] = self.dist_points(light.x,light.y,x1,y1)})
			end
		end
	end

	table.sort( edges_to_add, function(a,b) return a['distance'] < b['distance'] end)

	for _, e in ipairs(edges_to_add) do
		if light.edges[e[1][1]] then
			self:add_projection_edge( light, unpack(e))
		end
	end

end

function Monocle:add_projection_edge( light, e, x1,y1, isNext)
	local borderX, borderY = self:get_border_intersection( light, x1,y1)
	local dist2 = false
	local closest_intersectionX, closest_intersectionY = false, false
	local found_edge = false
	for search_edge in light.edges:values() do
		local sx1,sy1,sx2,sy2 = unpack(search_edge[1])
		if search_edge[1] ~= e[1] and not search_edge.projection then
			local intersectX, intersectY = self:findIntersect(x1,y1,borderX,borderY,sx1,sy1,sx2,sy2,true,true)
			if intersectX and not (intersectX == sx2 and intersectY == sy2 )then
				local new_dist2 = (intersectX - x1)^2 + (intersectY - y1)^2
				if not dist2 or new_dist2 < dist2 then
					dist2 = new_dist2
					closest_intersectionX, closest_intersectionY = intersectX, intersectY
					found_edge = search_edge
				end
			end
		end
	end
	if not found_edge or light.edges[found_edge[1]].back then
		return false
	else 
		local sx1,sy1,sx2,sy2 = unpack(found_edge[1])

		if isNext then

			if not found_edge[2] then
				self:add_projection_edge( light, found_edge,sx2,sy2,true)
			end

			proj_edge = tuple(x1,y1,closest_intersectionX,closest_intersectionY)
			self:add_edge(light, x1,y1,closest_intersectionX,closest_intersectionY, true)

			if self.round(closest_intersectionX,5) == self.round(sx1,5) and self.round(closest_intersectionY,5) == self.round(sy1,5) then

				light.edges[proj_edge][2] = found_edge[1]
				light.edges[proj_edge][3] = e[1]

				found_edge[3] = proj_edge

			else

				new_edge = tuple(closest_intersectionX,closest_intersectionY,sx2,sy2)
				self:add_edge(light, closest_intersectionX,closest_intersectionY,sx2,sy2, false, true)

				new_edge2 = tuple(sx1,sy1,closest_intersectionX,closest_intersectionY)
				self:add_edge(light, sx1,sy1,closest_intersectionX,closest_intersectionY, false, true, true)

				light.edges[proj_edge][2] = new_edge
				light.edges[proj_edge][3] = e[1]

				light.edges[new_edge][3] = proj_edge
				light.edges[new_edge][2] = found_edge[2]

				light.edges[new_edge2][3] = false
				light.edges[new_edge2][2] = false

				light.edges[found_edge[1]] = nil

				for search_edge in light.edges:values() do
					if search_edge[3] == found_edge[1] then
						search_edge[3] = new_edge2
					end
					if search_edge[2] == found_edge[1] then
						search_edge[2] = new_edge
					end
				end
			end 
			e[2] = proj_edge

		else

			if not found_edge[3] then
				self:add_projection_edge( light, found_edge,sx1,sy1,false)
			end

			proj_edge = tuple(closest_intersectionX,closest_intersectionY,x1,y1)
			self:add_edge(light, closest_intersectionX,closest_intersectionY,x1,y1, true)

			if self.round(closest_intersectionX,5) == self.round(sx1,5) and self.round(closest_intersectionY,5) == self.round(sy1,5) then

				light.edges[proj_edge][2] = e[1]
				light.edges[proj_edge][3] = found_edge[1]

				found_edge[2] = proj_edge

			else

				new_edge = tuple(sx1,sy1,closest_intersectionX,closest_intersectionY)
				self:add_edge(light, sx1,sy1,closest_intersectionX,closest_intersectionY, false, true)

				new_edge2 = tuple(closest_intersectionX,closest_intersectionY,sx2,sy2)
				self:add_edge(light, closest_intersectionX,closest_intersectionY,sx2,sy2, false, true,true)

				light.edges[proj_edge][3] = new_edge
				light.edges[proj_edge][2] = e[1]

				light.edges[new_edge][3] = found_edge[3]
				light.edges[new_edge][2] = proj_edge

				if found_edge[3] then
					light.edges[found_edge[3]][2] = new_edge
				end
				light.edges[new_edge2][3] = false
				light.edges[new_edge2][2] = false

				light.edges[found_edge[1]] = nil

				for search_edge in light.edges:values() do
					if search_edge[3] == found_edge[1] then
						search_edge[3] = new_edge2
					end
					if search_edge[2] == found_edge[1] then
						search_edge[2] = new_edge
					end 
				end

			end

			e[3] = proj_edge

		end
	end

end

function Monocle:draw_triangles( light )
	if self.useCanvas then
		_lg.setCanvas(self.canvas)
	end
	--[[_lg.setColor(0,0,0)
	_lg.rectangle('fill', 0, 0, _lg.getWidth(), _lg.getHeight())
	_lg.setBlendMode('alpha')
	]]--

	--Increase this for large maps
	local TOLERANCE = 500
	local start = self:get_closest_edge( light )
	local current_edge = start[1]
	local count = 0

	_lg.setColor( light.r, light.g, light.b, light.a )
	--_lg.setColor( 0, 255, 0, 255 )
	repeat
		local x1,y1,x2,y2
		if current_edge then
			x1,y1,x2,y2 = unpack(current_edge)
		else
			break
		end
		_lg.triangle('fill', light.x*self.tileSize,light.y*self.tileSize,
						x1*self.tileSize,y1*self.tileSize,x2*self.tileSize,y2*self.tileSize)
		if light.edges[current_edge] then
			current_edge = light.edges[current_edge][2]
		else
			break
		end
		count = count + 1
	until current_edge == start[1] or count > TOLERANCE
	
	if self.useCanvas then
		_lg.setCanvas()
	end
end

function Monocle:get_closest_edge( light )
	local closest = false
	local dist = false
	for e in light.edges:values() do
		local x1,y1,x2,y2 = unpack(e[1])
		new_dist = self.distPointToLine(light.x,light.y,x1,y1,x2,y2)
		if not closest or new_dist<dist then
			dist = new_dist
			closest = e
		end
	end
	return closest
end

function Monocle:draw_vision_edge( light )
	--this is the maximum number of cycles.
	--used to prevent infinite loops.
	local TOLERANCE = 500

	local start = self:get_closest_edge( light )
	local current_edge = start[1]
	local count = 0

	local x1,y1,x2,y2 = unpack(current_edge)
	_lg.setColor(255,255,0)
	_lg.line(light.x*tileSize,light.y*tileSize,x1*tileSize,y1*tileSize)
	_lg.line(light.x*tileSize,light.y*tileSize,x2*tileSize,y2*tileSize)

	_lg.setColor(255,0,0)

	repeat
		local x1,y1,x2,y2
		if current_edge then
			x1,y1,x2,y2 = unpack(current_edge)
		else
			break
		end
		_lg.line(x1*tileSize,y1*tileSize,x2*tileSize,y2*tileSize)
		if light.edges[current_edge] and light.edges[current_edge][2] then
			current_edge = light.edges[current_edge][2]
		else
			break
		end
		count = count + 1
	until current_edge == start[1] or count > TOLERANCE
	_lg.setColor(255,255,255)
end


function Monocle:add_edge( light, x1,y1,x2,y2,is_proj, split, back)
	local back = back
	local split = split or false
	local is_proj = is_proj or false
	local tup = tuple(x1,y1,x2,y2)
	local dist = self.distPointToLine(light.x,light.y,x1,y1,x2,y2)
	light.edges[tup] = {tup, false, false, 
						['projection'] = is_proj, 
						['distance'] = dist,
						['split'] = split,
						['back'] = back}
end

function Monocle:draw_debug( light )
	for e in light.edges:values() do

		local x1,y1,x2,y2 = unpack(e[1])

		_lg.setColor(0,200,50)
		local edge_scaled = {}
		for i, _ in ipairs(e[1]) do
			edge_scaled[i] = e[1][i] * tileSize
		end
		_lg.line(edge_scaled)
		_lg.setColor(0,0,0)
		_lg.circle('fill',x1* tileSize,y1* tileSize,2)
		_lg.circle('fill',x2* tileSize,y2* tileSize,2)

		if e[2] == false then
			_lg.setColor(255,0,0)
			_lg.circle('fill',(x1/3 + 2*x2/3) * tileSize,(y1/3 + 2*y2/3) * tileSize,2)
		end
		if e[3] == false then
			_lg.setColor(255,255,0)
			_lg.circle('fill',(2*x1/3 + x2/3) * tileSize,(2*y1/3 + y2/3) * tileSize,2)
		end
	end
	self:draw_vision_edge( light )
end

function Monocle:get_border_intersection(light, x1,y1)
	grid_height = #self.grid
	grid_width = #self.grid[1]

	if light.x <= x1 then
		local intersectX, intersectY = self:findIntersect(light.x,light.y,x1,y1,grid_width, 0, grid_width, grid_height)
		if intersectX then 
			return intersectX, intersectY
		end
	elseif light.x > x1 then
		local intersectX, intersectY = self:findIntersect(light.x,light.y,x1,y1,0, 0, 0, grid_height)
		if intersectX then 
			return intersectX, intersectY
		end
	end

	if light.y <= y1 then
		local intersectX, intersectY = self:findIntersect(light.x,light.y,x1,y1,0, grid_height, grid_width, grid_height)
		if intersectX then 
			return intersectX, intersectY
		end
	elseif light.y > y1 then
		local intersectX, intersectY = self:findIntersect(light.x,light.y,x1,y1,0, 0, grid_width, 0)
		if intersectX then 
			return intersectX, intersectY
		end
	end
end

-- Checks if two lines intersect (or line segments if seg is true)
-- Lines are given as four numbers (two coordinates)
function Monocle:findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
	-- added tolerance
	local tolerance = 0.00000001
	local round_to = 50
	local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
	local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
	local det = a1*b2 - a2*b1
	if det==0 then return false, "The lines are parallel." end
	local x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
	if seg1 or seg2 then
	    local min,max = math.min, math.max
	    if seg1 and not (min(l1p1x,l1p2x) <= x + tolerance and x <= max(l1p1x,l1p2x) + tolerance and min(l1p1y,l1p2y) <= y + tolerance 
	       and y <= (max(l1p1y,l1p2y)) + tolerance) or
	       seg2 and not (min(l2p1x,l2p2x) <= x + tolerance and x <= max(l2p1x,l2p2x) + tolerance and min(l2p1y,l2p2y) <= y + tolerance 
	          and y <= (max(l2p1y,l2p2y)) + tolerance) then
	        return false, "The lines don't intersect."
	    end
	end
	return x,y
end

function Monocle.distPointToLine(px,py,x1,y1,x2,y2)
  local dx,dy = x2-x1,y2-y1
  local length = math.sqrt(dx*dx+dy*dy)
  dx,dy = dx/length,dy/length
  local posOnLine = dx*(px-x1) + dy*(py-y1)
  if posOnLine < 0 then
    -- first end point is closest
    dx,dy = px-x1,py-y1
    return math.sqrt(dx*dx+dy*dy)
  elseif posOnLine > length then
    -- second end point is closest
    dx,dy = px-x2,py-y2
    return math.sqrt(dx*dx+dy*dy)   
  else
    -- point is closest to some part in the middle of the line
    return math.abs( dy*(px-x1) - dx*(py-y1))
  end
end

function Monocle.dist_points(x1,y1,x2,y2)
	return math.sqrt((y2-y1)^2 + (x2-x1)^2)
end

function Monocle.round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

return Monocle
