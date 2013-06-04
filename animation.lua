Animation = {}

function Animation:New(input)
  local o = input or {}
	setmetatable(o, self)
	self.__index = self
	
	o.timer = 0
	o.frame = 1
	return o
end

function Animation:reset()
  self.frame = 1
  self.timer = 0
end

function Animation:setAnim(name) -- Go to specified animation and reset, if not already there
	--if not self.data then return end
	if self.currentAnim ~= name then
	  self.currentAnim = name
	  self:reset()
	end
  --[[if self.data.anim[name] then
    if self.currentAnim ~= self.data.anim[name] then
			self.currentAnim = self.data.anim[name]
			self:reset()
		end
	else
		self.currentAnim = nil
	end--]]
end

function Animation:flip(flipped)
  self.flipped = flipped
end

function Animation:update(dt)
  self.timer = self.timer + dt
  -- switch to next frame
  if self.currentAnim then
		while self.timer > self.data.anim[self.currentAnim].duration[self.frame] do
			self.timer = self.timer - self.data.anim[self.currentAnim].duration[self.frame]
			self.frame = self.frame + 1
			if self.frame > #self.data.anim[self.currentAnim].frames then
				self.frame = 1
			end
		end
		self.currentQuad = self.data.anim[self.currentAnim].frames[self.frame]
  end
end

function Animation:draw(x,y,angle,ox,oy)
	if not self.data then return end
  local sx
  if self.flipped then
    sx = -1
	else
    sx = 1
	end
	if self.data.quads[self.currentQuad] then
		love.graphics.drawq(self.data.image, self.data.quads[self.currentQuad],x,y,angle,sx,1,ox,oy)
	end
end