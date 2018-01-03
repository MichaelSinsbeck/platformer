local Panel = require( "scripts/menu/menuPanel" )

local vanishingTime = 1/2
local LevelNameDisplay = {}
LevelNameDisplay.__index = LevelNameDisplay

function LevelNameDisplay:new( name, time )
	local o = {}
	setmetatable( o, self )

	o.name = name

	local w, lines = fontLarge:getWrap( name, 80*Camera.scale ) -- in pixel
	lines = #lines
	o.h = lines*fontLarge:getHeight()/Camera.scale + 8
	o.w = w/Camera.scale + 16

	o.box = Panel:new( 0, 0, o.w, o.h )
	o.box.x = ( love.graphics.getWidth() - o.box.box.pixelWidth )/2/Camera.scale
	--o.box.y = 0

	o.textWidth = w
	--o.textY = 0
	o.textGoalY = o.box.y*Camera.scale + (o.box.box.pixelHeight - lines*fontLarge:getHeight())/2
	o.textStartY = (o.box.y - o.box.box.pixelHeight)*Camera.scale + (o.box.box.pixelHeight - lines*fontLarge:getHeight())/2
	o.textX = o.box.x*Camera.scale + (o.box.box.pixelWidth - o.textWidth)/2
	o.lines = lines
	o.boxGoalY = 0
	o.boxStartY = -o.box.box.pixelHeight 
	
	o.box.y = o.boxStartY
	o.textY = o.textStartY

	o.active = true
	o.timer = time
	o.fullTime = time
	o.pos = 0

	return o
end

function LevelNameDisplay:draw()
	self.box:draw()
	love.graphics.setColor(colors.text)
	love.graphics.setFont( fontLarge )
	love.graphics.printf( self.name, math.floor(self.textX), math.floor(self.textY), self.textWidth, "center" )
	love.graphics.setColor(colors.white)
end

function LevelNameDisplay:update( dt )
	self.timer = self.timer - dt
	self.animation = utility.clamp(self.timer / vanishingTime,0,1)
	
	self.box.y = self.boxGoalY*self.animation + self.boxStartY*(1-self.animation)
	self.textY = self.textGoalY*self.animation + self.textStartY*(1-self.animation)

	if self.timer < 0 then
		return false
	end
	return true
end

function LevelNameDisplay:goAway()
	self.timer = math.min(self.timer, vanishingTime + 0.1)
end

return LevelNameDisplay
