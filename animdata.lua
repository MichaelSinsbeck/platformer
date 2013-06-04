AnimData = {}

function AnimData:New(input)
  local o = input or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function AnimData:loadImage(filename,height,width)
-- Load image and prepare quads
  self.image = love.graphics.newImage(filename)
  self.height = height
  self.width = width
  self.quads = {}
  self.anim = {}
  
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

function AnimData:addAni(name,frames,duration)
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
  self.default = name
  --self:setAnim(name)
end

function AnimData:NewAnim()
	local newAnim = Animation:New()
	newAnim.data = self
	if self.default then
		newAnim:setAnim(self.default)
	end
	return newAnim
end
