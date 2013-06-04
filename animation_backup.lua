Animation = {
	state = 
		{frame = 1,
		timer = 0,
		flipped = false}
  }

function Animation:New(input)
  local o = input or {}
	setmetatable(o, self)
	self.__index = self
	--[[o.frame = 1
	o.timer = 0
	o.flipped = false
	o.currentQuad = 1
	o.currentAnim = nil--]]
	o.state = self:EmptyState()
	return o
end

function Animation:EmptyState()
  return {frame = 1,
  timer = 0,
  flipped = false
  }
end

function Animation:loadImage(filename,height,width)
-- Load image and prepare quads
  self.image = love.graphics.newImage(filename)
  self.height = height
  self.width = width
  self.anim = {}
  self.state.frame = 0
  self.state.timer = 0
  
  self.quads = {}
  
  local imageWidth = self.image:getWidth()
  local imageHeight = self.image:getHeight()
  for j = 1,math.floor(imageHeight/height) do
    for i = 1,math.floor(imageWidth/width) do
      self.quads[i+(j-1)*math.floor(imageWidth/width)] = 
        love.graphics.newQuad((i-1)*(width),(j-1)*(height), width, height,
        imageWidth,imageHeight)
    end
  end
end

function Animation:reset()
  self.state.frame = 1
  self.state.timer = 0
end

function Animation:setAnim(name) -- Go to specified animation and reset, if not already there
  if self.anim[name] then
    if self.state.currentAnim ~= self.anim[name] then
			self.state.currentAnim = self.anim[name]
			self:reset()
		end
	else
		self.currentAnim = nil
	end
end

function Animation:flip(flipped)
  self.state.flipped = flipped
end

function Animation:update(dt)
  self.state.timer = self.state.timer + dt
  -- switch to next frame
  if self.state.currentAnim then
		while self.state.timer > self.state.currentAnim.duration[self.state.frame] do
			self.state.timer = self.state.timer - self.state.currentAnim.duration[self.state.frame]
			self.state.frame = self.state.frame + 1
			if self.state.frame > #self.state.currentAnim.frames then
				self.state.frame = 1
			end
		end
		self.state.currentQuad = self.state.currentAnim.frames[self.state.frame]
  end
end

function Animation:addAni(name,frames,duration)
	-- check, iff both input tables have the same length and add zeros, if necessary
	local frameLength = #frames
	local durationLength = #duration
	if frameLength > durationLength then
	  for excess = durationLength+1,frameLength do
	    duration[excess] = 0
	  end
	end
  self.anim[name] = {}
  self.anim[name].frames = frames
  self.anim[name].duration = duration
  self:setAnim(name)
end

function Animation:draw(x,y,angle,ox,oy)
  local sx
  if self.state.flipped then
    sx = -1
	else
    sx = 1
	end
	if self.quads[self.state.currentQuad] then
		love.graphics.drawq(self.image, self.quads[self.state.currentQuad],x,y,angle,sx,1,ox,oy)
	end
end
