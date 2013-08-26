Bungee = object:New({	
	tag = 'Bungee',
	animation = 'bungee',
	marginx = 0.2,
  marginy = 0.2,
})

function Bungee:setAcceleration(dt)
end

function Bungee:draw()
	object.draw(self)
	love.graphics.setLineWidth(Camera.scale*0.4)
	local r, g, b, a = love.graphics.getColor()	
	love.graphics.setColor(212,0,0)
	love.graphics.line(
		math.floor(self.x*myMap.tileSize),
		math.floor(self.y*myMap.tileSize),
		math.floor(p.x*myMap.tileSize),
		math.floor(p.y*myMap.tileSize))
	
	love.graphics.setColor(r,g,b,a)
end

function Bungee:postStep(dt)
  if self.collisionResult > 0 then
		self.vx = 0
		self.vy = 0	
		p:hook(self)
  end
end

function Bungee:throw()
	game:checkControls()
	local rvx,rvy = p.vx, math.min(p.vy-20,-20)
	if game.isLeft then
		rvx = rvx - 20
	end
	if game.isRight then
		rvx = rvx + 20
	end
	if rvx ~= 0 then
		rvx,rvy = rvx/math.sqrt(2),rvy/math.sqrt(2)
	end
	local angle = math.atan2(rvy,rvx)
	local newBungee = self:New({x=p.x,y=p.y,vx=rvx,vy=rvy,angle=angle})
	spriteEngine:insert(newBungee)	
end

function Bungee:disconnect()
	self:kill()
end
