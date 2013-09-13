
levelEnd = {}

local deathList = {}

function levelEnd:reset()
	deathList["fall"] = 0
	deathList["shuriken"] = 0
	deathList["goalie"] = 0
	deathList["imitator"] = 0
	deathList["missile"] = 0
	deathList["spikey"] = 0
	deathList["runner"] = 0
end

function levelEnd:addDeath( deathType )
	deathList[deathType] = deathList[deathType] + 1
end

function levelEnd:draw( )
	-- for now, just show a simple list:
	local font = love.graphics.getFont()
	local i = 0
	for k, v in pairs(deathList) do
		love.graphics.setColor(80,150,205)
		love.graphics.print(k, love.graphics.getWidth()/2 - font:getWidth(k) - 5, love.graphics.getHeight()/2 - font:getHeight()*(4 -i))
		love.graphics.setColor(255,255,255)
		love.graphics.print(v, love.graphics.getWidth()/2 + 5, love.graphics.getHeight()/2 - font:getHeight()*(4-i))
		i = i+1
	end
end

function levelEnd:display( )	-- called when level is won:
	mode = 'levelEnd'
	love.graphics.setBackgroundColor(40,40,40)
end

function levelEnd:keypressed( key, unicode )
	if key == 'escape' then
		menu.startTransition(menu.initWorldMap)()
	else	
	    Campaign:proceed()
	    mode = 'game'
    end
end
