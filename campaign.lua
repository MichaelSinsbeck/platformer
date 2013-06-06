Campaign = {'n1.dat','n2.dat','n3.dat','n4.dat','n5.dat','n6.dat'}
--Campaign = {'n1.dat','n2.dat','n3.dat','n4.dat','n5.dat','n6.dat','m1.dat','m3.dat','l1.dat','l2.dat','l3.dat','l4.dat', 'l5.dat','l6.dat','l7.dat','featuretest.dat','m1.dat'}
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
