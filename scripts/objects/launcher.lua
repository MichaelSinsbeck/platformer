local Launcher = object:New({
	tag = 'Launcher',
	category = "Enemies",
	radius2 = 20^2,
  --firerate = 3, -- in # of tiles
  rotating = true,
  timeleft = 0,
  --velocity = 3, --15
  marginx = .8,
  marginy = .8,
  isInEditor = true,
  vis = {
		Visualizer:New('launcher',{angle = -0.5*math.pi}),
		Visualizer:New('launcherSon'),
  },
	properties = {
		distance = utility.newIntegerProperty(3,1,10),
		velocity = utility.newIntegerProperty(15,1,20),
	},  
})

function Launcher:applyOptions()
	self.timeleft = self.distance/self.velocity
end

function Launcher:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  self.timeleft = self.timeleft - dt
  if self.timeleft < 0 then self.timeleft = 0 end
  
  if p.visible and not p.dead and myMap:lineOfSight(self.x,self.y,p.x,p.y) then
  
    self.vis[1].angle = math.atan2(dy,dx)    
    if self.timeleft == 0 then --shoot
			local vx = -self.velocity*math.cos(self.vis[1].angle)
			local vy = -self.velocity*math.sin(self.vis[1].angle)
			local newAngle = math.random()*math.pi*2
			local newShuriken = spriteFactory('Shuriken',{x=self.x,y=self.y,vx=vx,vy=vy,vis={Visualizer:New('shuriken',{angle=newAngle})} })
			spriteEngine:insert(newShuriken)
			self.timeleft = self.distance/self.velocity
			self:playSound('launcherShoot')
    end
  end
  self.vis[2].angle = self.vis[2].angle + 5*dt
end

return Launcher
