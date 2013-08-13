require 'objects.object'

spriteEngine = {
objects = {}
}

function spriteEngine:insert(newObject)
  if newObject.init then
	  newObject:init()
	end
  table.insert(self.objects,newObject)
  --table.sort(self.objects, function(a,b) return a.z < b.z end)
end

function spriteEngine:update(dt)
  for i,v in ipairs(self.objects) do
    if v.update then
      v:update(dt)
    end
  end
  self:kill()
end

function spriteEngine:draw()
  for i = #self.objects,1,-1 do
    if self.objects[i].draw then
			self.objects[i]:draw()
	  end
  end
end

function spriteEngine:empty()
  self.objects = {}
end

function spriteEngine:kill()
-- erase 'dead' objects
  for i = #self.objects,1,-1 do
		local thisObject = self.objects[i]
    if thisObject.dead then
			table.remove(self.objects,i)
		elseif thisObject.tag ~= 'player' and
		  (thisObject.x < 0 or
		   thisObject.x > myMap.width +2 or
		   thisObject.y < 0 or
		   thisObject.y > myMap.height+2) then
		  table.remove(self.objects,i)
    end
  end
end

function spriteEngine:DoAll(functionName,args)
  for i,v in ipairs(self.objects) do
		if v[functionName] then
		  v[functionName](v,args)
		end
	end
end
