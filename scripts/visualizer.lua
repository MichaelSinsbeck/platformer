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

function Visualizer:useMesh()
	self.update = self.updateMesh
	self.draw = self.drawMesh
end

function Visualizer:getSize() -- returns size in pixels (screen coordinates)
	if self.animation and AnimationDB.animation[self.animation] then
		local name	= AnimationDB.animation[self.animation].source
		local width = AnimationDB.source[name].width
		local height = AnimationDB.source[name].height
		return width,height
	else
		return 0,0
	end
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

function Visualizer:draw(x,y, useExternalColor)
	if self.active then
		local img = self:getImage()
		if img and self.currentQuad then
			local r,g,b = love.graphics.getColor()
			if not useExternalColor then
				love.graphics.setColor(255,255,255,self.alpha)
			else
				love.graphics.setColor(r,g,b,self.alpha)
			end
			love.graphics.draw(img, self.currentQuad,
				math.floor(x+self.relX*Camera.scale*8),
				math.floor(y+self.relY*Camera.scale*8),
				self.angle,
				self.sx,self.sy,
				self.ox*Camera.scale,self.oy*Camera.scale)
			love.graphics.setColor(r,g,b)
		elseif self.text then
			love.graphics.setColor(0,0,0, self.alpha)
			love.graphics.setFont(fontSmall)
			love.graphics.print(self.text, x+self.ox, y+self.oy)
		else
			print('Nothing to draw here')
		end
	end
end

function Visualizer:getImage()
	if self.imgName then
		return AnimationDB.image[self.imgName]
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
			self.imgName = source.name
		else -- if animation does not exists
			self.imgName = nil
		end
  end
end

-- The following uses a mesh to draw the animation:
function Visualizer:drawMesh(x,y, useExternalColor)
	if self.active then
		if self.currentMesh then
			if not useExternalColor then
				love.graphics.setColor(255,255,255,self.alpha)
			end
			love.graphics.draw(self.currentMesh,
				math.floor(x+self.relX*Camera.scale*8),
				math.floor(y+self.relY*Camera.scale*8),
				self.angle,
				self.sx,self.sy,
				self.ox*Camera.scale,self.oy*Camera.scale)
		elseif self.text then
			love.graphics.setColor(0,0,0, self.alpha)
			love.graphics.setFont(fontSmall)
			love.graphics.print(self.text, x+self.ox, y+self.oy)
		end
	end
end

function Visualizer:updateMesh(dt)
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
			self.currentMesh = source.meshes[animationData.frames[self.frame]]
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
