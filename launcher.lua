local launcherAnim = Animation:New()
launcherAnim:loadImage('images/launcher.png',50,50)
launcherAnim:addAni('loading',{1,2,3},{.45,.45,1e6})
launcherAnim.frame = 3

Launcher = object:New({
  radius2 = 20^2,
  firerate = 1,--1.5, -- in seconds
  rotating = true,
  timeleft = 0,
  velocity = 10,
  --img = love.graphics.newImage('images/launcher.png')
  animation = launcherAnim
})

function Launcher:setAcceleration(dt)
  local dx = self.x-p.x
  local dy = self.y-p.y
  
  self.timeleft = self.timeleft - dt
  if self.timeleft < 0 then self.timeleft = 0 end
  
  if lineOfSight(self.x,self.y,p.x,p.y) then

		self.angle = math.atan2(dy,dx)										    
    if self.timeleft == 0 then --shoot
			local vx = -self.velocity*math.cos(self.angle)
			local vy = -self.velocity*math.sin(self.angle)
			local newBullet = Missile:New({x=self.x,y=self.y,vx=vx,vy=vy})
			spriteEngine:insert(newBullet)
			self.timeleft = self.firerate
			self.animation:reset()
    end
  end
end
