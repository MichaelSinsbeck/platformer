require "object"

spriteEngine = {
objects = {}
}

function spriteEngine:insert(newObject)
  if newObject.init then
	  newObject:init()
	end
  table.insert(self.objects,newObject)
end

function spriteEngine:update(dt)
  for i,v in pairs(self.objects) do
    if v.update then
      v:update(dt)
    end
  end
  self:kill()
end

function spriteEngine:draw()
  for i,v in pairs(self.objects) do
    if v.draw then
			v:draw()
	  end
  end
end

function spriteEngine:empty()
  self.objects = {}
end

function spriteEngine:kill()
-- erase 'dead' objects
  for i = #self.objects,1,-1 do
    if self.objects[i].dead then
			table.remove(self.objects,i)
    end
  end
end
