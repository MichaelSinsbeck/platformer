Campaign = {		
	'n13.dat',
	'n1.dat',
	'n10.dat',
	'n2.dat',
	'n3.dat',
	'n15.dat',
	'n38.dat',
	'n11.dat',
	'n12.dat',
	'n5.dat',
	'n24.dat',	
	'n6.dat',
	'n7.dat',
	'n8.dat',
	'n9.dat',
	'n14.dat',
	'n17.dat',	
	'n18.dat',
	'n16.dat',
	'n20.dat',
	'n19.dat',
	'n21.dat',
	'n23.dat',
	'n27.dat',
	'n26.dat',
	'n28.dat',
	'n25.dat',
	'n22.dat',
	'n29.dat',
	'n31.dat',
	'n30.dat',
	'n32.dat',
	'n33.dat',
	'n34.dat', -- button
	'n35.dat',
	'n36.dat',
	'n37.dat', -- imitator
	'n39.dat',
	'n40.dat',	
	'n41.dat', -- wind
	'n42.dat', -- breaking block
	'n44.dat', -- glass tutorial
	'n43.dat', -- glass long level			
	'n45.dat', -- fixed cannon	
	
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
