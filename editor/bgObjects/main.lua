function love.load()
	dofile("automaticSort.lua")
	automaticSort()
	love.event.quit()
end

