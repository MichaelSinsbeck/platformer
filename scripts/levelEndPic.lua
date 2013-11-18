-- contains a list of all images displayed at level end:
local pics = {}
local picList = {}

function pics:reset()
	picList = {}
end

function pics:new( x, y, statType, num )
	local newPic = { x=x, y=y, vis = {}, posX = {}, posY = {} }
	if statType == "fall" then
		for k = 1, num do
			newPic.vis[k] = Visualizer:New( 'deathFall' .. math.random(4) )
			newPic.vis[k]:init()
			if math.random(2) == 1 then
				newPic.vis[k].sx = -1
			end
			newPic.posX[k] = math.random(25)-12.5
			newPic.posY[k] = math.random(10)/5
		end
	elseif statType == "spikes" then
		for k = 1, num do
			newPic.vis[k] = Visualizer:New( 'deathSpikes' .. math.random(4) )
			newPic.vis[k]:init()
			if math.random(2) == 1 then
				newPic.vis[k].sx = -1
			end
			newPic.posX[k] = math.random(25)-12.5
			newPic.posY[k] = math.random(10)/5
		end
	end

	picList[#picList+1] = newPic
end

function pics:draw()
	local x,y
	for k,pic in pairs(picList) do
		for k = 1,#pic.vis do
			x = pic.x + pic.posX[k]
			y = pic.y + pic.posY[k]
			pic.vis[k]:draw( x*Camera.scale, y*Camera.scale )
		end
	end
end

return pics
