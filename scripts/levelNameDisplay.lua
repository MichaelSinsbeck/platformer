local Panel = require( "scripts/menu/menuPanel" )

local LevelNameDisplay = {}
LevelNameDisplay.__index = LevelNameDisplay

function LevelNameDisplay:new( name, time )
	local o = {}
	setmetatable( o, self )

	o.name = name

	local w, lines = fontLarge:getWrap( name, 400 )
	o.h = lines*fontLarge:getHeight()/8
	o.w = w/8 + 32

	o.box = Panel:new( 0, 0, o.w, o.h )
	o.box.x = ( love.graphics.getWidth() - o.box.box.pixelWidth )/2/Camera.scale
	o.box.y = 0

	o.textWidth = w
	o.textY = o.box.y*Camera.scale + (o.box.box.pixelHeight - lines*fontLarge:getHeight())/2
	o.textX = o.box.x*Camera.scale + (o.box.box.pixelWidth - o.textWidth)/2
	o.lines = lines

	o.active = true
	o.timer = time
	o.fullTime = time

	return o
end

function LevelNameDisplay:draw()
	self.box:draw()
	love.graphics.setFont( fontLarge )
	love.graphics.printf( self.name, self.textX, self.textY, self.textWidth, "center" )
end

function LevelNameDisplay:update( dt )
	self.timer = self.timer - dt
	if self.timer > self.fullTime - 2 then
		--[[local animHeight = self.box.box.pixelHeight
		self.pos = - animHeight*Camera.scale + (self.fullTime - self.timer)*animHeight/2
		self.box.y = self.pos
		self.textY = self.box.y*Camera.scale +
				(self.box.box.pixelHeight - self.lines*fontLarge:getHeight())/2]]
	end
	if self.timer < 0 then
		return false
	end
	return true
end

return LevelNameDisplay
