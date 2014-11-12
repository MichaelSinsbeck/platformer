-- Class for the buttons in the menu (keyboard/gamepad controlled)

local Button = {}
Button.__index = Button

function Button:new()
	local o = {}
	setmetatable( o, self )
	return o
end

return Button
