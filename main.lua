-- global list that holds the death animations
-- (only single frame images for now):
deathAnimations = {}
deathAnimations[1] = love.graphics.newImage("images/death1.png")
deathAnimations[2] = love.graphics.newImage("images/death2.png")
deathAnimations[3] = love.graphics.newImage("images/death3.png")

-- list of deaths... in a real-world example, the game would save
-- every death at the end of this list
deaths = {}
deathTimers = {}

local numDeaths = math.random(4,8)

function love.load()

end

function love.draw()
	w = 10
	
	love.graphics.setColor(128, 179, 255)
	--love.graphics.setColor(28, 79, 155)
	love.graphics.rectangle("fill",0, love.graphics.getHeight()/2-60, love.graphics.getWidth(), 60)
	love.graphics.setColor(255,255,255)
	for i=1,#deaths do
		h = - math.min(deathTimers[i], 1)*deathAnimations[1]:getHeight() + love.graphics.getHeight()/2 --deathAnimations[1]:getHeight()
		love.graphics.draw(deathAnimations[deaths[i]], w, h)
		w = w + deathAnimations[deaths[i]]:getWidth() + 25
	end

	love.graphics.setColor(172,157,147)
	love.graphics.setColor(0,0,0)
love.graphics.rectangle("fill",0, love.graphics.getHeight()/2, love.graphics.getWidth(), 50)
	--[[love.graphics.setColor(132,127,117)
love.graphics.rectangle("fill",0, love.graphics.getHeight()/2+50, love.graphics.getWidth(), 5)
	love.graphics.setColor(102,97,87)
love.graphics.rectangle("fill",0, love.graphics.getHeight()/2+55, love.graphics.getWidth(), 5)
	love.graphics.setColor(50,30,25)
love.graphics.rectangle("fill",0, love.graphics.getHeight()/2+60, love.graphics.getWidth(), 5)
	love.graphics.setColor(20,10,10)
love.graphics.rectangle("fill",0, love.graphics.getHeight()/2+65, love.graphics.getWidth(), 5)
	love.graphics.setColor(0,0,0)
love.graphics.rectangle("fill",0, love.graphics.getHeight()/2, love.graphics.getWidth(), 2)
]]--
	love.graphics.setColor(255,255,255)

	
end

timeUntilNewImg = 1
timeRunning = 1
function love.update(dt)
	
	for i = 1,#deathTimers do
		deathTimers[i] = deathTimers[i] + dt*deathTimers[i] + dt*timeRunning
	end
	timeRunning = timeRunning + dt
	timeUntilNewImg = timeUntilNewImg - dt*2
	if timeUntilNewImg < 0 and numDeaths > #deaths then
		deaths[#deaths+1] = math.random(3)	-- add a death to list
		deathTimers[#deaths] = 0
		if #deaths > 2 then
			timeUntilNewImg = .5
		else
			timeUntilNewImg = 2
		end
	end
end
