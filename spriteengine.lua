require "object"

spriteEngine = {
objects = {}
}

function spriteEngine:insert(newObject)
  newObject:init()
  table.insert(self.objects,newObject)
end

function spriteEngine:update(dt)
  for i,v in pairs(self.objects) do
    v:update(dt)
  end
end

function spriteEngine:draw()
  for i,v in pairs(self.objects) do
    v:draw()
  end
end

function spriteEngine:empty()
  self.objects = {}
end

function spriteEngine:kill()
-- erase 'dead' objects
  for i = #self.objects,-1,1 do
    if self.objects[i].dead then
			table.remove(self.objects,self.objects[i])
    end
  end
end
