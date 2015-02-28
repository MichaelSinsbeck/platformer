local Laser = object:New({
	tag = 'Laser',
	category = 'Enemies',
  --firerate = 1.2, -- in seconds
  --velocity = 15,
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  solid = true,
  isFiring = false,
  vis = {
		Visualizer:New('laser'),
		Visualizer:New('laserDot',{active = false}),
	},
	properties = {
		angle = utility.newCycleProperty({0, 1, 2, -1}, {'right', 'down', 'left', 'up'}),
		timeOn = utility.newIntegerProperty(10,0.1,5,0.1),
		timeOff = utility.newIntegerProperty(10,0.1,5,0.1),
		phase = utility.newCycleProperty({0, .1, .2, .3, .4, .5, .6, .7, .8, .9}),

	},
})

function Laser:applyOptions()
	self.vis[1].angle = self.angle*0.5*math.pi
	self.vis[2].angle = self.angle*0.5*math.pi
	
	self.sx = self.x + 0.5*math.cos(self.angle*0.5*math.pi)
	self.sy = self.y + 0.5*math.sin(self.angle*0.5*math.pi)
	
	-- determine endpoints:
	if myMap then
		if self.angle == 0 then
			self.ex = myMap.width+1
			self.ey = self.y
		elseif self.angle == 1 then
			self.ex = self.x
			self.ey = myMap.height+1
		elseif self.angle == 2 then
			self.ex = -1
			self.ey = self.y
		elseif self.angle == -1 then
			self.ex = self.x
			self.ey = -1
		end
	else
		self.ex = self.x
		self.ey = self.y
	end
	self.tx = self.ex
	self.ty = self.ey
end

function Laser:draw()
	if self.isFiring then
		love.graphics.setLineWidth(Camera.scale*0.6)
		love.graphics.setColor(127,0,0)
		love.graphics.line(
			math.floor(self.sx*myMap.tileSize),
			math.floor(self.sy*myMap.tileSize),
			math.floor(self.tx*myMap.tileSize),
			math.floor(self.ty*myMap.tileSize))
			
		love.graphics.setLineWidth(Camera.scale*0.2)
		love.graphics.setColor(255,0,0)
		love.graphics.line(
			math.floor(self.sx*myMap.tileSize),
			math.floor(self.sy*myMap.tileSize),
			math.floor(self.tx*myMap.tileSize),
			math.floor(self.ty*myMap.tileSize))			
			
		love.graphics.setColor(255,255,255)
		
		
	end
	self.vis[2].active = self.isFiring
	self.vis[2].relX = self.tx-self.x
	self.vis[2].relY = self.ty-self.y
	object.draw(self)
end

function Laser:setAcceleration()
end

function Laser:postStep(dt)
	local timeTot = self.timeOn+self.timeOff
	self.phase = (self.phase - dt / timeTot)%1
	if self.phase < self.timeOff/timeTot then
		self.isFiring = true
	else
		self.isFiring = false
	end
end

function Laser:postpostStep(dt)
	if self.isFiring and myMap then
		local free,tx,ty = myMap:lineOfSight(self.sx,self.sy,self.ex,self.ey)
		if not free then
			self.tx = tx
			self.ty = ty
		else
			self.tx = self.ex
			self.ty = self.ey
		end
		--EditorMap:lineOfSight(x1,y1,x2,y2)
	end
end

return Laser
