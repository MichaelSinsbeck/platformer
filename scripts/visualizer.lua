Visualizer = {
}

function Visualizer:New(name,input,text)
  local o = input or {}
  o.animation = name or ''
  o.timer = o.timer or 0
  o.frame = o.frame or 1
  o.sx, o.sy = o.sx or 1, o.sy or 1
  o.relX, o.relY = o.relX or 0, o.relY or 0
  o.angle = o.angle or 0
  o.alpha = o.alpha or 255
  o.text = o.text or text
  if o.text then
	o.ox = -0.5*fontSmall:getWidth(o.text)
	o.oy = -0.5*fontSmall:getHeight()
  end
	if o.active == nil then o.active = true end
	setmetatable(o, self)
	self.__index = self
	--o:init()
	return o
end

function Visualizer:init()
	if self.animation and AnimationDB.animation[self.animation] then
		local name = AnimationDB.animation[self.animation].source
		self.ox = self.ox or 0.5*AnimationDB.source[name].width/Camera.scale
		self.oy = self.oy or 0.5*AnimationDB.source[name].height/Camera.scale
	end
	self:update(0)
end

function Visualizer:copy()
  local o = Visualizer:New(self.animation)
  o.timer = self.timer or 0
  o.frame = self.frame or 1
  o.sx, o.sy = self.sx or 1, self.sy or 1
  o.angle = self.angle or 0
  o.alpha = self.alpha or 255
  o.relX, o.relY = self.relX or 0, self.relY or 0
  o.active = self.active
  o.ox, o.oy = self.ox, self.oy
  o.text = self.text
  --o:init()
  return o
end

function Visualizer:reset()
	self.frame = 1
	self.timer = 0
end

function Visualizer:draw(x,y)
	if self.active then
		--print(self.img, self.currentQuad, self.text)
		if self.img and self.currentQuad then
			love.graphics.setColor(255,255,255,self.alpha)
			love.graphics.drawq(self.img, self.currentQuad,
				math.floor(x+self.relX*Camera.scale*8),
				math.floor(y+self.relY*Camera.scale*8),
				self.angle,
				self.sx,self.sy,
				self.ox*Camera.scale,self.oy*Camera.scale)
		elseif self.text then
			love.graphics.setColor(0,0,0, self.alpha)
			love.graphics.setFont(fontSmall)
			print(x, y, self.ox, self.oy,  x+self.ox, y+self.oy)
			love.graphics.print(self.text, x+self.ox, y+self.oy)
		end
	end
end

function Visualizer:update(dt)
  self.timer = self.timer + dt
  -- switch to next frame
  if self.animation then
		local animationData = AnimationDB.animation[self.animation]
		if animationData then -- only advance, if the animation exists in DB
			local source = AnimationDB.source[animationData.source]
			while self.timer > animationData.duration[self.frame] do
				self.timer = self.timer - animationData.duration[self.frame]
				self.frame = self.frame + 1
				if self.frame > #animationData.frames then
					self.frame = 1
				end
			end
			self.currentQuad = source.quads[animationData.frames[self.frame]]
			self.img = source.image
		else -- if animation does not exists
			self.img = nil
		end
  end
end

function Visualizer:setAni(name)
	if self.animation ~= name then
	  self.animation = name
	  if not continue then
	    self:reset()
	  end
	end
end
