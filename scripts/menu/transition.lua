local Transition = {}
Transition.__index = Transition

function Transition:new( submenu, time, startX, startY, startRot, endX, endY, endRot )
	local o = {}
	setmetatable( o, self )
	o.submenu = submenu
	o.time = time or 1
	o.startX = startX or 0
	o.startY = startY or 0
	o.startRot = startRot or 0
	o.endX = endX or 0
	o.endY = endY or 0
	o.endRot = endRot or 0
	o.curX = 0
	o.curY = 0
	o.curRot = 0

	o.passedTime = 0

	return o
end

function Transition:push()
	love.graphics.push()

	love.graphics.translate( self.curX, self.curY )
	love.graphics.rotate( self.curRot )
end

function Transition:pop()
	love.graphics.pop()
end

function Transition:update( dt )
	self.passedTime = self.passedTime + dt
	self.curX = self.passedTime*(self.endX - self.startX)/self.time + self.startX
	self.curY = self.passedTime*(self.endY - self.startY)/self.time + self.startY
	self.curRot = self.passedTime*(self.endRot - self.startRot)/self.time + self.startRot
	if self.passedTime > self.time then
		self.submenu:finishedTransition()
	end
end

return Transition
