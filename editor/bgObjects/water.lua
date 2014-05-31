local coords = {	
	-- plain water:
	{tileX=0,tileY=7,x=0,y=0},
	{tileX=0,tileY=8,x=0,y=1},

	-- water and wall:
	{tileX=0,tileY=21,x=1,y=0},
	{tileX=1,tileY=21,x=2,y=0},
	{tileX=2,tileY=21,x=3,y=0},

	-- water and mill:
	{tileX=0,tileY=19,x=1,y=1},
	{tileX=1,tileY=19,x=2,y=1},
	{tileX=2,tileY=19,x=3,y=1},
	{tileX=0,tileY=20,x=1,y=2},
	{tileX=1,tileY=20,x=2,y=2},
	{tileX=2,tileY=20,x=3,y=2},
}

return "background1", coords, "misc"
