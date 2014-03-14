local Cannon = object:New({
	tag = 'Cannon',
  radius2 = 20^2,
  firerate = 1,--1.5, -- in seconds
  rotating = true,
  isInEditor = true,
  timeleft = 0,
  velocity = 10,
  vis = {Visualizer:New('cannon',{angle = -0.5*math.pi}),},
  properties = {
		firerate = newProperty({.4, .6, .8, 1, 1.2, 1.4},nil,5),
	}
  --animation = 'cannon',
  --angle = -0.5*math.pi,
})

function Cannon:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  self.timeleft = self.timeleft - dt
  if self.timeleft < 0 then self.timeleft = 0 end
  
  if p.visible and not p.dead and lineOfSight(self.x,self.y,p.x,p.y) then
		self.vis[1].angle = math.atan2(dy,dx)										    
    if self.timeleft == 0 then --shoot
			local vx = -self.velocity*math.cos(self.vis[1].angle)
			local vy = -self.velocity*math.sin(self.vis[1].angle)
			local newBullet = spriteFactory('Missile',{x=self.x,y=self.y,vx=vx,vy=vy})
			spriteEngine:insert(newBullet)
			self.timeleft = self.firerate
			self:resetAnimation()
    end
  end
end

return Cannon
