local Transition = {}
Transition.__index = Transition

function Transition:new( submenu, time, startX, startY, startRot, endX, endY, endRot, startTime )
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
	o.curX = startX
	o.curY = startY
	o.curRot = startRot
	o.startTime = startTime	-- wait for startTime to be over before running the animation

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

-- Spline-like function that smoothes out transition.
-- Give value between 0 and 1 and it returns a value between 0 and 1, but "smoother".
function Transition:interpolateCos( rel )
	return -math.cos(math.pi*rel)*0.5 + 0.5
end

function Transition:update( dt )
	self.passedTime = self.passedTime + dt

	if self.passedTime > self.startTime then
		local smoothed = self:interpolateCos( (self.passedTime - self.startTime)/self.time )
		self.curX = smoothed*(self.endX - self.startX) + self.startX
		self.curY = smoothed*(self.endY - self.startY) + self.startY
		self.curRot = smoothed*(self.endRot - self.startRot) + self.startRot
		if self.passedTime > self.startTime + self.time then
			self.submenu:finishedTransition( self )
		end
	end
end

return Transition

