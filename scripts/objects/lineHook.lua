local LineHook = object:New({
	--ID = 0,
	tag = 'LineHook',
	layout = 'center',
  isInEditor = true,
	vis = {
	Visualizer:New('lineHook'),
	}
})
--[[
function LineHook:setID( new )
	self.ID = new
end]]

return LineHook
