local Bandanasign = object:New({
	tag = 'Bandanasign',
  marginx = 0.8,
  marginy = 0.8,
  z = 1,
  isInEditor = true,
  layout = 'center',
  vis = {
    Visualizer:New('signEmpty'),
    Visualizer:New('signBandana'),
    Visualizer:New('signCross'),
  },
	properties = {
		color = utility.newCycleProperty({'white','yellow','green','blue','red'})
	},
})

function Bandanasign:draw()
	local x = self.x*8*Camera.scale
	local y = self.y*8*Camera.scale
	
	self.vis[1]:draw(x,y,true)
	local color = utility.bandana2color[self.color]
	if color and not self.anchor then
		local r,g,b = love.graphics.getColor()
		love.graphics.setColor(color[1],color[2],color[3],255)
		self.vis[2]:draw(x,y,true)
		love.graphics.setColor(r,g,b)
	end
	self.vis[3]:draw(x,y,true)
end

function Bandanasign:setAcceleration()
end

return Bandanasign
