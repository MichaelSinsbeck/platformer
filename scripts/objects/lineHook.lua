LineHook = object:New({
	ID = 0,
	vis = {
		Visualizer:New('whiteLineSlide'),
	}
})

function LineHook:setID( new )
	self.ID = new
end
