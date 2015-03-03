local Star = object:New({
	tag = 'Star',
	category = 'Enemies',
	layout = 'center',
	marginx = 0.6,
  marginy = 0.6,  
  isInEditor = true,
  zoomState = 0,
  maxDistance = 5,
  circleState = 0,
  vis = {
		Visualizer:New('starBody'),
		Visualizer:New('starFace'),
		Visualizer:New('starEyes'),
		Visualizer:New('crosshairs',{sx=0, sy=0}),
  },
--	properties = {
--		direction = utility.newCycleProperty({0, .5, 1, -.5}, {'vertical', 'diagonal1','horizontal','diagonal2'}),
--	},
	anchorRadii = {.2,.2},
})

function Star:applyOptions()
end

function Star:setAcceleration(dt)
	self.vx = 0
	self.vy = 0
end

function Star:draw()
	object.draw(self)
	local s = Camera.scale*8
	love.graphics.setLineWidth(Camera.scale*0.2)
	love.graphics.setColor(200,200,200,127*self.circleState)
	
	love.graphics.circle('line',self.x*s,self.y*s,self.maxDistance*s)
		  

	love.graphics.setColor(255,255,255)
end

function Star:postStep(dt)
	self.vis[1].angle = (self.vis[1].angle + 5*dt)%(2*math.pi)
	self.circleState = math.max(self.circleState - 3*dt,0)

	local dx,dy = self.x-p.x, self.y-p.y
	local ratio = utility.pyth(dx,dy)/self.maxDistance
	
	if ratio > 1.01 then
		dx = dx/ratio
		dy = dy/ratio
		self.x = p.x + dx
		self.y = p.y + dy
		self.circleState = 1
	end
	
	self.vis[3].relX = -0.01*dx
	self.vis[3].relY = -0.01*dy
  -- show crosshairs
  if self.anchorRadii then
		if self.isCurrentTarget then
			self.zoomState = math.min(self.zoomState + 5*dt,1)
		else
			self.zoomState = math.max(self.zoomState - 7*dt,0)
		end
		local s = utility.easingOvershoot(self.zoomState)

		self.vis[4].angle = self.vis[4].angle + dt
		self.vis[4].sx = s
		self.vis[4].sy = s 
	end
	
  -- Kill player, if touching
	if not p.dead and self:touchPlayer(dx,dy) then
    p:kill()
    levelEnd:addDeath("death_star")
    objectClasses.Meat:spawn(p.x,p.y,self.vx,self.vy,12)
    self:playSound('starDeath')
  end
end


function Star:onKill()
	if p.anchor and p.anchor.target == self then
		spriteEngine:DoAll('disconnect')
	end
end

return Star
