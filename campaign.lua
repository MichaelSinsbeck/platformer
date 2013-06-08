Campaign = {
	'n13.dat',
	'n1.dat',
	'n10.dat',
	'n2.dat',
	'n3.dat',
	'n11.dat',
	'n4.dat',
	'n12.dat',
	'n5.dat',
	'n6.dat',
	'n7.dat',
	'n8.dat',
	'n9.dat',
	}

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
