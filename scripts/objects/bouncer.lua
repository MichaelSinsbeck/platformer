Bouncer = object:New({
	tag = 'bouncer',
  targetvy = -23,
  marginx = 0.8,
  marginy = 0.2,
  vis = {
		Visualizer:New('bouncer',{frame = 2}),
  },  
})

function Bouncer:setAcceleration(dt)
end

function Bouncer:postStep(dt)
	if self:touchPlayer() then
     p.vy = math.min(self.targetvy,p.vy)
     p.canUnJump = false
     self:resetAnimation()
  end
end

BouncerTop = Bouncer:New({
	targetvy = 23,
  vis = {
		Visualizer:New('bouncer',{frame = 2,angle = math.pi,}),
  },
	layout = 'top',
})

function BouncerTop:postStep(dt)
	if self:touchPlayer() then
     p.vy = math.max(self.targetvy,p.vy)
     p.canUnJump = false
     self:resetAnimation()
  end
end

BouncerLeft = Bouncer:New({
  marginx = 0.2,
  marginy = 0.8,
	targetvx = 23,
  vis = {
		Visualizer:New('bouncer',{frame = 2,angle = 0.5*math.pi,}),
  },
	layout = 'left',
})

function BouncerLeft:postStep(dt)
	if self:touchPlayer() then
		p.vx = math.max(self.targetvx,p.vx)
		p.status = 'fly'
		self:resetAnimation()
  end
end

BouncerRight = BouncerLeft:New({
	targetvx = -23,
  vis = {
		Visualizer:New('bouncer',{frame = 2,angle = -0.5*math.pi,}),
  }, 	
	--animationData = {frame = 2,angle = -0.5*math.pi,},
	layout = 'right',
})

function BouncerRight:postStep(dt)
	if self:touchPlayer() then
		p.vx = math.min(self.targetvx,p.vx)
		p.status = 'fly'
		self:resetAnimation()
  end
end
