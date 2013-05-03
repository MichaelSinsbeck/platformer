Campaign = {'featuretest.dat', 'l1.dat','l2.dat','l3.dat','l4.dat', 'l5.dat','l6.dat','l7.dat'}
Campaign.current = 0

function Campaign:reset()
  self.current = 1
  myMap = Map:LoadFromFile(self[self.current])  
end

function Campaign:proceed()
  self.current = self.current + 1
  if self[self.current] then
    myMap = Map:LoadFromFile(self[self.current])
    myMap:start(p)
  else
    mode = 'menu'
  end
end
